import 'package:flutter/material.dart';
import 'package:kardex/screens/K3-Createacc.dart';
import 'package:kardex/screens/K16-Login.dart';
import 'package:kardex/widgets/kardex_logo.dart';

class K2WelcomeScreen extends StatelessWidget {
  const K2WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar: Logo & KARDEX
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Logo
                            const KardexLogo(size: 32),
                            const SizedBox(width: 10),
                            const Text(
                              'KARDEX',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Main Headline
                        const Text(
                          'Take control of your recurring spending.',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Body Paragraphs
                        const Text(
                          'Available payments. Optional usage signals. Thoughtful AI. One clear view of what deserves to stay.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF555555),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Connect what you choose, or enter it yourself.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF555555),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Review every suggestion. Nothing changes without you.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF555555),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                    // Bottom Section: Footer & Buttons
                    Column(
                      children: [
                        const Center(
                          child: Text(
                            'Your data, your decisions. Always.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const K3CreateAccountScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4332),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Log In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const K16LoginScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B4332),
                              side: const BorderSide(
                                color: Color(0xFF1B4332),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
