import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';

class AdminKycDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminKycDetailScreen({super.key, required this.user});

  @override
  State<AdminKycDetailScreen> createState() => _AdminKycDetailScreenState();
}

class _AdminKycDetailScreenState extends State<AdminKycDetailScreen> {
  late Map<String, dynamic> _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user);
  }

  Future<void> _onApprove() async {
    final uid = _user['id'] as String? ?? _user['uid'] as String? ?? '';
    if (uid.isEmpty) return;

    setState(() => _isLoading = true);
    await FirestoreService.instance.updateUserKycStatus(uid, 'verified',
        checks: ['Identity PASSED', 'Sanctions PASSED'],
        reviewedBy: 'admin');
    
    setState(() {
      _user['kycStatus'] = 'verified';
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_user['fullName']} KYC approved'),
      backgroundColor: AppColors.kinTeal,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
  }

  Future<void> _onFlag() async {
    final uid = _user['id'] as String? ?? _user['uid'] as String? ?? '';
    if (uid.isEmpty) return;

    final reason = await _showReasonDialog();
    if (reason == null) return; // cancelled

    setState(() => _isLoading = true);
    await FirestoreService.instance.updateUserKycStatus(uid, 'flagged',
        reason: reason,
        checks: ['Identity REVIEW', 'Sanctions REVIEW'],
        reviewedBy: 'admin');

    setState(() {
      _user['kycStatus'] = 'flagged';
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_user['fullName']} flagged for review'),
      backgroundColor: AppColors.kinCoral,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
  }

  Future<String?> _showReasonDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Flag Reason', style: AppTheme.headingStyle(fontSize: 18)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Enter reason for flagging...',
            hintStyle: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey[400]!),
            filled: true, fillColor: AppColors.kinMist,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kinCoral, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _user['fullName'] as String? ?? 'Unknown User';
    final email = _user['email'] as String? ?? 'No Email';
    final status = _user['kycStatus'] as String? ?? 'pending';
    final isHistory = status == 'verified' || status == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('KYC Review Details', style: AppTheme.headingStyle(fontSize: 18)),
        iconTheme: const IconThemeData(color: AppColors.kinInk),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.kinTeal))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(name, email, status),
                const SizedBox(height: 24),
                if (!isHistory) _buildActionButtons(),
                if (!isHistory) const SizedBox(height: 24),
                _buildSection('Submitted Documents', [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDocumentImage(
                          label: 'Identity Document',
                          imageUrl: _user['identityImagePath'] as String? ?? _user['identity_image_path'] as String?,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDocumentImage(
                          label: 'ID Back (Optional)',
                          imageUrl: _user['identityBackImagePath'] as String?,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentImage(
                    label: 'Selfie / Biometric Liveness',
                    imageUrl: _user['selfieImagePath'] as String? ?? _user['selfie_image_path'] as String?,
                    isWide: true,
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection('Extracted Data', [
                  _infoRow('Full Name', name),
                  _infoRow('ID Type', _user['identityType'] ?? '—'),
                  _infoRow('ID Number', _user['identityNumber'] ?? '—'),
                  _infoRow('Nationality', _user['nationality'] ?? '—'),
                  _infoRow('Date of Birth', _user['dateOfBirth'] ?? '—'),
                  _infoRow('Address', '${_user['street'] ?? ''} ${_user['city'] ?? ''} ${_user['country'] ?? ''}'.trim()),
                ]),
                const SizedBox(height: 20),
                if (_user['kycDecisionNote'] != null || _user['kycFlagReason'] != null)
                  _buildSection('Review Notes', [
                    Text(_user['kycDecisionNote'] ?? _user['kycFlagReason'] ?? '', style: AppTheme.bodyStyle(fontSize: 14)),
                  ]),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(String name, String email, String status) {
    Color statusColor;
    if (status == 'verified') {
      statusColor = AppColors.kinTeal;
    } else if (status == 'flagged' || status == 'rejected') {
      statusColor = AppColors.kinCoral;
    } else {
      statusColor = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.assignment_ind_rounded, size: 40, color: statusColor),
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTheme.headingStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(email, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey[500]!)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: AppTheme.bodyStyle(
                fontSize: 12, 
                color: statusColor,
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _onFlag,
            icon: const Icon(Icons.flag_rounded, size: 18),
            label: const Text('Flag for Review'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.kinCoral,
              side: const BorderSide(color: AppColors.kinCoral),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _onApprove,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approve KYC'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kinTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePreviewDialog(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF181B1A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 640,
            maxHeight: 700,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (imageUrl.startsWith('http'))
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 20),
                        tooltip: 'Open in new tab',
                        onPressed: () {
                          launchUrl(Uri.parse(imageUrl), mode: LaunchMode.externalApplication);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Flexible(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 260, maxHeight: 540),
                  color: Colors.black,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: AppColors.kinTeal),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.broken_image_rounded, size: 48, color: Colors.white38),
                                    const SizedBox(height: 12),
                                    const Text('Unable to display preview directly', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: () {
                                        launchUrl(Uri.parse(imageUrl), mode: LaunchMode.externalApplication);
                                      },
                                      icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.kinTeal),
                                      label: const Text('Open Direct Link', style: TextStyle(color: AppColors.kinTeal)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Image.file(
                            File(imageUrl),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.white38),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentImage({
    required String label,
    String? imageUrl,
    bool isWide = false,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final isRemote = hasImage && imageUrl.startsWith('http');
    final isLocal = hasImage && !isRemote && File(imageUrl).existsSync();

    if (!hasImage || (!isRemote && !isLocal)) {
      return _mockDocument(label, isWide: isWide);
    }

    return GestureDetector(
      onTap: () => _showImagePreviewDialog(imageUrl, label),
      child: Container(
        height: isWide ? 160 : 120,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isRemote)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                      color: AppColors.kinTeal,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _mockDocument(label, isWide: isWide),
              )
            else
              Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _mockDocument(label, isWide: isWide),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mockDocument(String label, {bool isWide = false}) {
    return Container(
      height: isWide ? 120 : 100,
      decoration: BoxDecoration(
        color: AppColors.kinMist,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isWide ? Icons.face_retouching_natural : Icons.credit_card, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTheme.headingStyle(fontSize: 16, color: Colors.grey[800]!)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    if (value == '—' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[500]!)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.kinInk)),
          ),
        ],
      ),
    );
  }
}
