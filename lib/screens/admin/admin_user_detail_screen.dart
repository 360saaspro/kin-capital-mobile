import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import 'admin_transaction_detail_screen.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late Map<String, dynamic> _user;
  bool _isLoading = false;

  // Transactions state
  StreamSubscription? _txSub;
  StreamSubscription? _userSub;
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  bool _loadingTx = true;
  String _txSearchQuery = '';
  String _txTypeFilter = 'All';
  final TextEditingController _txSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user);
    final uid = _user['uid'] as String? ?? _user['id'] as String? ?? '';

    // Listen for live user updates (e.g. balance, status)
    if (uid.isNotEmpty) {
      _userSub = FirestoreService.instance.usersCollection?.doc(uid).snapshots().listen((doc) {
        if (!mounted || !doc.exists) return;
        final data = doc.data();
        if (data != null) {
          setState(() {
            _user = {..._user, ...data};
          });
        }
      });

      // Stream user transactions
      _txSub = FirestoreService.instance.streamUserTransactions(uid).listen((txs) {
        if (!mounted) return;
        setState(() {
          _allTransactions = txs;
          _loadingTx = false;
          _applyTxFilter();
        });
      });
    } else {
      _loadingTx = false;
    }
  }

  @override
  void dispose() {
    _txSub?.cancel();
    _userSub?.cancel();
    _txSearchController.dispose();
    super.dispose();
  }

  void _applyTxFilter() {
    final query = _txSearchQuery.trim().toLowerCase();
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        // Filter by type
        if (_txTypeFilter != 'All') {
          final txType = (tx['type'] as String? ?? '').toLowerCase();
          if (txType != _txTypeFilter.toLowerCase()) return false;
        }

        // Filter by search query
        if (query.isNotEmpty) {
          final title = (tx['title'] as String? ?? '').toLowerCase();
          final desc = (tx['description'] as String? ?? '').toLowerCase();
          final cat = (tx['category'] as String? ?? '').toLowerCase();
          final amt = (tx['amount'] ?? '').toString().toLowerCase();
          final id = (tx['id'] as String? ?? '').toLowerCase();
          final status = (tx['status'] as String? ?? '').toLowerCase();
          return title.contains(query) ||
              desc.contains(query) ||
              cat.contains(query) ||
              amt.contains(query) ||
              id.contains(query) ||
              status.contains(query);
        }
        return true;
      }).toList();
    });
  }

  String _getCurrencySymbol(String? c) {
    switch ((c ?? 'GBP').toUpperCase()) {
      case 'JMD': return 'J\$';
      case 'USD': return 'US\$';
      case 'GBP': return '£';
      case 'CAD': return 'CA\$';
      case 'EUR': return '€';
      default: return '£';
    }
  }

  String _amtStr(Map<String, dynamic> tx) {
    final amt = (tx['amount'] as num?)?.toDouble().abs() ?? 0.0;
    final type = (tx['type'] as String? ?? '').toLowerCase();
    final c = tx['currency'] as String? ?? (_user['currency'] as String? ?? 'GBP');
    final isPositive = type == 'deposit' || type == 'received';
    final prefix = isPositive ? '+' : '-';
    return '$prefix${_getCurrencySymbol(c)}${amt.toStringAsFixed(2)}';
  }

  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final p = name.trim().split(' ');
    return p.length >= 2 ? '${p[0][0]}${p[1][0]}'.toUpperCase() : p[0][0].toUpperCase();
  }

  Future<void> _updateStatus(String status) async {
    final uid = _user['id'] as String? ?? _user['uid'] as String? ?? '';
    if (uid.isEmpty) return;

    setState(() => _isLoading = true);
    await FirestoreService.instance.updateUserStatus(uid, status);
    setState(() {
      _user['accountStatus'] = status;
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Account status updated to $status'),
      backgroundColor: AppColors.kinTeal,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _sendMessage() async {
    final uid = _user['id'] as String? ?? _user['uid'] as String? ?? '';
    if (uid.isEmpty) return;

    setState(() => _isLoading = true);
    final chatId = uid;
    await FirestoreService.instance.sendSupportMessage(chatId, 'admin', 'Admin has sent a message.');
    
    await FirestoreService.instance.addNotification(uid, {
      'title': 'New Message from Admin',
      'body': 'Please check your support chats.',
      'type': 'message',
    });

    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Message sent to user'),
      backgroundColor: AppColors.kinTeal,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final name = _user['fullName'] as String? ?? 'Unknown User';
    final email = _user['email'] as String? ?? 'No email provided';
    final status = _user['accountStatus'] as String? ?? 'active';
    final rawBalance = _user['balance'];
    final balance = (rawBalance is num) ? rawBalance.toDouble() : 0.0;
    final currency = _user['currency'] as String? ?? 'GBP';
    final accNum = _user['accountNumber'] as String? ?? '—';
    final transit = _user['transitBankCode'] as String? ?? '—';
    final uid = _user['id'] as String? ?? _user['uid'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('User Profile', style: AppTheme.headingStyle(fontSize: 18)),
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
                const SizedBox(height: 18),
                
                // --- USER BALANCE CARD ---
                _buildBalanceCard(balance, currency, accNum, transit),
                const SizedBox(height: 20),

                _buildActionButtons(status),
                const SizedBox(height: 24),

                // --- RECENT TRANSACTIONS & SEARCH ---
                _buildTransactionsSection(uid),
                const SizedBox(height: 24),

                _buildSection('Verification & KYC Documents', [
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
                          label: 'Selfie / Biometric',
                          imageUrl: _user['selfieImagePath'] as String? ?? _user['selfie_image_path'] as String?,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),

                _buildSection('Personal Information', [
                  _infoRow('Date of Birth', _user['dateOfBirth'] ?? '—'),
                  _infoRow('Nationality', _user['nationality'] ?? '—'),
                  _infoRow('Identity Type', _user['identityType'] ?? '—'),
                  _infoRow('Identity Number', _user['identityNumber'] ?? '—'),
                ]),
                const SizedBox(height: 20),

                _buildSection('Contact & Location', [
                  _infoRow('Phone', _user['phone'] ?? '—'),
                  _infoRow('Street', _user['street'] ?? '—'),
                  _infoRow('City', _user['city'] ?? '—'),
                  _infoRow('Country', _user['country'] ?? _user['countryOfResidence'] ?? '—'),
                ]),
                const SizedBox(height: 20),

                _buildSection('Financial Profile', [
                  _infoRow('Employment', _user['employmentStatus'] ?? '—'),
                  _infoRow('Industry', _user['industry'] ?? '—'),
                  _infoRow('Monthly Income', _user['monthlyIncome'] ?? '—'),
                  _infoRow('Account Tier', _user['tier'] ?? 'Standard'),
                  _infoRow('Role', _user['role'] ?? 'User'),
                  _infoRow('KYC Status', _user['kycStatus'] ?? 'Pending'),
                ]),
              ],
            ),
          ),
    );
  }

  // ==================== BALANCE & ACCOUNT BANNER ====================
  Widget _buildBalanceCard(double balance, String currency, String accNum, String transit) {
    final sym = _getCurrencySymbol(currency);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF004D46),
            AppColors.primaryTeal,
            Color(0xFF00332E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'CURRENT AVAILABLE BALANCE',
                    style: AppTheme.labelStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Text(
                  currency.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$sym${balance.toStringAsFixed(2)}',
            style: AppTheme.headingStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Number',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        accNum,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (accNum != '—') ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: accNum));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Account number copied to clipboard'), duration: Duration(seconds: 1)),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, color: Colors.white70, size: 14),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Transit / Branch Code',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    transit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TRANSACTIONS & SEARCH ====================
  Widget _buildTransactionsSection(String uid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primaryTeal, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Transactions',
                    style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.kinMist,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_allTransactions.length} total',
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _txSearchController,
            onChanged: (val) {
              _txSearchQuery = val;
              _applyTxFilter();
            },
            decoration: InputDecoration(
              hintText: 'Search by title, category, amount...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal, size: 20),
              suffixIcon: _txSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _txSearchController.clear();
                        _txSearchQuery = '';
                        _applyTxFilter();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF6F8F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final type in ['All', 'deposit', 'transfer', 'withdrawal'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        type == 'All' ? 'All' : type[0].toUpperCase() + type.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _txTypeFilter == type ? FontWeight.bold : FontWeight.normal,
                          color: _txTypeFilter == type ? Colors.white : AppColors.kinInk,
                        ),
                      ),
                      selected: _txTypeFilter == type,
                      selectedColor: AppColors.primaryTeal,
                      backgroundColor: const Color(0xFFF0F4F2),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide.none,
                      onSelected: (selected) {
                        _txTypeFilter = type;
                        _applyTxFilter();
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transactions List or States
          if (_loadingTx)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primaryTeal),
              ),
            )
          else if (_allTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.kinMist,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No transactions recorded yet for this user.',
                    style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[600]!),
                  ),
                ],
              ),
            )
          else if (_filteredTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.kinMist,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 36, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No transactions match "$_txSearchQuery"',
                    style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[600]!),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
              itemBuilder: (context, i) {
                final tx = _filteredTransactions[i];
                return _buildTxItem(tx);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTxItem(Map<String, dynamic> tx) {
    final type = (tx['type'] as String? ?? '').toLowerCase();
    final isPositive = type == 'deposit' || type == 'received';
    final title = tx['title'] as String? ?? (type == 'deposit' ? 'Account Deposit' : 'Transfer');
    final category = tx['category'] as String? ?? (type.isNotEmpty ? type[0].toUpperCase() + type.substring(1) : '');
    final timeStr = _timeAgo(tx['createdAt'] as String?);
    final amtStr = _amtStr(tx);
    final status = (tx['status'] as String? ?? 'completed').toLowerCase();

    IconData icon;
    Color iconColor;
    Color iconBg;

    if (type == 'deposit' || type == 'received') {
      icon = Icons.arrow_downward_rounded;
      iconColor = AppColors.kinTeal;
      iconBg = const Color(0xFFE6F4F1);
    } else if (type == 'withdrawal') {
      icon = Icons.shopping_bag_outlined;
      iconColor = AppColors.kinCoral;
      iconBg = const Color(0xFFFFECEB);
    } else {
      icon = Icons.arrow_upward_rounded;
      iconColor = const Color(0xFFE67E22);
      iconBg = const Color(0xFFFDF2E9);
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminTransactionDetailScreen(transaction: tx),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (category.isNotEmpty) ...[
                        Text(
                          category,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        if (timeStr.isNotEmpty)
                          Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                      ],
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amtStr,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? AppColors.kinTeal : AppColors.kinCoral,
                  ),
                ),
                if (status != 'completed') ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: status == 'reversed'
                          ? Colors.grey.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: status == 'reversed' ? Colors.grey[700] : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER & DETAILS ====================
  Widget _buildHeader(String name, String email, String status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              final avatarUrl = _user['photoURL'] as String? ??
                  _user['selfieImagePath'] as String? ??
                  _user['selfie_image_path'] as String?;
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                _showImagePreviewDialog(avatarUrl, name);
              }
            },
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.kinTeal.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3), width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildAvatar(name),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTheme.headingStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(email, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey[500]!)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'suspended' ? AppColors.kinCoral.withValues(alpha: 0.1) : AppColors.kinTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: AppTheme.bodyStyle(
                fontSize: 12, 
                color: status == 'suspended' ? AppColors.kinCoral : AppColors.kinTeal,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    final isSuspended = status == 'suspended';
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus(isSuspended ? 'active' : 'suspended'),
            icon: Icon(isSuspended ? Icons.lock_open : Icons.lock_outline, size: 18),
            label: Text(isSuspended ? 'Activate Account' : 'Suspend Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuspended ? AppColors.kinTeal : AppColors.kinCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _sendMessage,
            icon: const Icon(Icons.message_outlined, size: 18),
            label: const Text('Send Message'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.kinTeal,
              side: const BorderSide(color: AppColors.kinTeal),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
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
          child: Column(children: children),
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
            child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.kinInk)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final avatarUrl = _user['photoURL'] as String? ??
        _user['selfieImagePath'] as String? ??
        _user['selfie_image_path'] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        return Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(_initials(name), style: AppTheme.headingStyle(fontSize: 28, color: AppColors.kinTeal)),
          ),
        );
      } else if (File(avatarUrl).existsSync()) {
        return Image.file(
          File(avatarUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(_initials(name), style: AppTheme.headingStyle(fontSize: 28, color: AppColors.kinTeal)),
          ),
        );
      }
    }
    return Center(child: Text(_initials(name), style: AppTheme.headingStyle(fontSize: 28, color: AppColors.kinTeal)));
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
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final isRemote = hasImage && imageUrl.startsWith('http');
    final isLocal = hasImage && !isRemote && File(imageUrl).existsSync();

    if (!hasImage || (!isRemote && !isLocal)) {
      return _mockDocument(label);
    }

    return GestureDetector(
      onTap: () => _showImagePreviewDialog(imageUrl, label),
      child: Container(
        height: 120,
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
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.kinTeal),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _mockDocument(label),
              )
            else
              Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _mockDocument(label),
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

  Widget _mockDocument(String label) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.kinMist,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(label.contains('Selfie') ? Icons.face_retouching_natural : Icons.credit_card, color: Colors.grey[400], size: 30),
            const SizedBox(height: 8),
            Text(label, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]!)),
            const SizedBox(height: 4),
            Text('Not provided', style: TextStyle(fontSize: 10, color: Colors.grey[400]!)),
          ],
        ),
      ),
    );
  }
}
