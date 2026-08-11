import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF0E6), // Light cream/peach at top
              Color(0xFFFFBBAA), // Warm coral/peach at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center leaf watermark
                  Icon(
                    Icons.eco_outlined,
                    size: 140,
                    color: AppColors.kinCoral.withValues(alpha: 0.15),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      // Official Logo
                      Image.asset(
                        'assets/images/kin_logo.png',
                        width: 140,
                      ),
                      const SizedBox(height: 48),
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
                      const SizedBox(height: 48), // Replaced Spacer to allow scrolling
                      
                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: AppColors.kinInk,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
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
                      
                      // Secure & Regulated Badge
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

      ),
    );
  }
}
