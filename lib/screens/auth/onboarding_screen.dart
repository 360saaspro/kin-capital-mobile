import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kin_bounceable.dart';
import '../kyc/kyc_flow_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onGetStarted(BuildContext context) async {
    await AuthService.instance.signOut();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycFlowScreen()),
      );
    }
  }

  void _onLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Desktop Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
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
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _onLogin(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                foregroundColor: AppColors.kinInk,
                              ),
                              child: Text(
                                'Log in',
                                style: AppTheme.bodyStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _onGetStarted(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Get started',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Two-Column Hero
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1150),
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left Column: Hero & Value Props
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primaryTeal.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primaryTeal),
                                        const SizedBox(width: 6),
                                        Text(
                                          'INSTANT CROSS-BORDER RAILS',
                                          style: AppTheme.labelStyle(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Send money home\nin seconds.',
                                    style: AppTheme.headingStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'The reliable, secure, and warm way to support your loved ones across the ocean. Bank-grade security, real FX rates, and instant transfers to Jamaica, Trinidad, Barbados & beyond.',
                                    style: AppTheme.bodyStyle(
                                      fontSize: 15,
                                      color: AppColors.kinInk.withValues(alpha: 0.7),
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Feature highlight rows
                                  _buildFeatureItem(
                                    icon: Icons.bolt_rounded,
                                    iconBg: AppColors.primaryTeal.withValues(alpha: 0.1),
                                    iconColor: AppColors.primaryTeal,
                                    title: 'Direct-to-Bank & Mobile Wallets',
                                    subtitle: 'Funds delivered within seconds to local accounts.',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildFeatureItem(
                                    icon: Icons.currency_exchange,
                                    iconBg: const Color(0xFFFF6B5A).withValues(alpha: 0.12),
                                    iconColor: const Color(0xFFD63C2A),
                                    title: 'Transparent, Fair Exchange Rates',
                                    subtitle: 'Zero hidden fees with market-leading rates in JMD, TTD, BBD, USD & GBP.',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildFeatureItem(
                                    icon: Icons.verified_user_rounded,
                                    iconBg: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                    iconColor: const Color(0xFF2E7D32),
                                    title: 'FCA Authorised & Safeguarded',
                                    subtitle: 'Client funds segregated in regulated tier-1 institutional accounts.',
                                  ),

                                  const SizedBox(height: 16),
                                  // Social proof stars
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Trusted by 20,000+ Caribbean diaspora families',
                                        style: AppTheme.bodyStyle(
                                          fontSize: 13,
                                          color: AppColors.kinInk.withValues(alpha: 0.65),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 48),

                            // Right Column: Interactive Card
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 420),
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE2EBE7), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.kinInk.withValues(alpha: 0.06),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryTeal.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'DIGITAL ONBOARDING',
                                          textAlign: TextAlign.center,
                                          style: AppTheme.labelStyle(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.0,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Experience banking\nbuilt for home.',
                                        style: AppTheme.headingStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Open your multi-currency account in 3 minutes.',
                                        style: AppTheme.bodyStyle(
                                          fontSize: 13,
                                          color: AppColors.kinInk.withValues(alpha: 0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 18),

                                      // Primary CTA
                                      KinBounceable(
                                        onTap: () => _onGetStarted(context),
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryTeal,
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryTeal.withValues(alpha: 0.3),
                                                blurRadius: 14,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Get started',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Secondary CTA
                                      OutlinedButton(
                                        onPressed: () => _onLogin(context),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primaryTeal,
                                          side: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.3), width: 1.5),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          'I have an account',
                                          style: AppTheme.bodyStyle(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Regulatory security note
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7FAF8),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE5EDE8)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.gpp_good_outlined, size: 18, color: AppColors.primaryTeal),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'FCA Authorised • Client funds safeguarded in segregated accounts',
                                                style: AppTheme.bodyStyle(
                                                  fontSize: 11,
                                                  color: AppColors.kinInk.withValues(alpha: 0.65),
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.25,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Desktop Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
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
                            Text(
                              'Powered by Kin Capital Rails',
                              style: AppTheme.bodyStyle(
                                fontSize: 11.5,
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.headingStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.bodyStyle(
                  fontSize: 12.5,
                  color: AppColors.kinInk.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE / TABLET LAYOUT ====================
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3F5F5), // Faded light gray
            Colors.white,       // White
            Color(0xFFD5EBE7), // Faded primary green
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/kin_logo.png',
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      Text(
                        'Send money home in seconds.',
                        style: AppTheme.headingStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The reliable, secure, and warm\nway to support your loved ones\nacross the ocean.',
                        style: AppTheme.bodyStyle(
                          fontSize: 18,
                          color: AppColors.kinInk.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      KinBounceable(
                        onTap: () => _onGetStarted(context),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryTeal.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Get started',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => _onLogin(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                        ),
                        child: Text(
                          'I have an account',
                          style: AppTheme.bodyStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gpp_good_outlined, size: 16, color: AppColors.kinInk),
                            const SizedBox(width: 8),
                            Text(
                              'SECURE & REGULATED',
                              style: AppTheme.labelStyle(
                                color: AppColors.kinInk,
                                letterSpacing: 1.2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authorised by the FCA. Your money is\nsafeguarded in segregated accounts.',
                        style: AppTheme.bodyStyle(
                          fontSize: 13,
                          color: AppColors.kinInk.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}