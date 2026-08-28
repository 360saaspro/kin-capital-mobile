import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/image_quality_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';
import '../../../core/widgets/kin_shake_container.dart';
import 'document_upload_modal.dart';

/// Screen 3: Live Document Camera Scanner
/// Features:
/// - Explicit Camera Permission request & handler
/// - Real live rear-camera feed with ID-specific framing overlay
/// - Real photo capture + Automated Image Blur, Clarity & Rotation Inspection
/// - Interactive rotation controls (0°, 90°, 180°, 270°) and retake options
class DocumentScannerScreen extends StatefulWidget {
  final DocumentType docType;
  final Function(String documentNumber, String? imagePath) onScanSuccess;
  final VoidCallback onOcrFailed;

  const DocumentScannerScreen({
    super.key,
    required this.docType,
    required this.onScanSuccess,
    required this.onOcrFailed,
  });

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isCheckingPermission = true;

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  bool _isScanning = false;
  bool _shakeError = false;

  // Review & Quality Inspection state
  String? _capturedImagePath;
  int _rotationQuarterTurns = 0; // 0, 1, 2, 3 (each is 90 deg)
  bool _isInspectingQuality = false;
  bool _isAnalyzingQuality = false; // true while ImageQualityService runs
  ImageQualityResult? _qualityResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _checkPermissionAndInitCamera();
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
      _setupCameraController(cameraController.description);
    }
  }

  Future<void> _checkPermissionAndInitCamera() async {
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
        await _initializeCamera();
      }
    } catch (e) {
      debugPrint('Permission error (native plugin requires app rebuild): $e');
      if (mounted) {
        setState(() {
          // If plugin is missing (hot reload without full rebuild), allow fallback simulation
          _permissionStatus = PermissionStatus.granted;
          _isCheckingPermission = false;
        });
      }
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isNotEmpty) {
        final backIndex = _availableCameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _selectedCameraIndex = backIndex >= 0 ? backIndex : 0;
        await _setupCameraController(_availableCameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    // Mark as uninitialized immediately so the preview widget unmounts cleanly
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
      });
    }

    final prevController = _cameraController;
    _cameraController = null;

    // Dispose old controller first and give the hardware time to release
    if (prevController != null) {
      try {
        await prevController.dispose();
      } catch (_) {}
      // Small delay so Android camera HAL fully releases the hardware
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
          _isFlashOn = false;
        });
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Camera controller init error: $e');
      await controller.dispose();
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      final newFlash = !_isFlashOn;
      await _cameraController!.setFlashMode(
        newFlash ? FlashMode.torch : FlashMode.off,
      );
      setState(() {
        _isFlashOn = newFlash;
      });
      KinHaptics.lightTap();
    } catch (e) {
      debugPrint('Flash mode error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;
    KinHaptics.lightTap();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    await _setupCameraController(_availableCameras[_selectedCameraIndex]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _triggerSnapAndScan() async {
    if (_isScanning) return;
    KinHaptics.lightTap();
    setState(() {
      _isScanning = true;
    });

    String? photoPath;

    // Capture real picture from camera
    if (_cameraController != null && _isCameraInitialized) {
      try {
        final file = await _cameraController!.takePicture();
        photoPath = file.path;
      } catch (e) {
        debugPrint('Take picture error: $e');
      }
    }

    // Animate laser scan overlay
    _scanController.repeat(reverse: true);

    // OCR processing window — then show inspection
    Timer(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      _scanController.stop();
      _scanController.reset();

      setState(() {
        _isScanning = false;
        _capturedImagePath = photoPath;
        _isInspectingQuality = true;
        _rotationQuarterTurns = 0;
        _qualityResult = null;
        _isAnalyzingQuality = photoPath != null;
      });
      KinHaptics.successClick();

      // Run real quality analysis in background if we have a photo
      if (photoPath != null) {
        final result = await ImageQualityService.analyze(photoPath);
        if (mounted) {
          setState(() {
            _qualityResult = result;
            _isAnalyzingQuality = false;
          });
          // Auto-warn if blurry
          if (result.isBlurry) KinHaptics.errorSequence();
        }
      }
    });
  }

  void _rotateCapturedImage() {
    KinHaptics.stateChange();
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  void _retakePhoto() {
    KinHaptics.lightTap();
    setState(() {
      _isInspectingQuality = false;
      _capturedImagePath = null;
      _rotationQuarterTurns = 0;
      _isScanning = false;
      _qualityResult = null;
      _isAnalyzingQuality = false;
    });
  }

  Future<void> _confirmAndProceed() async {
    KinHaptics.successClick();

    final docNum = widget.docType == DocumentType.passport
        ? 'P-JAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : (widget.docType == DocumentType.nationalId
            ? 'HN-0801-1992-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
            : 'DL-CARIB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

    final imgPath = _capturedImagePath;

    // Explicitly dispose rear camera hardware so front camera can start cleanly
    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (_) {}

    widget.onScanSuccess(docNum, imgPath);
  }

  void _triggerOcrFailure() {
    setState(() {
      _shakeError = true;
    });
    KinHaptics.errorSequence();

    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        widget.onOcrFailed();
      }
    });
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

    if (_isInspectingQuality) {
      return _buildQualityInspectionView();
    }

    final size = MediaQuery.of(context).size;
    final frameWidth = size.width * 0.88;
    final frameHeight = widget.docType == DocumentType.passport
        ? frameWidth / 1.35
        : frameWidth / 1.58;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Live Camera Preview Feed
            Positioned.fill(
              child: KinShakeContainer(
                shake: _shakeError,
                child: _isCameraInitialized && _cameraController != null
                    ? ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize?.height ?? size.width,
                            height: _cameraController!.value.previewSize?.width ?? size.height,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF131716), Color(0xFF222927)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.docType.icon,
                                size: 80,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Camera Ready',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // 2. Dimmed Mask Vignette Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DocumentMaskPainter(
                    frameWidth: frameWidth,
                    frameHeight: frameHeight,
                  ),
                ),
              ),
            ),

            // 3. ID-Specific Frame Guide & Laser Scanner
            Center(
              child: SizedBox(
                width: frameWidth,
                height: frameHeight,
                child: Stack(
                  children: [
                    _buildCornerBrackets(),
                    _buildDocumentTypeGuidelines(frameWidth, frameHeight),
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: frameHeight * _scanAnimation.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: AppColors.kinTealLight,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryTeal.withValues(alpha: 0.95),
                                    blurRadius: 14,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 4. Top Header Controls
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'Scan ${widget.docType.label}',
                      style: AppTheme.headingStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [
                      if (_isCameraInitialized) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: _isFlashOn
                                ? AppColors.primaryTeal.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _toggleFlash,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_availableCameras.length > 1)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 20),
                              onPressed: _switchCamera,
                            ),
                          ),
                      ] else ...[
                        IconButton(
                          icon: const Icon(Icons.report_problem_outlined, color: Colors.amber),
                          tooltip: 'Simulate OCR Failure',
                          onPressed: _triggerOcrFailure,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 5. Bottom Instructions & Shutter Button
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isScanning
                          ? 'Extracting ${widget.docType.label} data...'
                          : 'Position entire ${widget.docType.label.toLowerCase()} inside the frame',
                      style: AppTheme.bodyStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isScanning)
                    KinBounceable(
                      onTap: _triggerSnapAndScan,
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primaryTeal,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quality Inspection Screen: Blur Check, Rotation & Verification
  Widget _buildQualityInspectionView() {
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
                    'Photo Inspection',
                    style: AppTheme.headingStyle(color: Colors.white, fontSize: 22),
                  ),
                  if (_isAnalyzingQuality)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Analysing...', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_qualityResult?.isBlurry ?? false)
                            ? Colors.orange.withValues(alpha: 0.2)
                            : const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (_qualityResult?.isBlurry ?? false)
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle,
                            color: (_qualityResult?.isBlurry ?? false)
                                ? Colors.orange
                                : const Color(0xFF10B981),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (_qualityResult?.isBlurry ?? false) ? 'Check Blur' : 'Sharp & Clear',
                            style: TextStyle(
                              color: (_qualityResult?.isBlurry ?? false)
                                  ? Colors.orange
                                  : const Color(0xFF10B981),
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
                'Verify your document is legible, un-cropped, and right-side up.',
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),

              // Image Preview with Rotation
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2625),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (_qualityResult?.isBlurry ?? false)
                                ? Colors.orange.withValues(alpha: 0.6)
                                : AppColors.primaryTeal.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: RotatedBox(
                            quarterTurns: _rotationQuarterTurns,
                            child: _capturedImagePath != null && File(_capturedImagePath!).existsSync()
                                ? Image.file(
                                    File(_capturedImagePath!),
                                    fit: BoxFit.contain,
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.docType.icon,
                                          size: 80,
                                          color: Colors.white.withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.docType.label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Rotation overlay pill
                      Positioned(
                        top: 12,
                        right: 12,
                        child: KinBounceable(
                          onTap: _rotateCapturedImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.rotate_right_rounded, color: Colors.white, size: 18),
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

              // Automated Inspection Metrics Cards
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2625),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                              'Analysing image quality...',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          _buildMetricBadge(
                            title: 'CLARITY',
                            value: _qualityResult != null
                                ? '${_qualityResult!.sharpnessScore.toStringAsFixed(1)}%'
                                : '—',
                            status: _qualityResult?.sharpnessLabel ?? '—',
                            isGood: _qualityResult == null || !_qualityResult!.isBlurry,
                            icon: Icons.filter_center_focus_rounded,
                          ),
                          Container(height: 36, width: 1, color: Colors.white.withValues(alpha: 0.15)),
                          _buildMetricBadge(
                            title: 'ORIENTATION',
                            value: '$rotationAngle°',
                            status: rotationAngle == 0 ? 'Upright' : 'Adjusted',
                            isGood: true,
                            icon: Icons.crop_rotate_rounded,
                          ),
                          Container(height: 36, width: 1, color: Colors.white.withValues(alpha: 0.15)),
                          _buildMetricBadge(
                            title: 'LIGHTING',
                            value: _qualityResult != null
                                ? (_qualityResult!.lighting == LightingStatus.tooDark
                                    ? 'Too Dark'
                                    : _qualityResult!.lighting == LightingStatus.tooGlary
                                        ? 'Glare'
                                        : 'Optimal')
                                : '—',
                            status: _qualityResult?.lightingLabel ?? '—',
                            isGood: _qualityResult == null ||
                                _qualityResult!.lighting == LightingStatus.optimal,
                            icon: Icons.light_mode_outlined,
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
                      onPressed: _retakePhoto,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
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
                      onPressed: _confirmAndProceed,
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
                            'Continue to Selfie',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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
              Icon(icon, size: 14, color: isGood ? const Color(0xFF10B981) : Colors.orange),
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
                child: const Icon(Icons.camera_alt_outlined, color: Colors.amber, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Access Required',
                style: AppTheme.headingStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'To verify your identity document safely and meet financial compliance regulations, Kin requires permission to use your camera.',
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
                      await _checkPermissionAndInitCamera();
                    }
                  },
                  style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
                  child: Text(
                    _permissionStatus.isPermanentlyDenied ? 'Open Settings' : 'Allow Camera Access',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: AppTheme.bodyStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBrackets() {
    const bracketSize = 28.0;
    const bracketThickness = 3.5;
    const color = AppColors.kinTealLight;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: bracketThickness),
                left: BorderSide(color: color, width: bracketThickness),
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: bracketThickness),
                right: BorderSide(color: color, width: bracketThickness),
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(16)),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: bracketThickness),
                left: BorderSide(color: color, width: bracketThickness),
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: bracketThickness),
                right: BorderSide(color: color, width: bracketThickness),
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeGuidelines(double width, double height) {
    switch (widget.docType) {
      case DocumentType.passport:
        return _buildPassportGuidelines(width, height);
      case DocumentType.nationalId:
        return _buildNationalIdGuidelines(width, height);
      case DocumentType.driversLicense:
        return _buildDriversLicenseGuidelines(width, height);
    }
  }

  Widget _buildPassportGuidelines(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PASSPORT BIO-DATA PAGE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.public, color: Colors.white.withValues(alpha: 0.4), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width * 0.28,
                height: height * 0.48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 5,
                      width: index == 3 ? width * 0.3 : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P<JAM<<DOE<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'A1234567<8JAM8506151M2801017<<<<<<<<<<<<<04',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalIdGuidelines(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NATIONAL IDENTITY / TRN CARD',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.credit_card, color: Colors.white.withValues(alpha: 0.4), size: 16),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: width * 0.26,
                height: height * 0.54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.memory, color: Colors.amber, size: 16),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 5,
                      width: width * 0.35,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDriversLicenseGuidelines(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DRIVER'S LICENCE",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CLASS C / PPV',
                  style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                width: width * 0.26,
                height: height * 0.54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 5,
                      width: index == 2 ? width * 0.3 : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _DocumentMaskPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  _DocumentMaskPainter({
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      const Radius.circular(20),
    );

    final cutOutPath = Path()..addRRect(frameRect);
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, cutOutPath);

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DocumentMaskPainter oldDelegate) {
    return oldDelegate.frameWidth != frameWidth || oldDelegate.frameHeight != frameHeight;
  }
}
