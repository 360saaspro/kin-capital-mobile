import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';
import '../../../core/widgets/kin_shake_container.dart';
import 'document_upload_modal.dart';

/// Screen 3 Camera Scanner View:
/// Custom camera view with overlay mask (rounded rectangle guiding document alignment).
/// Once snapped, a teal (#006A61) scanning line sweeps up and down the document preview.
class DocumentScannerScreen extends StatefulWidget {
  final DocumentType docType;
  final Function(String documentNumber) onScanSuccess;
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
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  bool _isScanning = false;
  bool _shakeError = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _triggerSnapAndScan() {
    KinHaptics.lightTap();
    setState(() {
      _isScanning = true;
    });

    _scanController.repeat(reverse: true);

    // Simulate 2.2 second scan duration for data extraction animation
    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _scanController.stop();

      // Return synthetic identity document number based on document type
      final docNum = widget.docType == DocumentType.passport
          ? 'P-JAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : (widget.docType == DocumentType.nationalId
              ? 'HN-0801-1992-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
              : 'DL-CARIB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

      KinHaptics.successClick();
      widget.onScanSuccess(docNum);
    });
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera View Finder & Mask Background
            KinShakeContainer(
              shake: _shakeError,
              child: Stack(
                children: [
                  // Simulated Camera Feed (Dark Gradient Background)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF171D1C), Color(0xFF2B3230)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.docType.icon,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),

                  // Rounded Rectangle Document Guide Frame
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.width * 0.56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isScanning
                              ? AppColors.primaryTeal
                              : Colors.white.withValues(alpha: 0.8),
                          width: 3,
                        ),
                        boxShadow: _isScanning
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          // Sweeping Teal Scanning Laser Line (#006A61 / #0FA89A)
                          if (_isScanning)
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: (MediaQuery.of(context).size.width * 0.56) *
                                      _scanAnimation.value,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppColors.kinTealLight,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryTeal.withValues(alpha: 0.9),
                                          blurRadius: 12,
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
                ],
              ),
            ),

            // Top Header Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Scan ${widget.docType.label}',
                    style: AppTheme.headingStyle(color: Colors.white, fontSize: 18),
                  ),
                  // Test OCR Failure toggle button
                  IconButton(
                    icon: const Icon(Icons.report_problem_outlined, color: Colors.amber),
                    tooltip: 'Simulate OCR Error',
                    onPressed: _triggerOcrFailure,
                  ),
                ],
              ),
            ),

            // Bottom Instructions & Shutter Button
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    _isScanning
                        ? 'Extracting document data...'
                        : 'Align your ${widget.docType.label.toLowerCase()} inside the frame',
                    style: AppTheme.bodyStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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
}
