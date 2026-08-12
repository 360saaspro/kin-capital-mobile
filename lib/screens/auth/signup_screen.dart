import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/app_config.dart';
import 'kyc_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _agreeTerms = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Generate a deterministic entity ID from the user's name.
  String _generateEntityId(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    final suffix = DateTime.now().millisecondsSinceEpoch % 10000;
    return '${slug}_${suffix}';
  }

  void _onCreateAccount() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service and Privacy Policy.')),
      );
      return;
    }

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final entityId = _generateEntityId(name);

    // Store entity ID globally for the app session
    AppConfig().entityId = entityId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycVerificationScreen(
          entityId: entityId,
          fullName: name,
          email: email,
          phone: phone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Create account',
                  style: AppTheme.headingStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Join thousands of people across the Caribbean managing their money with Kin.',
                  style: AppTheme.bodyStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                _buildLabel('Full Name'),
                _buildTextField(_nameCtrl, 'e.g. Camille Stevenson', Icons.person_outline),

                const SizedBox(height: 20),

                _buildLabel('Email Address'),
                _buildTextField(_emailCtrl, 'e.g. camille@kin.app', Icons.email_outlined),

                const SizedBox(height: 20),

                _buildLabel('Phone Number'),
                _buildTextField(_phoneCtrl, 'e.g. +1 (876) 123-4567', Icons.phone_outlined),

                const SizedBox(height: 32),

                _buildTermsCheckbox(),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _onCreateAccount,
                    style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
                    child: const Text('Create Account',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.bodyStyle(color: Colors.grey[600]),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                                color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: ctrl,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: AppColors.primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[600]),
              children: [
                const TextSpan(text: 'By signing up, I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                      color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                      color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}