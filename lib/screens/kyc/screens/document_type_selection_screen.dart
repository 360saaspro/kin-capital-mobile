import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';
import 'document_upload_modal.dart';

/// Step 4: Government ID / Document Selection Screen
/// Replaces the bottom sheet with a dedicated full-page screen matching Step 3's design language.
class DocumentTypeSelectionScreen extends StatefulWidget {
  final Function(DocumentType docType) onNext;

  const DocumentTypeSelectionScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<DocumentTypeSelectionScreen> createState() => _DocumentTypeSelectionScreenState();
}

class _DocumentTypeSelectionScreenState extends State<DocumentTypeSelectionScreen> {
  DocumentType _selectedType = DocumentType.nationalId;

  final List<Map<String, dynamic>> _documentOptions = [
    {
      'type': DocumentType.nationalId,
      'title': 'National ID / TRN Card',
      'subtitle': 'Government issued national identity card or Tax Registration Number',
      'badge': 'Instant OCR',
      'icon': Icons.badge_outlined,
    },
    {
      'type': DocumentType.passport,
      'title': 'Passport',
      'subtitle': 'International passport photo and bio-data page',
      'badge': 'Global Travel',
      'icon': Icons.menu_book_rounded,
    },
    {
      'type': DocumentType.driversLicense,
      'title': "Driver's Licence",
      'subtitle': 'Official government issued driver photo licence',
      'badge': 'Regional ID',
      'icon': Icons.minor_crash_outlined,
    },
  ];

  void _handleNext() {
    KinHaptics.lightTap();
    widget.onNext(_selectedType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kinCream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Select ID Document',
                      style: AppTheme.headingStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kinInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose the official government photo ID you will scan to verify your identity.',
                      style: AppTheme.bodyStyle(
                        fontSize: 14,
                        color: AppColors.kinInk.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'AVAILABLE DOCUMENT TYPES',
                      style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),

                    // Document option cards (Matching Step 3 style)
                    Column(
                      children: _documentOptions.map((opt) {
                        final type = opt['type'] as DocumentType;
                        final isSelected = type == _selectedType;
                        final badge = opt['badge'] as String?;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: KinBounceable(
                            onTap: () {
                              KinHaptics.stateChange();
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryTeal : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryTeal.withValues(alpha: 0.12),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: isSelected
                                        ? AppColors.primaryTeal.withValues(alpha: 0.15)
                                        : Colors.grey[100],
                                    child: Icon(
                                      opt['icon'] as IconData,
                                      color: isSelected ? AppColors.primaryTeal : Colors.grey[600],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                opt['title'] as String,
                                                style: AppTheme.bodyStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColors.kinInk,
                                                ),
                                              ),
                                            ),
                                            if (badge != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primaryTeal.withValues(alpha: 0.1)
                                                      : Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  badge,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? AppColors.primaryTeal : Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          opt['subtitle'] as String,
                                          style: AppTheme.bodyStyle(
                                            fontSize: 12,
                                            color: AppColors.kinInk.withValues(alpha: 0.55),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryTeal : Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Security & RegTech callout
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, color: AppColors.primaryTeal, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Documents are scanned locally on your device and encrypted with AES-256 for compliance.',
                              style: AppTheme.bodyStyle(
                                fontSize: 12,
                                color: AppColors.kinInk.withValues(alpha: 0.6),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Anchored "Continue to Scan" Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: KinBounceable(
                onTap: _handleNext,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Continue to Camera Scan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}
