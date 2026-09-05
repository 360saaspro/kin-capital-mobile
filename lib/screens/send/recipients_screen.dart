import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'send_amount_screen.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../home/notifications_screen.dart';

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Contact> _deviceContacts = [];
  bool _hasPermission = false;
  bool _isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts = await FlutterContacts.getAll(properties: {ContactProperty.phone});
        if (mounted) {
          setState(() {
            _deviceContacts = contacts;
            _hasPermission = true;
            _isLoadingContacts = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isLoadingContacts = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoadingContacts = false;
        });
      }
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

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
    final accountCtrl = TextEditingController();
    final transitCtrl = TextEditingController();

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
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: accountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Bank Account Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: transitCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Transit/Bank Code',
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
                  final account = accountCtrl.text.trim();
                  final transit = transitCtrl.text.trim();
                  if (name.isNotEmpty && account.isNotEmpty && transit.isNotEmpty) {
                    final uid = AuthService.instance.currentUid;
                    await FirestoreService.instance.addRecipient(uid, {
                      'name': name,
                      'phone': phone,
                      'accountNumber': account,
                      'transitBankCode': transit,
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
                          StreamBuilder<Map<String, dynamic>?>(
                            stream: FirestoreService.instance.streamUserProfile(AuthService.instance.currentUid),
                            builder: (context, snapshot) {
                              final profile = snapshot.data ?? FirestoreService.instance.getCachedUser(AuthService.instance.currentUid);
                              final rawPhotoUrl = AuthService.instance.fallbackPhotoUrl ?? profile?['photoURL'] ?? AuthService.instance.currentUser?.photoURL;
                              
                              return CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryTeal,
                                backgroundImage: rawPhotoUrl != null 
                                    ? (rawPhotoUrl.toString().startsWith('data:image')
                                        ? MemoryImage(base64Decode(rawPhotoUrl.toString().split(',').last)) as ImageProvider
                                        : NetworkImage(rawPhotoUrl))
                                    : null,
                                child: rawPhotoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                              );
                            }
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Good ${_greeting()}',
                            style: AppTheme.headingStyle(
                              fontSize: 18,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: FirestoreService.instance.streamUserNotifications(AuthService.instance.currentUid),
                        builder: (context, snapshot) {
                          final notifications = snapshot.data ?? FirestoreService.instance.getCachedNotifications(AuthService.instance.currentUid);
                          final activeNotifications = notifications.where((n) {
                            final type = n['type']?.toString().toLowerCase();
                            final isRead = n['isRead'] == true;
                            return !isRead && (type == 'notification' || type == 'offer');
                          }).toList();

                          if (activeNotifications.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return IconButton(
                            icon: const Icon(Icons.notifications_active, color: AppColors.primaryTeal, size: 28),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                          );
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Who are we sending to?',
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
                      child: Text('Frequent', style: AppTheme.headingStyle(fontSize: 18)),
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
                        
                        final deviceContactsMapped = _deviceContacts.map((c) {
                          String phoneStr = 'No phone number';
                          if (c.phones.isNotEmpty) {
                            final firstNum = c.phones.first.number.trim();
                            if (firstNum.isNotEmpty) {
                              phoneStr = firstNum;
                            }
                          }
                          String nameStr = c.displayName?.trim() ?? '';
                          if (nameStr.isEmpty) {
                            nameStr = phoneStr != 'No phone number' ? phoneStr : 'Unknown Contact';
                          }
                          return {
                            'name': nameStr,
                            'detail': phoneStr,
                            'accountNumber': null,
                            'transitBankCode': null,
                          };
                        });

                        final all = [
                          ...firestoreRecipients.map((r) {
                            final nameStr = (r['name']?.toString().trim().isNotEmpty == true)
                                ? r['name'].toString().trim()
                                : 'Unknown';
                            final detailStr = r['accountNumber']?.toString() ??
                                r['phone']?.toString() ??
                                '';
                            return {
                              'name': nameStr,
                              'detail': detailStr,
                              'accountNumber': r['accountNumber'],
                              'transitBankCode': r['transitBankCode'],
                            };
                          }),
                          ...deviceContactsMapped,
                        ].where((c) {
                          if (_searchQuery.isEmpty) return true;
                          final n = (c['name'] ?? '').toLowerCase();
                          final d = (c['detail'] ?? '').toLowerCase();
                          return n.contains(_searchQuery) || d.contains(_searchQuery);
                        }).toList();

                        if (_isLoadingContacts && all.isEmpty) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: AppColors.primaryTeal),
                          ));
                        }

                        if (!_hasPermission && firestoreRecipients.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Text('Contacts permission denied', style: AppTheme.headingStyle(fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text('Enable contacts permission in settings or add recipients manually.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          );
                        }

                        if (all.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text('No contacts found.', style: TextStyle(color: Colors.grey[600])),
                            ),
                          );
                        }

                        return Column(
                          children: all.map((c) {
                            final name = (c['name']?.toString().trim().isNotEmpty == true)
                                ? c['name'].toString().trim()
                                : 'Unknown';
                            final detail = c['detail']?.toString() ?? '';
                            return _buildContactItem(
                              context,
                              name,
                              detail,
                              null,
                              c['accountNumber'],
                              c['transitBankCode'],
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 105),
        child: ElevatedButton.icon(
          onPressed: () => _showAddRecipientSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoral,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 6,
            shadowColor: AppColors.primaryCoral.withValues(alpha: 0.35),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'New Recipient',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
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

  Widget _buildContactItem(BuildContext context, String name, String detail, String? imageUrl, [dynamic accountNumber, dynamic transitBankCode]) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendAmountScreen(
              recipientName: name,
              avatarUrl: imageUrl,
              accountNumber: accountNumber?.toString(),
              transitBankCode: transitBankCode?.toString(),
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
