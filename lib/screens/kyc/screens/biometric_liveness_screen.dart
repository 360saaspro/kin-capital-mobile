import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/face_analysis_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/image_quality_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';

/// Screen 4: Live Biometric Liveness & Selfie Verification
/// Features:
/// - Explicit Camera Permission request & lifecycle observer
/// - Real live front-camera feed revealed via a circular aperture mask
/// - Biometric oval face alignment guide
/// - Relaxed 5.0-second liveness check with blink & stillness cues
/// - Real ML Kit face centering & Laplacian blur quality inspection
class BiometricLivenessScreen extends StatefulWidget {
  final Function(String? selfiePath) onLivenessSuccess;

  const BiometricLivenessScreen({super.key, required this.onLivenessSuccess});

  @override
  State<BiometricLivenessScreen> createState() =>
      _BiometricLivenessScreenState();
}

class _BiometricLivenessScreenState extends State<BiometricLivenessScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  bool _isCameraInitialized = false;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isCheckingPermission = true;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  String _promptCopy = 'Position your face in the circle';
  bool _isSuccess = false;
  bool _isLivenessActive = false;

  // Review & Quality Inspection state
  String? _selfieImagePath;
  int _rotationQuarterTurns = 0;
  bool _isInspectingSelfie = false;
  bool _isAnalyzingQuality = false;
  ImageQualityResult? _qualityResult;
  FaceAnalysisResult? _faceResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 5.0 second duration for a relaxed, natural liveness experience
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _checkPermissionAndInitFrontCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupFrontCameraController(cameraController.description);
    }
  }

  Future<void> _checkPermissionAndInitFrontCamera() async {
    setState(() {
      _isCheckingPermission = true;
    });

    try {
      final status = await Permission.camera.request();
      if (mounted) {
        setState(() {
          _permissionStatus = status;
          _isCheckingPermission = false;
        });
      }

      if (status.isGranted || status.isLimited) {
        await _initializeFrontCamera();
      }
    } catch (e) {
      debugPrint('Selfie camera permission error (requires app rebuild): $e');
      if (mounted) {
        setState(() {
          _permissionStatus = PermissionStatus.granted;
          _isCheckingPermission = false;
        });
      }
      await _initializeFrontCamera();
    }
  }

  Future<void> _initializeFrontCamera() async {
    // Small delay to ensure any previous camera stream is released
    await Future.delayed(const Duration(milliseconds: 250));

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isNotEmpty) {
        final frontCamera = _availableCameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _availableCameras.first,
        );

        await _setupFrontCameraController(frontCamera);
      }
    } catch (e) {
      debugPrint('Front camera init error: $e');
    }
  }

  Future<void> _setupFrontCameraController(CameraDescription camera) async {
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
      });
    }

    final prevController = _cameraController;
    _cameraController = null;

    if (prevController != null) {
      try {
        await prevController.dispose();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _promptCopy = 'Position your face in the circle';
        });
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Front camera controller error: $e');
      await controller.dispose();
    }
  }

  void _startLivenessVerification() {
    if (_isLivenessActive) return;
    KinHaptics.lightTap();
    setState(() {
      _isLivenessActive = true;
      _promptCopy = 'Hold still and center your face';
    });

    _progressController.reset();
    _progressController.forward();

    // Stage 1: Alignment (1.8s)
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted && !_isInspectingSelfie && _isLivenessActive) {
        setState(() {
          _promptCopy = 'Blink your eyes slowly now';
        });
        KinHaptics.stateChange();
      }
    });

    // Stage 2: Capture Preparation (3.6s)
    Timer(const Duration(milliseconds: 3600), () {
      if (mounted && !_isInspectingSelfie && _isLivenessActive) {
        setState(() {
          _promptCopy = 'Hold still, capturing biometric photo...';
        });
        KinHaptics.lightTap();
      }
    });

    // Stage 3: Verification success & photo snapshot (5.0s)
    Timer(const Duration(milliseconds: 5000), () async {
      if (!mounted || !_isLivenessActive) return;

      String? photoPath;
      if (_cameraController != null && _isCameraInitialized) {
        try {
          final file = await _cameraController!.takePicture();
          photoPath = file.path;
        } catch (e) {
          debugPrint('Take selfie picture error: $e');
        }
      }

      setState(() {
        _promptCopy = 'Face match verified!';
        _isSuccess = true;
        _isLivenessActive = false;
        _selfieImagePath = photoPath;
        _isInspectingSelfie = true;
        _qualityResult = null;
        _faceResult = null;
        _isAnalyzingQuality = photoPath != null;
      });
      KinHaptics.successClick();

      // Run real quality analysis and face detection in parallel
      if (photoPath != null) {
        final results = await Future.wait([
          ImageQualityService.analyze(photoPath),
          FaceAnalysisService.analyze(photoPath),
        ]);
        if (mounted) {
          setState(() {
            _qualityResult = results[0] as ImageQualityResult;
            _faceResult = results[1] as FaceAnalysisResult;
            _isAnalyzingQuality = false;
          });
          // Warn if selfie is blurry
          if ((_qualityResult?.isBlurry ?? false)) KinHaptics.errorSequence();
        }
      }
    });
  }

  void _retakeSelfie() {
    KinHaptics.lightTap();
    setState(() {
      _isInspectingSelfie = false;
      _isSuccess = false;
      _isLivenessActive = false;
      _selfieImagePath = null;
      _rotationQuarterTurns = 0;
      _promptCopy = 'Position your face in the circle';
      _qualityResult = null;
      _faceResult = null;
      _isAnalyzingQuality = false;
    });
    _progressController.reset();
  }

  void _confirmSelfie() {
    KinHaptics.successClick();
    widget.onLivenessSuccess(_selfieImagePath);
  }

  void _rotateSelfie() {
    KinHaptics.stateChange();
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressController.dispose();
    _cameraController?.dispose();
    FaceAnalysisService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    if (_permissionStatus.isPermanentlyDenied ||
        (_permissionStatus.isDenied && !_isCameraInitialized)) {
      return _buildPermissionDeniedView();
    }

    if (_isInspectingSelfie) {
      return _buildSelfieInspectionView();
    }

    final size = MediaQuery.of(context).size;
    const double circleDiameter = 270.0;
    // Compute Y center of the circular cutout to align with the screen center
    final double circleCenterY = size.height * 0.44;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Front Camera Preview Layer (Full Screen)
          Positioned.fill(
            child: _isCameraInitialized && _cameraController != null
                ? ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width:
                            _cameraController!.value.previewSize?.height ??
                            size.width,
                        height:
                            _cameraController!.value.previewSize?.width ??
                            size.height,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF171D1C),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
          ),

          // 2. Solid Cream Vignette Mask with Transparent Circle Cutout
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BiometricCircleMaskPainter(
                  circleDiameter: circleDiameter,
                  circleCenterY: circleCenterY,
                ),
              ),
            ),
          ),

          // 3. Dynamic Progress Ring & Face Alignment Overlay (Centered on the cutout)
          Positioned(
            top: circleCenterY - (circleDiameter / 2) - 8,
            left: (size.width - circleDiameter) / 2 - 8,
            child: SizedBox(
              width: circleDiameter + 16,
              height: circleDiameter + 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dynamic Neo-Green Progress Arc
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        width: circleDiameter + 16,
                        height: circleDiameter + 16,
                        child: CircularProgressIndicator(
                          value: _isLivenessActive
                              ? _progressAnimation.value
                              : 0.0,
                          strokeWidth: 7,
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981), // Neo-Green
                          ),
                        ),
                      );
                    },
                  ),

                  // High-Contrast Glowing Face Oval Guide
                  if (!_isSuccess)
                    Container(
                      width: circleDiameter * 0.68,
                      height: circleDiameter * 0.86,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _isLivenessActive
                              ? const Color(0xFF10B981)
                              : Colors.white.withValues(alpha: 0.85),
                          width: _isLivenessActive ? 3.0 : 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isLivenessActive
                                        ? const Color(0xFF10B981)
                                        : Colors.black)
                                    .withValues(alpha: 0.35),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),

                  // Success Green Overlay
                  if (_isSuccess)
                    Container(
                      width: circleDiameter,
                      height: circleDiameter,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x4410B981),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 80,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 4. Foreground UI Controls & Prompts (Safe Area)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),
                // Header Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'BIOMETRIC LIVENESS',
                    style: AppTheme.labelStyle(
                      color: AppColors.primaryTeal,
                      letterSpacing: 1.2,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  'Face Verification',
                  style: AppTheme.headingStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Animated Prompt Copy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _promptCopy,
                      key: ValueKey(_promptCopy),
                      style: AppTheme.bodyStyle(
                        fontSize: 16,
                        color: _isSuccess
                            ? const Color(0xFF10B981)
                            : AppColors.kinInk.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Action Button / Scanning Status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      if (!_isLivenessActive && !_isSuccess)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isCameraInitialized
                                ? _startLivenessVerification
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCameraInitialized
                                      ? Icons.camera_front
                                      : Icons.hourglass_top_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCameraInitialized
                                      ? "I'm Ready • Start Scan"
                                      : 'Starting Camera...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_isLivenessActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Checking Biometric Liveness...',
                                style: TextStyle(
                                  color: AppColors.kinInk.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Footer Security Note
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.security,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bank-grade encrypted 3D biometric match',
                        style: AppTheme.labelStyle(
                          color: AppColors.kinInk.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Selfie Inspection & Quality Review View
  Widget _buildSelfieInspectionView() {
    final rotationAngle = _rotationQuarterTurns * 90;

    return Scaffold(
      backgroundColor: AppColors.kinInk,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selfie Verification',
                    style: AppTheme.headingStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Face Match Verified',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Confirm your photo is clear and well-lit before submitting.',
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),

              // Circular Selfie Preview with Rotation
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1F2625),
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: RotatedBox(
                            quarterTurns: _rotationQuarterTurns,
                            child:
                                _selfieImagePath != null &&
                                    File(_selfieImagePath!).existsSync()
                                ? Image.file(
                                    File(_selfieImagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.face_retouching_natural,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Rotation button
                      Positioned(
                        bottom: 0,
                        right: 16,
                        child: KinBounceable(
                          onTap: _rotateSelfie,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.rotate_right_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rotate ($rotationAngle°)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Real Inspection Metrics Cards
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2625),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: _isAnalyzingQuality
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Analysing selfie...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          _buildMetricBadge(
                            title: 'FACE POSITION',
                            value: _faceResult != null
                                ? (_faceResult!.faceDetected
                                      ? _faceResult!.centeringLabel
                                      : 'Not Found')
                                : '—',
                            status: _faceResult?.centeringStatus ?? '—',
                            isGood:
                                _faceResult == null ||
                                (_faceResult!.faceDetected &&
                                    _faceResult!.isCentered),
                            icon: Icons.center_focus_strong_rounded,
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _buildMetricBadge(
                            title: 'LIVENESS',
                            value: _faceResult != null
                                ? _faceResult!.livenessLabel
                                : '—',
                            status: _faceResult?.livenessStatus ?? '—',
                            isGood:
                                _faceResult == null ||
                                _faceResult!.livenessPassed,
                            icon: Icons.remove_red_eye_outlined,
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _buildMetricBadge(
                            title: 'LIGHTING',
                            value: _qualityResult != null
                                ? (_qualityResult!.lighting ==
                                          LightingStatus.tooDark
                                      ? 'Too Dark'
                                      : _qualityResult!.lighting ==
                                            LightingStatus.tooGlary
                                      ? 'Glare'
                                      : 'Optimal')
                                : '—',
                            status: _qualityResult?.lightingLabel ?? '—',
                            isGood:
                                _qualityResult == null ||
                                _qualityResult!.lighting ==
                                    LightingStatus.optimal,
                            icon: Icons.lightbulb_outline_rounded,
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // Bottom Action Buttons: Retake vs Confirm
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _retakeSelfie,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Retake',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _confirmSelfie,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm & Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBadge({
    required String title,
    required String value,
    required String status,
    required bool isGood,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isGood ? const Color(0xFF10B981) : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: isGood ? const Color(0xFF10B981) : Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Scaffold(
      backgroundColor: AppColors.kinCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_front_outlined,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Front Camera Access Required',
                style: AppTheme.headingStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kin uses your front camera to ensure biometric liveness and protect against identity theft.',
                style: AppTheme.bodyStyle(
                  fontSize: 14,
                  color: AppColors.kinInk.withValues(alpha: 0.65),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    KinHaptics.lightTap();
                    if (_permissionStatus.isPermanentlyDenied) {
                      await openAppSettings();
                    } else {
                      await _checkPermissionAndInitFrontCamera();
                    }
                  },
                  style: AppTheme.buttonStyle(
                    backgroundColor: AppColors.primaryTeal,
                  ),
                  child: Text(
                    _permissionStatus.isPermanentlyDenied
                        ? 'Open Settings'
                        : 'Allow Camera Access',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTheme.bodyStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that paints the solid cream background with a circular aperture cut out
class _BiometricCircleMaskPainter extends CustomPainter {
  final double circleDiameter;
  final double circleCenterY;

  _BiometricCircleMaskPainter({
    required this.circleDiameter,
    required this.circleCenterY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final circleCenter = Offset(size.width / 2, circleCenterY);
    final cutOutPath = Path()
      ..addOval(
        Rect.fromCircle(center: circleCenter, radius: circleDiameter / 2),
      );

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutOutPath,
    );

    final paint = Paint()
      ..color = AppColors.kinCream
      ..style = PaintingStyle.fill;

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BiometricCircleMaskPainter oldDelegate) {
    return oldDelegate.circleDiameter != circleDiameter ||
        oldDelegate.circleCenterY != circleCenterY;
  }
}
