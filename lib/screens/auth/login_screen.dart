import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome back',
                style: AppTheme.headingStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Log in to your Kin account to continue your financial journey.',
                style: AppTheme.bodyStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              
              _buildLabel('Email Address'),
              _buildTextField('camille@kin.app', Icons.email_outlined),
              
              const SizedBox(height: 24),
              
              _buildLabel('Password'),
              _buildPasswordField(),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Main Dashboard
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: 60,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Center(
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.face, size: 48, color: AppColors.primaryTeal),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to use Face ID',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildTextField(String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kinMistLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey[400],
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
