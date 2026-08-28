import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kin_bounceable.dart';
import '../../../core/services/auth_service.dart';

class CaribbeanCountry {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CaribbeanCountry({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

const List<CaribbeanCountry> kCaribbeanCountries = [
  CaribbeanCountry(name: 'Jamaica', code: 'JM', dialCode: '+1 876', flag: '🇯🇲'),
  CaribbeanCountry(name: 'Trinidad & Tobago', code: 'TT', dialCode: '+1 868', flag: '🇹🇹'),
  CaribbeanCountry(name: 'Barbados', code: 'BB', dialCode: '+1 246', flag: '🇧🇧'),
  CaribbeanCountry(name: 'Bahamas', code: 'BS', dialCode: '+1 242', flag: '🇧🇸'),
  CaribbeanCountry(name: 'Cayman Islands', code: 'KY', dialCode: '+1 345', flag: '🇰🇾'),
  CaribbeanCountry(name: 'St. Lucia', code: 'LC', dialCode: '+1 758', flag: '🇱🇨'),
  CaribbeanCountry(name: 'Dominican Republic', code: 'DO', dialCode: '+1 809', flag: '🇩🇴'),
  CaribbeanCountry(name: 'Guyana', code: 'GY', dialCode: '+592', flag: '🇬🇾'),
  CaribbeanCountry(name: 'Belize', code: 'BZ', dialCode: '+501', flag: '🇧🇿'),
  CaribbeanCountry(name: 'Honduras', code: 'HN', dialCode: '+504', flag: '🇭🇳'),
];

/// Step 1: Personal Details & Contact
/// Name (2+ words), Email (regex), Phone (Caribbean dial code), Date of Birth (Native Calendar Picker & 18+ age check).
class FriendlyDataCaptureScreen extends StatefulWidget {
  final Function(Map<String, String> data) onNext;

  const FriendlyDataCaptureScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<FriendlyDataCaptureScreen> createState() => _FriendlyDataCaptureScreenState();
}

class _FriendlyDataCaptureScreenState extends State<FriendlyDataCaptureScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController(text: '1995-06-15');

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  bool _obscurePassword = true;

  CaribbeanCountry _selectedCountry = kCaribbeanCountries.first; // Jamaica default
  DateTime? _selectedDate = DateTime(1995, 6, 15);

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _dobError;

  bool _isButtonActive = false;
  bool _isLoading = false;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_fullNameFocus);
    });

    _fullNameController.addListener(_validateInputs);
    _emailController.addListener(_validateInputs);
    _phoneController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
    _dobController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final password = _passwordController.text;

    final isNameValid = name.contains(' ') && name.length >= 3;
    final isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    final isPhoneValid = phoneDigits.length >= 7;
    final isPasswordValid = password.length >= 6;
    final isAgeValid = _selectedDate != null && _calculateAge(_selectedDate!) >= 18;

    setState(() {
      _nameError = name.isNotEmpty && !isNameValid ? 'Enter full first and last name' : null;
      _emailError = email.isNotEmpty && !isEmailValid ? 'Enter a valid email address' : null;
      _phoneError = phoneDigits.isNotEmpty && !isPhoneValid ? 'Enter valid phone number' : null;
      _passwordError = password.isNotEmpty && !isPasswordValid ? 'Minimum 6 characters' : null;
      _dobError = _selectedDate != null && !isAgeValid ? 'Must be at least 18 years old' : null;
    });

    final isValid = isNameValid && isEmailValid && isPhoneValid && isPasswordValid && isAgeValid;

    if (isValid != _isButtonActive) {
      setState(() {
        _isButtonActive = isValid;
      });

      if (isValid && !_hasTriggeredHaptic) {
        KinHaptics.lightTap();
        _hasTriggeredHaptic = true;
      } else if (!isValid) {
        _hasTriggeredHaptic = false;
      }
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDateOfBirth() async {
    KinHaptics.stateChange();
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? eighteenYearsAgo,
      firstDate: hundredYearsAgo,
      lastDate: now,
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
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
      _validateInputs();
    }
  }

  void _showCountrySelector() {
    KinHaptics.stateChange();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Select Caribbean Region',
                style: AppTheme.headingStyle(fontSize: 18),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: kCaribbeanCountries.length,
                itemBuilder: (context, index) {
                  final country = kCaribbeanCountries[index];
                  final isSelected = country.code == _selectedCountry.code;
                  return ListTile(
                    leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(country.name, style: AppTheme.bodyStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(country.dialCode, style: AppTheme.dataStyle(color: Colors.grey[600], fontSize: 14)),
                    selected: isSelected,
                    selectedTileColor: AppColors.primaryTeal.withValues(alpha: 0.08),
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                      Navigator.pop(context);
                      _validateInputs();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (!_isButtonActive || _isLoading) return;
    KinHaptics.lightTap();

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: '${_selectedCountry.dialCode} ${_phoneController.text.trim()}',
      );

      if (mounted) {
        setState(() => _isLoading = false);
        widget.onNext({
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': '${_selectedCountry.dialCode} ${_phoneController.text.trim()}',
          'country_of_residence': _selectedCountry.name,
          'nationality': _selectedCountry.name,
          'date_of_birth': _dobController.text.trim(),
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.parseAuthError(e))),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
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
                      'Personal & Contact Details',
                      style: AppTheme.headingStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kinInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your legal name, email, contact phone, and date of birth.',
                      style: AppTheme.bodyStyle(
                        fontSize: 14,
                        color: AppColors.kinInk.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 1. Full Name Input
                    Text('FULL LEGAL NAME', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _fullNameController,
                      focusNode: _fullNameFocus,
                      textCapitalization: TextCapitalization.words,
                      style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'e.g. Marcus Garvey',
                        errorText: _nameError,
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryTeal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                      ),
                      onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                    ),

                    const SizedBox(height: 20),

                    // 2. Email Address Input
                    Text('EMAIL ADDRESS', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'name@domain.com',
                        errorText: _emailError,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryTeal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                      ),
                      onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                    ),

                    const SizedBox(height: 20),

                    // 3. Phone Input with Caribbean Country Selector
                    Text('PHONE NUMBER', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _showCountrySelector,
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 4),
                                Text(_selectedCountry.dialCode, style: AppTheme.dataStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            keyboardType: TextInputType.phone,
                            style: AppTheme.dataStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: '876-5432',
                              errorText: _phoneError,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 4. Password Input
                    Text('PASSWORD', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Minimum 6 characters',
                        errorText: _passwordError,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryTeal),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Date of Birth with Native Calendar Picker
                    Text('DATE OF BIRTH', style: AppTheme.labelStyle(fontSize: 11, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectDateOfBirth,
                      borderRadius: BorderRadius.circular(16),
                      child: IgnorePointer(
                        child: TextField(
                          controller: _dobController,
                          style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            errorText: _dobError,
                            prefixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryTeal),
                            suffixIcon: const Icon(Icons.edit_calendar_outlined, color: AppColors.primaryTeal),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                          ),
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
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(
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
