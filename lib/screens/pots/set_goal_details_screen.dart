import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/branded_background.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/currency_service.dart';

class SetGoalDetailsScreen extends StatefulWidget {
  final String category;
  final String potTitle;
  final IconData iconData;
  final Color accentColor;

  const SetGoalDetailsScreen({
    super.key,
    this.category = 'Family Support',
    this.potTitle = 'Family Support',
    this.iconData = Icons.favorite_rounded,
    this.accentColor = AppColors.kinCoral,
  });

  @override
  State<SetGoalDetailsScreen> createState() => _SetGoalDetailsScreenState();
}

class _SetGoalDetailsScreenState extends State<SetGoalDetailsScreen> {
  late final TextEditingController _amountController;
  DateTime? _selectedDate;
  bool _roundUpEnabled = true;
  int _roundUpMultiplier = 2;
  bool _isLoading = false;

  final List<int> _multiplierOptions = [1, 2, 3, 5, 10];

  @override
  void initState() {
    super.initState();
    final isJmd = CurrencyService.instance.currency.value == AppCurrency.jmd;
    _amountController = TextEditingController(text: isJmd ? '50,000' : '500');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addPresetAmount(int preset) {
    final currentText = _amountController.text.replaceAll(',', '').trim();
    final current = double.tryParse(currentText) ?? 0.0;
    final updated = current + preset;
    setState(() {
      _amountController.text = _formatAmountNumber(updated);
    });
  }

  void _setPresetAmount(int preset) {
    setState(() {
      _amountController.text = _formatAmountNumber(preset.toDouble());
    });
  }

  String _formatAmountNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(2);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.kinInk,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _setDurationPreset(int months) {
    setState(() {
      _selectedDate = DateTime.now().add(Duration(days: months * 30));
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _handleCreatePot(AppCurrency currency) async {
    final cleanAmount = _amountController.text.replaceAll(',', '').trim();
    final target = double.tryParse(cleanAmount) ?? (currency == AppCurrency.jmd ? 50000.0 : 500.0);

    if (target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a target amount greater than zero.'),
          backgroundColor: AppColors.kinCoral,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = AuthService.instance.currentUid;
      final potId = 'pot_${DateTime.now().millisecondsSinceEpoch}';

      await FirestoreService.instance.createOrUpdatePot(uid, potId, {
        'title': widget.potTitle,
        'category': widget.category,
        'targetAmount': target,
        'savedAmount': 0.0,
        'currency': currency.code,
        'targetDate': _selectedDate?.toIso8601String(),
        'roundUpEnabled': _roundUpEnabled,
        'roundUpMultiplier': _roundUpMultiplier,
        'icon': widget.iconData.codePoint.toString(),
        'color': widget.accentColor.toARGB32().toRadixString(16),
        'status': 'Active',
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Yard Pot "${widget.potTitle}" created successfully!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (_) {
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppCurrency>(
      valueListenable: CurrencyService.instance.currency,
      builder: (context, currency, _) {
        return Scaffold(
          backgroundColor: AppColors.kinMistLight,
          body: BrandedBackground(
            opacity: 0.02,
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildProgressBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDynamicHero(currency),
                          const SizedBox(height: 28),
                          _buildTargetAmountSection(currency),
                          const SizedBox(height: 28),
                          _buildDatePickerSection(),
                          const SizedBox(height: 28),
                          _buildBoostersSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(currency),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Goal Details',
            style: AppTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Step 2 of 2',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step 1: Goal Identity',
                style: AppTheme.bodyStyle(
                  color: AppColors.kinInk.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                'Step 2: Target & Boosters',
                style: AppTheme.bodyStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHero(AppCurrency currency) {
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
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/kin_logo.png',
                width: 120,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, size: 14, color: Colors.amber[300]),
                        const SizedBox(width: 6),
                        Text(
                          widget.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Icon(widget.iconData, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.potTitle,
                style: AppTheme.headingStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Currency: ${currency.label}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAmountSection(AppCurrency currency) {
    final isJmd = currency == AppCurrency.jmd;
    final presets = isJmd ? [10000, 25000, 50000, 100000] : [100, 250, 500, 1000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TARGET SAVINGS AMOUNT',
              style: AppTheme.labelStyle(
                color: AppColors.kinInk.withValues(alpha: 0.5),
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              currency.code,
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  currency.symbol,
                  style: AppTheme.headingStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTheme.headingStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kinInk,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.00',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
                  : '+${currency.symbol}$val';

              return GestureDetector(
                onTap: () => _addPresetAmount(val),
                onDoubleTap: () => _setPresetAmount(val),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryTeal.withValues(alpha: 0.15),
                    ),
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
      ],
    );
  }

  Widget _buildDatePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TARGET DATE (OPTIONAL)',
          style: AppTheme.labelStyle(
            color: AppColors.kinInk.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _selectedDate != null
                    ? AppColors.primaryTeal
                    : AppColors.kinInk.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primaryTeal,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDate != null ? _formatDate(_selectedDate!) : 'No date selected',
                        style: AppTheme.bodyStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _selectedDate != null ? AppColors.kinInk : AppColors.kinInk.withValues(alpha: 0.5),
                        ),
                      ),
                      if (_selectedDate != null)
                        Text(
                          '${_selectedDate!.difference(DateTime.now()).inDays} days remaining',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.kinInk.withValues(alpha: 0.4), size: 18),
                    onPressed: () => setState(() => _selectedDate = null),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: AppColors.primaryTeal),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildQuickDateChip('3 Months', 3),
            const SizedBox(width: 8),
            _buildQuickDateChip('6 Months', 6),
            const SizedBox(width: 8),
            _buildQuickDateChip('1 Year', 12),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateChip(String label, int months) {
    return GestureDetector(
      onTap: () => _setDurationPreset(months),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.kinInk.withValues(alpha: 0.08)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.kinInk.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildBoostersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Round-ups',
                        style: AppTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Save spare change automatically',
                        style: AppTheme.bodyStyle(
                          fontSize: 12,
                          color: AppColors.kinInk.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch.adaptive(
                value: _roundUpEnabled,
                activeTrackColor: AppColors.primaryTeal,
                activeThumbColor: Colors.white,
                onChanged: (val) => setState(() => _roundUpEnabled = val),
              ),
            ],
          ),
          if (_roundUpEnabled) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'ROUND-UP MULTIPLIER',
              style: AppTheme.labelStyle(
                color: AppColors.kinInk.withValues(alpha: 0.5),
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _multiplierOptions.map((mult) {
                final isSelected = _roundUpMultiplier == mult;
                return GestureDetector(
                  onTap: () => setState(() => _roundUpMultiplier = mult),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryTeal : AppColors.kinMistLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      '${mult}x',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.kinInk,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kinMistLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Every transaction spare change is multiplied by ${_roundUpMultiplier}x and saved directly into this pot.',
                      style: AppTheme.bodyStyle(
                        fontSize: 11,
                        color: AppColors.kinInk.withValues(alpha: 0.65),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(AppCurrency currency) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : () => _handleCreatePot(currency),
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.savings_outlined, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Create Yard Pot',
                              style: AppTheme.headingStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
