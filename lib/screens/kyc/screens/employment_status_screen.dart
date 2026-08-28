import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';

const List<Map<String, dynamic>> kEmploymentStatusOptions = [
  {
    'id': 'self_employed',
    'title': 'Self-Employed / MSME Trader',
    'subtitle': 'Business owner, market vendor, or independent contractor',
    'icon': Icons.storefront_outlined,
  },
  {
    'id': 'full_time',
    'title': 'Employed Full-Time',
    'subtitle': 'Salaried employee working 30+ hours per week',
    'icon': Icons.work_outline,
  },
  {
    'id': 'part_time',
    'title': 'Employed Part-Time',
    'subtitle': 'Working casual or part-time shifts',
    'icon': Icons.access_time_outlined,
  },
  {
    'id': 'student',
    'title': 'Student',
    'subtitle': 'Enrolled in university or vocational program',
    'icon': Icons.school_outlined,
  },
  {
    'id': 'retired',
    'title': 'Retired',
    'subtitle': 'Receiving pension or retirement funds',
    'icon': Icons.elderly_outlined,
  },
];

const List<String> kIndustryOptions = [
  'Retail & E-commerce',
  'Hospitality & Tourism',
  'Agriculture & Food Trade',
  'Technology & Digital Services',
  'Construction & Logistics',
  'Healthcare & Wellness',
  'Education & Civil Service',
  'Other / General Services',
];

const List<String> kIncomeRangeOptions = [
  'Under JMD \$150,000 / month',
  'JMD \$150,000 - \$350,000 / month',
  'JMD \$350,000 - \$750,000 / month',
  'JMD \$750,000 - \$1,500,000 / month',
  'JMD \$1,500,000+ / month',
];

/// Step 3: Employment & Income Profile
/// Employment status selection, industry dropdown, and monthly cash flow bracket options.
class EmploymentStatusScreen extends StatefulWidget {
  final Function(Map<String, String> employmentData) onNext;

  const EmploymentStatusScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<EmploymentStatusScreen> createState() => _EmploymentStatusScreenState();
}

class _EmploymentStatusScreenState extends State<EmploymentStatusScreen> {
  String _selectedStatus = 'self_employed';
  String _selectedIndustry = kIndustryOptions[0];
  String _selectedIncome = kIncomeRangeOptions[1]; // JMD $150,000 - $350,000 default

  void _handleNext() {
    KinHaptics.lightTap();
    final statusObj = kEmploymentStatusOptions.firstWhere(
      (opt) => opt['id'] == _selectedStatus,
      orElse: () => kEmploymentStatusOptions.first,
    );

    widget.onNext({
      'employment_status': statusObj['title'] as String,
      'employment_status_id': _selectedStatus,
      'industry': _selectedIndustry,
      'monthly_income': _selectedIncome,
    });
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
                      'Employment & Financials',
                      style: AppTheme.headingStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kinInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select your primary source of income and business industry.',
                      style: AppTheme.bodyStyle(
                        fontSize: 14,
                        color: AppColors.kinInk.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Employment Status Selection Tiles
                    Text('EMPLOYMENT STATUS', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 10),
                    Column(
                      children: kEmploymentStatusOptions.map((opt) {
                        final isSelected = opt['id'] == _selectedStatus;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: KinBounceable(
                            onTap: () {
                              KinHaptics.stateChange();
                              setState(() {
                                _selectedStatus = opt['id'] as String;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryTeal : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryTeal.withValues(alpha: 0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isSelected
                                        ? AppColors.primaryTeal.withValues(alpha: 0.15)
                                        : Colors.grey[100],
                                    child: Icon(
                                      opt['icon'] as IconData,
                                      color: isSelected ? AppColors.primaryTeal : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          opt['title'] as String,
                                          style: AppTheme.bodyStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.kinInk,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          opt['subtitle'] as String,
                                          style: AppTheme.bodyStyle(
                                            fontSize: 12,
                                            color: AppColors.kinInk.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryTeal,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 2. Industry / Occupation Dropdown
                    Text('INDUSTRY / OCCUPATION', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedIndustry,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
                          style: AppTheme.bodyStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          items: kIndustryOptions.map((ind) {
                            return DropdownMenuItem<String>(
                              value: ind,
                              child: Text(ind),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              KinHaptics.stateChange();
                              setState(() {
                                _selectedIndustry = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Monthly Income / Cash Flow Bracket Dropdown
                    Text('ESTIMATED MONTHLY CASH FLOW (JMD \$)', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedIncome,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
                          style: AppTheme.bodyStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          items: kIncomeRangeOptions.map((inc) {
                            return DropdownMenuItem<String>(
                              value: inc,
                              child: Text(inc),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              KinHaptics.stateChange();
                              setState(() {
                                _selectedIncome = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom Anchored "Next" Button
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
                  child: const Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
