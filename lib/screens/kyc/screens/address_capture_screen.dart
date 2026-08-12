import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';

const List<Map<String, String>> kCaribbeanAddressAutofillSuggestions = [
  {
    'display': '14 Hope Road, Kingston, Jamaica',
    'street': '14 Hope Road',
    'city': 'Kingston',
    'country': 'Jamaica',
  },
  {
    'display': '23 King Street, Montego Bay, Jamaica',
    'street': '23 King Street',
    'city': 'Montego Bay',
    'country': 'Jamaica',
  },
  {
    'display': '87 West Bay Road, George Town, Grand Cayman',
    'street': '87 West Bay Road',
    'city': 'George Town',
    'country': 'Cayman Islands',
  },
  {
    'display': '45 Independence Avenue, Bridgetown, Barbados',
    'street': '45 Independence Avenue',
    'city': 'Bridgetown',
    'country': 'Barbados',
  },
  {
    'display': '12 Frederick Street, Port of Spain, Trinidad',
    'street': '12 Frederick Street',
    'city': 'Port of Spain',
    'country': 'Trinidad & Tobago',
  },
  {
    'display': '123 Calle Principal, San Pedro Sula, Cortes',
    'street': '123 Calle Principal',
    'city': 'San Pedro Sula',
    'country': 'Honduras',
  },
];

const List<String> kResidenceDurationOptions = [
  'Less than 6 months',
  '6 - 12 months',
  '1 - 3 years',
  '3+ years',
];

/// Step 2: Address & Residence Duration
/// Interactive Caribbean address search with autofill suggestions, street, city, country, and duration at address selection.
class AddressCaptureScreen extends StatefulWidget {
  final Function(Map<String, String> addressData) onNext;

  const AddressCaptureScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<AddressCaptureScreen> createState() => _AddressCaptureScreenState();
}

class _AddressCaptureScreenState extends State<AddressCaptureScreen> {
  final _searchController = TextEditingController();
  final _streetController = TextEditingController(text: '14 Hope Road');
  final _cityController = TextEditingController(text: 'Kingston');
  final _countryController = TextEditingController(text: 'Jamaica');

  String _selectedDuration = kResidenceDurationOptions[2]; // '1 - 3 years' default
  List<Map<String, String>> _filteredSuggestions = [];
  bool _showSuggestions = false;
  bool _isButtonActive = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _streetController.addListener(_validateInputs);
    _cityController.addListener(_validateInputs);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final matches = kCaribbeanAddressAutofillSuggestions.where((item) {
      return item['display']!.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredSuggestions = matches.isNotEmpty ? matches : kCaribbeanAddressAutofillSuggestions;
      _showSuggestions = true;
    });
  }

  void _selectSuggestion(Map<String, String> suggestion) {
    KinHaptics.stateChange();
    setState(() {
      _searchController.text = suggestion['display']!;
      _streetController.text = suggestion['street']!;
      _cityController.text = suggestion['city']!;
      _countryController.text = suggestion['country']!;
      _showSuggestions = false;
    });
    _validateInputs();
  }

  void _validateInputs() {
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final isValid = street.isNotEmpty && city.isNotEmpty;

    if (isValid != _isButtonActive) {
      setState(() {
        _isButtonActive = isValid;
      });
    }
  }

  void _handleNext() {
    if (!_isButtonActive) return;
    KinHaptics.lightTap();

    final fullAddress =
        '${_streetController.text.trim()}, ${_cityController.text.trim()}, ${_countryController.text.trim()}';

    widget.onNext({
      'address': fullAddress,
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'residence_duration': _selectedDuration,
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
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
                      'Residential Address',
                      style: AppTheme.headingStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kinInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search for your address or enter street & town details manually.',
                      style: AppTheme.bodyStyle(
                        fontSize: 14,
                        color: AppColors.kinInk.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Address Autofill Search Field
                    Text('SEARCH / AUTOFILL ADDRESS', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _searchController,
                      style: AppTheme.bodyStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Type city, street, or island...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryTeal),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                      ),
                    ),

                    // Autofill Dropdown Suggestions List
                    if (_showSuggestions && _filteredSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredSuggestions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _filteredSuggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined, color: AppColors.primaryTeal, size: 20),
                              title: Text(item['display']!, style: AppTheme.bodyStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              onTap: () => _selectSuggestion(item),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Street Address Input
                    Text('STREET ADDRESS', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _streetController,
                      style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'e.g. 14 Hope Road',
                        prefixIcon: const Icon(Icons.home_outlined, color: AppColors.primaryTeal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // City Input
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOWN / CITY', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _cityController,
                                style: AppTheme.bodyStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'Kingston',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Country Input
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('COUNTRY', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _countryController,
                                style: AppTheme.bodyStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'Jamaica',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Duration at Address Dropdown Selection
                    Text('HOW LONG HAVE YOU LIVED AT THIS ADDRESS?', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDuration,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
                          style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          items: kResidenceDurationOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              KinHaptics.stateChange();
                              setState(() {
                                _selectedDuration = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Anchored "Next" Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: KinBounceable(
                onTap: _isButtonActive ? _handleNext : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isButtonActive ? AppColors.primaryTeal : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isButtonActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryTeal.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isButtonActive ? Colors.white : Colors.grey[600],
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
