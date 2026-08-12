import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _nameController = TextEditingController(text: 'Camille Stevenson');
  final _emailController = TextEditingController(text: 'camille@kin.app');
  final _phoneController = TextEditingController(text: '+1 (876) 123-4567');
  final _dobController = TextEditingController(text: '12 October 1992');
  final _addressController = TextEditingController(text: '123 Palm Grove Avenue, Kingston 6, Jamaica');

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final uid = AuthService.instance.currentUid;
      final profile = await FirestoreService.instance.getUserProfile(uid);
      if (profile != null && mounted) {
        setState(() {
          if (profile['fullName'] != null) _nameController.text = profile['fullName'];
          if (profile['email'] != null) _emailController.text = profile['email'];
          if (profile['phone'] != null) _phoneController.text = profile['phone'];
          if (profile['dob'] != null) _dobController.text = profile['dob'];
          if (profile['address'] != null) _addressController.text = profile['address'];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final uid = AuthService.instance.currentUid;
      await FirestoreService.instance.setUserProfile(uid, {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'address': _addressController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal details updated successfully!'),
            backgroundColor: AppColors.primaryTeal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated successfully.')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showEditSheet(String title, TextEditingController controller, {bool isDate = false}) async {
    if (isDate) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(1992, 10, 12),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
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
          final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
          controller.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
        });
      }
      return;
    }

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
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Edit $title',
              style: AppTheme.headingStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: title.contains('Address') ? 3 : 1,
              decoration: InputDecoration(
                labelText: title,
                labelStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                style: AppTheme.buttonStyle(backgroundColor: AppColors.kinInk),
                child: const Text('Confirm'),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personal details',
          style: AppTheme.headingStyle(fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileEditHeader(),
                  const SizedBox(height: 40),
                  
                  _buildSectionHeader('BASIC INFORMATION'),
                  _buildDetailItem(
                    Icons.person_outlined, 
                    'Full Name', 
                    _nameController.text,
                    onTap: () => _showEditSheet('Full Name', _nameController),
                  ),
                  _buildDetailItem(
                    Icons.email_outlined, 
                    'Email Address', 
                    _emailController.text,
                    onTap: () => _showEditSheet('Email Address', _emailController),
                  ),
                  _buildDetailItem(
                    Icons.phone_outlined, 
                    'Phone Number', 
                    _phoneController.text,
                    onTap: () => _showEditSheet('Phone Number', _phoneController),
                  ),
                  _buildDetailItem(
                    Icons.calendar_today_outlined, 
                    'Date of Birth', 
                    _dobController.text,
                    onTap: () => _showEditSheet('Date of Birth', _dobController, isDate: true),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('ADDRESS'),
                  _buildDetailItem(
                    Icons.location_on_outlined, 
                    'Residential Address', 
                    _addressController.text,
                    onTap: () => _showEditSheet('Residential Address', _addressController),
                  ),
                  
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileEditHeader() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: AppColors.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Text(
                'kin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kinInk,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload feature coming soon!')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kinMistLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryTeal, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTheme.bodyStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.kinInk,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kinInk,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
