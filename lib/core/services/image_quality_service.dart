import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Lighting status of a captured photo.
enum LightingStatus {
  tooDark,
  optimal,
  tooGlary,
}

/// Result of real image quality analysis via Laplacian variance,
/// luminance measurement, and glare pixel counting.
class ImageQualityResult {
  final double sharpnessScore; // 0–100, higher is sharper
  final bool isBlurry; // true when score < 45
  final double luminance; // 0–255 average pixel brightness
  final LightingStatus lighting;
  final double glarePercent; // % pixels with R,G,B all > 230
  final String sharpnessLabel;
  final String lightingLabel;

  const ImageQualityResult({
    required this.sharpnessScore,
    required this.isBlurry,
    required this.luminance,
    required this.lighting,
    required this.glarePercent,
    required this.sharpnessLabel,
    required this.lightingLabel,
  });

  /// Fallback result when analysis cannot be performed.
  factory ImageQualityResult.unavailable() => const ImageQualityResult(
        sharpnessScore: 0,
        isBlurry: false,
        luminance: 128,
        lighting: LightingStatus.optimal,
        glarePercent: 0,
        sharpnessLabel: 'Checking...',
        lightingLabel: 'Checking...',
      );
}

/// Runs all image quality checks in an Isolate so the UI thread is never
/// blocked while processing a multi-megapixel JPEG.
class ImageQualityService {
  ImageQualityService._();

  /// Analyse [imagePath] and return a fully populated [ImageQualityResult].
  static Future<ImageQualityResult> analyze(String imagePath) async {
    try {
      // Offload the heavy pixel work to a background isolate
      final result = await compute(_analyzeInIsolate, imagePath);
      return result;
    } catch (e) {
      debugPrint('ImageQualityService error: $e');
      return ImageQualityResult.unavailable();
    }
  }

  // ──────────────────────────────────────────────
  // Private isolate-safe worker function
  // ──────────────────────────────────────────────
  static ImageQualityResult _analyzeInIsolate(String imagePath) {
    final bytes = File(imagePath).readAsBytesSync();
    final original = img.decodeImage(bytes);
    if (original == null) return ImageQualityResult.unavailable();

    // Resize to a fast thumbnail — reduces work from megapixels to ~65k pixels
    final thumbnail = img.copyResize(
      original,
      width: 256,
      height: (original.height * 256 / original.width).round(),
      interpolation: img.Interpolation.average,
    );

    final greyscale = img.grayscale(thumbnail);
    final width = greyscale.width;
    final height = greyscale.height;
    final total = width * height;

    // ── 1. Laplacian variance for sharpness ─────────────────────────────────
    // Kernel: [0, 1, 0,  1,-4, 1,  0, 1, 0]
    double sumSq = 0;
    double sumVal = 0;
    int laplacianCount = 0;

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final center = greyscale.getPixel(x, y).r.toInt();
        final top = greyscale.getPixel(x, y - 1).r.toInt();
        final bottom = greyscale.getPixel(x, y + 1).r.toInt();
        final left = greyscale.getPixel(x - 1, y).r.toInt();
        final right = greyscale.getPixel(x + 1, y).r.toInt();

        final laplacian = top + bottom + left + right - 4 * center;
        sumSq += laplacian * laplacian;
        sumVal += laplacian;
        laplacianCount++;
      }
    }

    final mean = laplacianCount > 0 ? sumVal / laplacianCount : 0.0;
    final variance = laplacianCount > 0
        ? (sumSq / laplacianCount) - (mean * mean)
        : 0.0;

    // Normalise: variance of ~250 on a sharp phone photo → score 100
    // Tune the divisor to match your camera resolution/jpeg quality
    final sharpnessScore = (math.min(variance / 2.5, 100.0)).clamp(0.0, 100.0);
    final isBlurry = sharpnessScore < 45.0;

    // ── 2. Average luminance ─────────────────────────────────────────────────
    double lumSum = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        lumSum += greyscale.getPixel(x, y).r.toDouble();
      }
    }
    final double luminance = total > 0 ? lumSum / total : 128.0;

    // ── 3. Glare detection (% of pixels where R,G,B all > 230) ───────────────
    int glarePixels = 0;
    for (int y = 0; y < thumbnail.height; y++) {
      for (int x = 0; x < thumbnail.width; x++) {
        final pixel = thumbnail.getPixel(x, y);
        if (pixel.r > 230 && pixel.g > 230 && pixel.b > 230) {
          glarePixels++;
        }
      }
    }
    final glarePercent = total > 0 ? (glarePixels / total) * 100 : 0.0;

    // ── 4. Classify lighting ─────────────────────────────────────────────────
    final LightingStatus lighting;
    if (luminance < 55) {
      lighting = LightingStatus.tooDark;
    } else if (glarePercent > 12) {
      lighting = LightingStatus.tooGlary;
    } else {
      lighting = LightingStatus.optimal;
    }

    // ── 5. Human-readable labels ─────────────────────────────────────────────
    final sharpnessLabel = isBlurry
        ? 'Low Focus'
        : sharpnessScore < 70
            ? 'Acceptable'
            : 'High Focus';

    final lightingLabel = lighting == LightingStatus.tooDark
        ? 'Too Dark'
        : lighting == LightingStatus.tooGlary
            ? 'Glare Detected'
            : 'No Glare';

    return ImageQualityResult(
      sharpnessScore: sharpnessScore,
      isBlurry: isBlurry,
      luminance: luminance,
      lighting: lighting,
      glarePercent: glarePercent,
      sharpnessLabel: sharpnessLabel,
      lightingLabel: lightingLabel,
    );
  }
}
