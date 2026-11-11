import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kardex/screens/K2-Welcome.dart';
import 'package:kardex/widgets/kardex_logo.dart';

class K1SplashScreen extends StatefulWidget {
  const K1SplashScreen({super.key});

  @override
  State<K1SplashScreen> createState() => _K1SplashScreenState();
}

class _K1SplashScreenState extends State<K1SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const K2WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToWelcome() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const K2WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToWelcome,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F5),
        body: SafeArea(
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  // Center Content: Logo, KARDEX, Tagline
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      const KardexLogo(size: 64),
                      const SizedBox(height: 24),
                      // KARDEX text
                      const Text(
                        'KARDEX',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      const Text(
                        'Every renewal, reconsidered.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  // Bottom Tagline
                  const Text(
                    'A QUIETER WAY TO MANAGE MONEY',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500,
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
}
