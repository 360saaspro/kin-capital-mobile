import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';

enum DocumentType {
  passport,
  nationalId,
  driversLicense,
}

extension DocumentTypeX on DocumentType {
  String get apiKey {
    switch (this) {
      case DocumentType.passport:
        return 'passport';
      case DocumentType.nationalId:
        return 'national_id';
      case DocumentType.driversLicense:
        return 'drivers_license';
    }
  }

  String get label {
    switch (this) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.nationalId:
        return 'National ID';
      case DocumentType.driversLicense:
        return "Driver's License";
    }
  }

  String get description {
    switch (this) {
      case DocumentType.passport:
        return 'International passport bio page';
      case DocumentType.nationalId:
        return 'Government issued national identity card / TRN';
      case DocumentType.driversLicense:
        return 'Official driver license photo ID';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.passport:
        return Icons.menu_book_rounded;
      case DocumentType.nationalId:
        return Icons.badge_outlined;
      case DocumentType.driversLicense:
        return Icons.minor_crash_outlined;
    }
  }
}

/// Screen 3: RegTech Document Upload (Bottom-Sheet Modal)
/// Pristine white bottom-sheet displaying large friendly options for Passport, National ID, Driver's License.
class DocumentUploadModal extends StatelessWidget {
  final Function(DocumentType docType) onSelect;

  const DocumentUploadModal({
    super.key,
    required this.onSelect,
  });

  static Future<DocumentType?> show(BuildContext context) {
    return showModalBottomSheet<DocumentType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DocumentUploadModal(
        onSelect: (docType) {
          Navigator.pop(context, docType);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Pull Indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Copy
            Text(
              'Verify Your Identity',
              style: AppTheme.headingStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose an official government document to scan.',
              style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.6), fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Options list
            _buildOption(context, DocumentType.nationalId),
            const SizedBox(height: 12),
            _buildOption(context, DocumentType.passport),
            const SizedBox(height: 12),
            _buildOption(context, DocumentType.driversLicense),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, DocumentType docType) {
    return KinBounceable(
      onTap: () {
        KinHaptics.stateChange();
        onSelect(docType);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kinMistLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
              child: Icon(docType.icon, color: AppColors.primaryTeal, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docType.label,
                    style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    docType.description,
                    style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryTeal, size: 16),
          ],
        ),
      ),
    );
  }
}
