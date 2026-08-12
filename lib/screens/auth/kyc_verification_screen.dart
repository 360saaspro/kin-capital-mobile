import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/api_models.dart';
import 'biometric_setup_screen.dart';

class KycVerificationScreen extends StatefulWidget {
  final String entityId;
  final String fullName;
  final String email;
  final String phone;

  const KycVerificationScreen({
    super.key,
    required this.entityId,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Identity type
  String _identityType = 'national_id';
  final _identityNumberCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  bool _submitting = false;
  KycSubmitResponse? _result;
  String? _error;

  final _identityTypes = [
    ('national_id', 'National ID'),
    ('passport', 'Passport'),
    ('drivers_license', "Driver's Licence"),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill for demo
    _nationalityCtrl.text = 'Honduran';
    _countryCtrl.text = 'Honduras';
    _addressCtrl.text = '123 Calle Principal, San Pedro Sula';
    _dobCtrl.text = '1985-06-15';
  }

  @override
  void dispose() {
    _identityNumberCtrl.dispose();
    _dobCtrl.dispose();
    _nationalityCtrl.dispose();
    _addressCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await _api.kycSubmit(
        entityId: widget.entityId,
        fullName: widget.fullName,
        email: widget.email,
        phone: widget.phone,
        dateOfBirth: _dobCtrl.text.trim(),
        nationality: _nationalityCtrl.text.trim(),
        identityType: _identityType,
        identityNumber: _identityNumberCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        countryOfResidence: _countryCtrl.text.trim(),
      );
      setState(() {
        _result = result;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PASSED':
        return AppColors.primaryTeal;
      case 'PENDING_REVIEW':
        return Colors.orange;
      case 'FLAGGED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PASSED':
        return Icons.verified;
      case 'PENDING_REVIEW':
        return Icons.engineering;
      case 'FLAGGED':
        return Icons.warning_amber;
      default:
        return Icons.help_outline;
    }
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
        title: const Text(
          'Identity Verification',
          style: TextStyle(color: AppColors.kinInk, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _result != null ? _buildResult() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.gpp_good, color: AppColors.primaryTeal, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KYC Required',
                          style: AppTheme.bodyStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'We need to verify your identity before you can send money. '
                        'Your data is encrypted and securely stored.',
                        style: AppTheme.bodyStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Identity Type
          _buildLabel('Identity Document'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _identityType,
            items: _identityTypes.map((t) {
              return DropdownMenuItem(value: t.$1, child: Text(t.$2));
            }).toList(),
            onChanged: (v) => setState(() => _identityType = v!),
            decoration: _inputDecoration('Select document type', Icons.badge_outlined),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 20),

          // Identity Number
          _buildLabel('Document Number'),
          const SizedBox(height: 8),
          _buildTextField(_identityNumberCtrl, 'e.g. HN-12345678', Icons.numbers),
          const SizedBox(height: 20),

          // Date of Birth
          _buildLabel('Date of Birth'),
          const SizedBox(height: 8),
          _buildTextField(_dobCtrl, 'YYYY-MM-DD', Icons.calendar_today),
          const SizedBox(height: 20),

          // Nationality
          _buildLabel('Nationality'),
          const SizedBox(height: 8),
          _buildTextField(_nationalityCtrl, 'e.g. Honduran', Icons.flag_outlined),
          const SizedBox(height: 20),

          // Country of Residence
          _buildLabel('Country of Residence'),
          const SizedBox(height: 8),
          _buildTextField(_countryCtrl, 'e.g. Honduras', Icons.public),
          const SizedBox(height: 20),

          // Address
          _buildLabel('Residential Address'),
          const SizedBox(height: 8),
          _buildTextField(_addressCtrl, 'Street, City, Country', Icons.home_outlined),
          const SizedBox(height: 32),

          // Error
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_error!, style: TextStyle(color: Colors.red, fontSize: 13))),
                ],
              ),
            ),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitKyc,
              style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
              child: _submitting
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Verify Identity',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 24),

          // Privacy note
          Center(
            child: Text(
              'Your data is encrypted and never shared without your consent.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final r = _result!;
    final passed = r.status == 'PASSED';

    return Column(
      children: [
        // Status icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _statusColor(r.status).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_statusIcon(r.status), color: _statusColor(r.status), size: 64),
        ),
        const SizedBox(height: 24),

        // Status title
        Text(
          r.status == 'PASSED'
              ? 'Identity Verified'
              : r.status == 'PENDING_REVIEW'
                  ? 'Pending Review'
                  : 'Additional Review Required',
          style: AppTheme.headingStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          r.status == 'PASSED'
              ? 'Your identity has been verified successfully. You can now send money and access credit.'
              : r.status == 'PENDING_REVIEW'
                  ? 'Some checks need manual review. We will notify you when complete.'
                  : 'We could not verify your identity. Please contact support.',
          textAlign: TextAlign.center,
          style: AppTheme.bodyStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Checks
        if (r.checks.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text('Checks Passed',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...r.checks.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(c, style: TextStyle(fontSize: 13, color: Colors.green.shade800)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        // Flags
        if (r.flags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text('Flags',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...r.flags.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(f, style: TextStyle(fontSize: 13, color: Colors.orange.shade800)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        const SizedBox(height: 40),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BiometricSetupScreen()),
                (route) => false,
              );
            },
            style: AppTheme.buttonStyle(
              backgroundColor: passed ? AppColors.primaryTeal : Colors.grey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  passed ? 'Continue to Security Setup' : 'Continue Anyway',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
        if (!passed) ...[
          const SizedBox(height: 12),
          Text(
            'Limited functionality until verification is complete.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label,
          style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[400]),
      filled: true,
      fillColor: AppColors.kinMistLight.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}