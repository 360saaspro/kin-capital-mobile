import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/branded_background.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/currency_service.dart';
import 'set_goal_identity_screen.dart';

class YardPotScreen extends StatefulWidget {
  final Map<String, dynamic>? pot;
  const YardPotScreen({super.key, this.pot});

  @override
  State<YardPotScreen> createState() => _YardPotScreenState();
}

class _YardPotScreenState extends State<YardPotScreen> {
  late String _potId;

  @override
  void initState() {
    super.initState();
    _potId = widget.pot?['id']?.toString() ?? 'pot_default';
  }

  IconData _resolvePotIcon(dynamic iconCode, dynamic category) {
    if (iconCode != null) {
      final code = int.tryParse(iconCode.toString());
      if (code == Icons.favorite_rounded.codePoint) return Icons.favorite_rounded;
      if (code == Icons.beach_access_rounded.codePoint || code == Icons.beach_access.codePoint) return Icons.beach_access_rounded;
      if (code == Icons.shield_outlined.codePoint) return Icons.shield_outlined;
      if (code == Icons.school_rounded.codePoint) return Icons.school_rounded;
      if (code == Icons.home_work_outlined.codePoint) return Icons.home_work_outlined;
      if (code == Icons.stars_rounded.codePoint) return Icons.stars_rounded;
      if (code == Icons.savings_outlined.codePoint) return Icons.savings_outlined;
    }
    final cat = category?.toString().toLowerCase() ?? '';
    if (cat.contains('family')) return Icons.favorite_rounded;
    if (cat.contains('vacation') || cat.contains('trip') || cat.contains('holiday')) return Icons.beach_access_rounded;
    if (cat.contains('emergency') || cat.contains('buffer') || cat.contains('rainy')) return Icons.shield_outlined;
    if (cat.contains('school') || cat.contains('tuition') || cat.contains('growth')) return Icons.school_rounded;
    if (cat.contains('home') || cat.contains('tech') || cat.contains('upgrade')) return Icons.home_work_outlined;
    return Icons.savings_outlined;
  }

  double _toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  void _showAddFundsSheet(BuildContext context, String uid, String symbol, Map<String, dynamic> activePot) {
    final amountController = TextEditingController();
    final isJmd = CurrencyService.instance.currency.value == AppCurrency.jmd;
    final presets = isJmd ? [5000, 10000, 25000, 50000] : [25, 50, 100, 250];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.kinInk.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Funds to Pot',
                        style: AppTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.kinInk),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Text(
                    'Deposit directly into "${activePot['title'] ?? 'Yard Pot'}"',
                    style: AppTheme.bodyStyle(
                      color: AppColors.kinInk.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<Map<String, dynamic>?>(
                    stream: FirestoreService.instance.streamUserProfile(uid),
                    builder: (context, snapshot) {
                      final profile = snapshot.data ?? FirestoreService.instance.getCachedUser(uid);
                      final balance = _toDouble(profile?['balance']);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primaryTeal),
                            const SizedBox(width: 6),
                            Text(
                              'Available: $symbol${balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.kinMistLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          symbol,
                          style: AppTheme.headingStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            autofocus: true,
                            style: AppTheme.headingStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kinInk,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: presets.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final val = presets[index];
                        final label = isJmd
                            ? '+J\$${(val / 1000).toStringAsFixed(0)}k'
                            : '+$symbol$val';

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              amountController.text = val.toString();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final entered = double.tryParse(amountController.text.replaceAll(',', '').trim());
                        if (entered == null || entered <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount.'),
                              backgroundColor: AppColors.kinCoral,
                            ),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);

                        // Process pot funding in Firestore
                        await FirestoreService.instance.addPotFunds(uid, _potId, entered);
                        await FirestoreService.instance.addTransaction(
                          userId: uid,
                          amount: entered,
                          type: 'pot_deposit',
                          title: 'Saved to ${activePot['title'] ?? 'Yard Pot'}',
                          metadata: {
                            'currency': CurrencyService.instance.currency.value.name.toUpperCase(),
                          },
                        );

                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text('Added $symbol${entered.toStringAsFixed(2)} to pot!'),
                                ],
                              ),
                              backgroundColor: AppColors.primaryTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Deposit to Pot',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showInviteSheet(BuildContext context, String uid, Map<String, dynamic> activePot) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.kinInk.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invite Contributor',
                    style: AppTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.kinInk),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Invite family or friends to save together in this Yard Pot.',
                style: AppTheme.bodyStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'MEMBER NAME',
                style: AppTheme.labelStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.kinMistLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Auntie June or Marcus',
                    hintStyle: TextStyle(color: AppColors.kinInk.withValues(alpha: 0.35), fontSize: 14),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryTeal, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PHONE OR EMAIL',
                style: AppTheme.labelStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.kinMistLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    hintText: '+1 (876) ... or email@domain.com',
                    hintStyle: TextStyle(color: AppColors.kinInk.withValues(alpha: 0.35), fontSize: 14),
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryTeal, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final contact = contactController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a contributor name.'),
                          backgroundColor: AppColors.kinCoral,
                        ),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    // Add contributor in Firestore
                    await FirestoreService.instance.addPotContributor(uid, _potId, {
                      'name': name,
                      'contact': contact,
                      'role': 'Contributor',
                      'status': 'Invited',
                      'contributedAmount': 0.0,
                    });

                    await FirestoreService.instance.addPotActivity(uid, _potId, {
                      'type': 'Invitation',
                      'title': '$name invited to pot',
                      'amount': 0.0,
                    });

                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: Colors.white),
                              const SizedBox(width: 10),
                              Text('Invitation sent to $name!'),
                            ],
                          ),
                          backgroundColor: AppColors.primaryTeal,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Send Invitation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUid;

    return ValueListenableBuilder<AppCurrency>(
      valueListenable: CurrencyService.instance.currency,
      builder: (context, currency, _) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.streamUserPots(uid),
          builder: (context, potsSnapshot) {
            final allPots = (potsSnapshot.data?.isNotEmpty == true)
                ? potsSnapshot.data!
                : FirestoreService.instance.getCachedPots(uid);

            final currentPot = allPots.firstWhere(
              (p) => p['id'] == _potId,
              orElse: () => widget.pot ?? {
                'id': _potId,
                'title': 'Yard Pot',
                'category': 'Family Support',
                'savedAmount': 0.0,
                'targetAmount': 50000.0,
                'roundUpMultiplier': 2,
                'status': 'Active',
              },
            );

            final potTitle = currentPot['title'] ?? 'Yard Pot';

            return Scaffold(
              backgroundColor: AppColors.kinMistLight,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  potTitle,
                  style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                actions: const [], // Removed notification and profile icon as requested
              ),
              body: BrandedBackground(
                opacity: 0.02,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainGoalCard(context, uid, currency.symbol, currentPot),
                        const SizedBox(height: 28),
                        _buildContributorsSection(context, uid, currency.symbol, currentPot),
                        const SizedBox(height: 28),
                        _buildActivitySection(context, uid, currency.symbol, currentPot),
                        const SizedBox(height: 28),
                        _buildSavingsProverbCard(currentPot),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SetGoalIdentityScreen()),
                  );
                },
                backgroundColor: AppColors.primaryTeal,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMainGoalCard(BuildContext context, String uid, String symbol, Map<String, dynamic> pot) {
    final title = pot['title'] ?? 'Yard Pot';
    final category = (pot['category'] ?? 'SAVINGS').toString().toUpperCase();
    final savedAmount = _toDouble(pot['savedAmount'], 0.0);
    final targetAmount = _toDouble(pot['targetAmount'], 50000.0);
    final progress = targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    final icon = _resolvePotIcon(pot['icon'], pot['category']);
    final colorHex = pot['color']?.toString();
    final color = colorHex != null
        ? Color(int.tryParse(colorHex, radix: 16) ?? AppColors.primaryTeal.toARGB32())
        : AppColors.primaryTeal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.06),
            blurRadius: 20,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: AppTheme.headingStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$symbol${savedAmount.toStringAsFixed(2)}',
                style: AppTheme.dataStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.kinInk),
              ),
              const SizedBox(width: 8),
              Text(
                '/ $symbol${targetAmount.toStringAsFixed(0)}',
                style: AppTheme.bodyStyle(color: AppColors.kinInk.withValues(alpha: 0.5), fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent% Saved',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.kinMistLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddFundsSheet(context, uid, symbol, pot),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add funds', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showInviteSheet(context, uid, pot),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Invite', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributorsSection(BuildContext context, String uid, String symbol, Map<String, dynamic> pot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Contributors', style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => _showInviteSheet(context, uid, pot),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTeal),
              label: const Text('Invite', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.streamPotContributors(uid, _potId),
          builder: (context, snapshot) {
            final invitedList = (snapshot.data?.isNotEmpty == true)
                ? snapshot.data!
                : FirestoreService.instance.getCachedPotContributors(uid, _potId);

            return StreamBuilder<Map<String, dynamic>?>(
              stream: FirestoreService.instance.streamUserProfile(uid),
              builder: (context, userSnapshot) {
                final profile = userSnapshot.data ?? FirestoreService.instance.getCachedUser(uid);
                final ownerName = (profile?['fullName'] as String?)?.isNotEmpty == true
                    ? profile!['fullName'] as String
                    : 'You (Owner)';
                final potSaved = _toDouble(pot['savedAmount'], 0.0);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: 1 + invitedList.length + 1,
                  itemBuilder: (context, index) {
                    // Item 0 is always the primary user
                    if (index == 0) {
                      final initial = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'Y';
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryTeal.withValues(alpha: 0.04),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ownerName,
                              style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$symbol${potSaved.toStringAsFixed(2)}',
                              style: AppTheme.dataStyle(color: AppColors.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }

                    // Last item is Add Member tile
                    if (index == invitedList.length + 1) {
                      return GestureDetector(
                        onTap: () => _showInviteSheet(context, uid, pot),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryTeal.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: AppColors.primaryTeal, size: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Member',
                                style: AppTheme.bodyStyle(
                                  color: AppColors.primaryTeal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Invited members
                    final contributor = invitedList[index - 1];
                    final cName = contributor['name'] ?? 'Family Member';
                    final cInitial = cName.isNotEmpty ? cName[0].toUpperCase() : 'M';
                    final cAmount = _toDouble(contributor['contributedAmount'], 0.0);
                    final status = contributor['status'] ?? 'Active';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.kinInk.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.kinCoral.withValues(alpha: 0.12),
                            child: Text(
                              cInitial,
                              style: const TextStyle(
                                color: AppColors.kinCoral,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cName,
                            style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status == 'Invited' ? 'Invited' : '$symbol${cAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: status == 'Invited' ? AppColors.kinInk.withValues(alpha: 0.5) : AppColors.primaryTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context, String uid, String symbol, Map<String, dynamic> pot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pot Activity', style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.streamPotActivities(uid, _potId),
          builder: (context, snapshot) {
            final activities = (snapshot.data?.isNotEmpty == true)
                ? snapshot.data!
                : FirestoreService.instance.getCachedPotActivities(uid, _potId);

            if (activities.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_toggle_off_rounded, color: AppColors.primaryTeal, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No Pot Activity Yet', style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Deposits and round-up savings will appear here.', style: TextStyle(color: AppColors.kinInk.withValues(alpha: 0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                itemBuilder: (context, index) {
                  final a = activities[index];
                  final title = a['title'] ?? 'Pot Transaction';
                  final type = a['type'] ?? 'Deposit';
                  final amt = _toDouble(a['amount']);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type == 'Invitation' ? Icons.mail_outline : Icons.savings_outlined,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      title,
                      style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      type,
                      style: TextStyle(color: AppColors.kinInk.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    trailing: amt > 0
                        ? Text(
                            '+$symbol${amt.toStringAsFixed(2)}',
                            style: AppTheme.dataStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSavingsProverbCard(Map<String, dynamic> pot) {
    final multiplier = pot['roundUpMultiplier']?.toString() ?? '2';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal,
            const Color(0xFF004D47),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -15,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/kin_logo.png',
                width: 100,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SMART ROUND-UPS: ${multiplier}X',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '"Every mickle makes a muckle. Save with family, grow with community."',
                style: AppTheme.bodyStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '— Jamaican Proverb',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
