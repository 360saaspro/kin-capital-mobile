import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../main_screen.dart';
import 'screens/splash_verification_screen.dart';
import 'screens/friendly_data_capture_screen.dart';
import 'screens/address_capture_screen.dart';
import 'screens/employment_status_screen.dart';
import 'screens/document_upload_modal.dart';
import 'screens/document_scanner_screen.dart';
import 'screens/agentic_processing_screen.dart';
import 'screens/human_escalation_screen.dart';
import 'widgets/kyc_progress_bar.dart';
import 'widgets/ocr_retry_sheet.dart';

/// Master Coordinator for the Kin Capital Rails Onboarding & KYC Flow.
/// Manages 5-step progression:
///   Step 1: Personal Details & Contact (validation, email, Caribbean dial code, calendar DOB picker)
///   Step 2: Address & Residence Duration (address autofill suggestions, duration selector)
///   Step 3: Employment & Financial Profile (employment status, industry, monthly cash flow)
///   Step 4: RegTech Document Upload & Camera Scanner
///   Step 5: Agentic Brain Processing Screen (/kyc-submit, /orchestrate & green checkmark bloom)
class KycFlowScreen extends StatefulWidget {
  const KycFlowScreen({super.key});

  @override
  State<KycFlowScreen> createState() => _KycFlowScreenState();
}

class _KycFlowScreenState extends State<KycFlowScreen> {
  int _currentStep = 0; // 0: Splash, 1: Step 1, 2: Step 2, 3: Step 3, 4: Step 4 (Scanner), 5: Step 5 (Agentic), 6: Human Escalation
  final Map<String, String> _kycData = {};

  // Step 0 Complete: Splash -> Move to Step 1
  void _onSplashVerified() {
    setState(() {
      _currentStep = 1;
    });
  }

  // Step 1 Complete: Personal Details -> Move to Step 2 (Address)
  void _onStep1Captured(Map<String, String> data) {
    _kycData.addAll(data);
    setState(() {
      _currentStep = 2;
    });
  }

  // Step 2 Complete: Address Captured -> Move to Step 3 (Employment)
  void _onStep2Captured(Map<String, String> addressData) {
    _kycData.addAll(addressData);
    setState(() {
      _currentStep = 3;
    });
  }

  // Step 3 Complete: Employment Captured -> Trigger Step 4 Document Upload
  void _onStep3Captured(Map<String, String> employmentData) async {
    _kycData.addAll(employmentData);

    // Open Step 4 Document Selector Bottom Sheet
    final selectedType = await DocumentUploadModal.show(context);
    if (selectedType != null) {
      _kycData['identity_type'] = selectedType.apiKey;

      if (!mounted) return;
      // Open Document Scanner Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentScannerScreen(
            docType: selectedType,
            onScanSuccess: (docNum) {
              _kycData['identity_number'] = docNum;
              Navigator.pop(context); // Close scanner
              setState(() {
                _currentStep = 5; // Move directly to Step 5 (Agentic Processing)
              });
            },
            onOcrFailed: () {
              Navigator.pop(context); // Close scanner
              _showOcrRetrySheet();
            },
          ),
        ),
      );
    }
  }

  void _showOcrRetrySheet() {
    OcrRetrySheet.show(context, onRetake: () {
      _onStep3Captured({});
    });
  }

  // Step 5 Passed: Scale & Fade Transition into Home Screen
  void _onKycPassed() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          );
        },
      ),
      (route) => false,
    );
  }

  // Sanctions / AML Flag: Move to Human Escalation Screen
  void _onKycFlagged() {
    setState(() {
      _currentStep = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash verification if step 0
    if (_currentStep == 0) {
      return SplashVerificationScreen(onVerificationComplete: _onSplashVerified);
    }

    // Show Human Escalation if step 6
    if (_currentStep == 6) {
      return HumanEscalationScreen(
        entityId: _kycData['entity_id'] ?? 'user_001',
        onReturnHome: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        },
      );
    }

    // Determine current active step (1 to 5) for progress bar
    final progressStep = _currentStep.clamp(1, 5);

    return Scaffold(
      backgroundColor: AppColors.kinCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Filling Progress Bar
            KycProgressBar(currentStep: progressStep, totalSteps: 5),

            // Active Step Content
            Expanded(
              child: IndexedStack(
                index: progressStep - 1,
                children: [
                  FriendlyDataCaptureScreen(onNext: _onStep1Captured),
                  AddressCaptureScreen(onNext: _onStep2Captured),
                  EmploymentStatusScreen(onNext: _onStep3Captured),
                  // Step 4 Document Upload is launched via Modal Bottom Sheet
                  EmploymentStatusScreen(onNext: _onStep3Captured),
                  AgenticProcessingScreen(
                    userData: _kycData,
                    onPass: _onKycPassed,
                    onFlagged: _onKycFlagged,
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
