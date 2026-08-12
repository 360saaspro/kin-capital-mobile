import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'send_amount_screen.dart';

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'K';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _showAddRecipientSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add New Recipient', style: AppTheme.headingStyle(fontSize: 20)),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: 'Phone or Account Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isNotEmpty) {
                    final uid = AuthService.instance.currentUid;
                    await FirestoreService.instance.addRecipient(uid, {
                      'name': name,
                      'phone': phone.isNotEmpty ? phone : '+1 (876) 555-0199',
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recipient saved to Firestore!'), backgroundColor: AppColors.primaryTeal),
                      );
                    }
                  }
                },
                style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
                child: const Text('Save Recipient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryTeal,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Good morning',
                            style: AppTheme.headingStyle(
                              fontSize: 18,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.notifications_outlined, color: AppColors.primaryTeal),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Who are we sending\nto?',
                    style: AppTheme.headingStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search name or @handle',
                        hintStyle: AppTheme.bodyStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Frequent Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Frequent', style: AppTheme.headingStyle(fontSize: 18)),
                          Text(
                            'SEE ALL',
                            style: AppTheme.bodyStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24),
                        children: [
                          _buildFrequentItem(context, 'Mom', 'https://i.pravatar.cc/150?u=mom'),
                          _buildFrequentItem(context, 'Sis', 'https://i.pravatar.cc/150?u=sis'),
                          _buildFrequentItem(context, 'Tunde', 'https://i.pravatar.cc/150?u=tunde'),
                          _buildFrequentItem(context, 'Marcus', 'https://i.pravatar.cc/150?u=marcus'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // All Contacts & Firestore Stream
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('All contacts', style: AppTheme.headingStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),

                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: FirestoreService.instance.streamUserRecipients(AuthService.instance.currentUid),
                      builder: (context, snapshot) {
                        final firestoreRecipients = snapshot.data ?? [];
                        final all = [
                          {'name': 'Andre Anderson', 'detail': '@dre_anderson'},
                          {'name': 'Brianna Brown', 'detail': '+1 (876) 555-0123'},
                          {'name': 'Chris Campbell', 'detail': '+1 (876) 444-9876'},
                          ...firestoreRecipients.map((r) => {'name': r['name'] ?? '', 'detail': r['phone'] ?? ''}),
                        ].where((c) {
                          if (_searchQuery.isEmpty) return true;
                          final n = (c['name'] ?? '').toLowerCase();
                          return n.contains(_searchQuery);
                        }).toList();

                        return Column(
                          children: all.map((c) {
                            return _buildContactItem(context, c['name']!, c['detail']!, null);
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 85),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton(
          onPressed: () => _showAddRecipientSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 8,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('NEW RECIPIENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequentItem(BuildContext context, String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendAmountScreen(
              recipientName: name,
              avatarUrl: imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryTeal, width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: AppTheme.bodyStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String name, String detail, String? imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendAmountScreen(
              recipientName: name,
              avatarUrl: imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(name),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    Text(detail, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
