import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../services/app_config.dart';
import '../main_screen.dart';
import '../admin/admin_panel_screen.dart';
import 'forgot_password_screen.dart';
import 'onboarding_screen.dart';
import '../kyc/kyc_flow_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? entityId;
  const LoginScreen({super.key, this.entityId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entityId != null && widget.entityId!.isNotEmpty) {
      _emailController.text = widget.entityId!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  void _autofillDemo(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    final input = _emailController.text.trim();
    final password = _passwordController.text;

    if (input.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // If it looks like a standard email address, authenticate with Firebase Auth
      if (input.contains('@')) {
        final isAdmin = input.toLowerCase() == 'admin@kin.app';
        final isDemoUser = input.toLowerCase() == 'mk@gmail.com' ||
            input.toLowerCase() == 'camille@kin.app' ||
            input.toLowerCase() == 'camarlo@icloud.com';
        final authPassword = password.isNotEmpty 
            ? password 
            : (isAdmin ? 'Admin123!' : (isDemoUser ? 'Password123!' : 'Password123!'));
        try {
          await AuthService.instance.login(email: input, password: authPassword);
        } catch (e) {
          if (isAdmin) {
            try {
              // Auto-provision the admin account if it doesn't exist or credentials fail
              await AuthService.instance.signUp(
                email: input,
                password: authPassword,
                fullName: 'Kin Admin',
                phone: '+1 (800) 555-0000',
              );
              await AuthService.instance.login(email: input, password: authPassword);
            } catch (signUpError) {
              if (signUpError.toString().toLowerCase().contains('already exists')) {
                throw Exception('Incorrect password for admin account.');
              }
              rethrow;
            }
          } else if (isDemoUser) {
            try {
              // Auto-provision demo user account if it doesn't exist
              final name = input.toLowerCase() == 'mk@gmail.com' 
                  ? 'Marcus Johnson' 
                  : (input.toLowerCase() == 'camille@kin.app' ? 'Camille B.' : 'Camarlo Richards');
              await AuthService.instance.signUp(
                email: input,
                password: authPassword,
                fullName: name,
                phone: '+1 876 5689455',
              );
              final uid = AuthService.instance.currentUid;
              await FirestoreService.instance.setUserProfile(uid, {
                'balance': 3450.00,
                'kycStatus': 'verified',
                'fullName': name,
                'email': input,
                'role': 'user',
              });
              await AuthService.instance.login(email: input, password: authPassword);
            } catch (signUpError) {
              if (signUpError.toString().toLowerCase().contains('already exists')) {
                throw Exception('Incorrect password for demo user. Default password is Password123!');
              }
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      } else {
        // Fallback to Entity ID demo login
        AppConfig().entityId = input;
      }

      if (mounted) {
        final profile = await FirestoreService.instance.getUserProfile(AuthService.instance.currentUid);
        if (!mounted) return;
        final role = profile?['role'] ?? 'user';

        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AuthService.parseAuthError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 960;
          if (isDesktop) {
            return _buildDesktopLayout(context, constraints);
          }
          return _buildMobileLayout(context, constraints);
        },
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF4F8F6),
            Colors.white,
            Color(0xFFE6F2EE),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/kin_logo.png',
                        height: 34,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'CARIBBEAN DIGITAL BANK',
                          style: AppTheme.labelStyle(
                            color: AppColors.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _navigateBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.kinInk),
                    label: Text(
                      'Back to home',
                      style: AppTheme.bodyStyle(
                        color: AppColors.kinInk,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            // Centered Login Card
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2EBE7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kinInk.withValues(alpha: 0.06),
                          blurRadius: 36,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: _buildLoginForm(isDesktop: true),
                  ),
                ),
              ),
            ),

            // Desktop Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2026 Kin Capital. All rights reserved.',
                    style: AppTheme.bodyStyle(
                      fontSize: 11.5,
                      color: AppColors.kinInk.withValues(alpha: 0.5),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.gpp_good_outlined, size: 14, color: AppColors.primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        'Authorised by the FCA • Client funds segregated',
                        style: AppTheme.bodyStyle(
                          fontSize: 11.5,
                          color: AppColors.kinInk.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MOBILE / TABLET LAYOUT ====================
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.kinInk),
            onPressed: _navigateBack,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              child: _buildLoginForm(isDesktop: false),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGIN FORM ====================
  Widget _buildLoginForm({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          Image.asset(
            'assets/images/kin_logo.png',
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
        ],

        Text('Welcome back', style: AppTheme.headingStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Log in to your Kin account to continue your financial journey.',
          style: AppTheme.bodyStyle(fontSize: 15, color: Colors.grey[600]),
        ),

        const SizedBox(height: 24),

        // Quick Demo Accounts Chips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.primaryTeal),
                  const SizedBox(width: 6),
                  Text(
                    'QUICK DEMO SIGN-IN',
                    style: AppTheme.labelStyle(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.person_outline, size: 16, color: AppColors.primaryTeal),
                    label: const Text('User: mk@gmail.com'),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.25)),
                    onPressed: () => _autofillDemo('mk@gmail.com', 'Password123!'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.admin_panel_settings_outlined, size: 16, color: Color(0xFFD63C2A)),
                    label: const Text('Admin: admin@kin.app'),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: const Color(0xFFD63C2A).withValues(alpha: 0.25)),
                    onPressed: () => _autofillDemo('admin@kin.app', 'Admin123!'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Demo passwords autofill automatically (User: Password123! • Admin: Admin123!)',
                style: AppTheme.bodyStyle(
                  fontSize: 11.5,
                  color: AppColors.kinInk.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryCoral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.primaryCoral, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.primaryCoral, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        _buildLabel('Email Address'),
        _buildTextField(_emailController, 'e.g. mk@gmail.com', Icons.email_outlined),

        const SizedBox(height: 20),

        _buildLabel('Password'),
        _buildPasswordField(),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: AppTheme.buttonStyle(backgroundColor: AppColors.primaryTeal),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Log in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
          ],
        ),

        const SizedBox(height: 20),

        Center(
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.face_rounded, size: 44, color: AppColors.primaryTeal),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in with Face ID / Biometrics',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Don't have an account link
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KycFlowScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Get started',
                  style: AppTheme.bodyStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTheme.bodyStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE7), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primaryTeal.withValues(alpha: 0.6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE7), width: 1.5),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primaryTeal.withValues(alpha: 0.6), size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey[500],
              size: 20,
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