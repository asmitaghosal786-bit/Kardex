import 'package:flutter/material.dart';
import 'package:kardex/screens/K11-Reports2.dart';
import 'package:kardex/screens/K12-Subscriptions.dart';
import 'package:kardex/screens/K13-Profile.dart';
import 'package:kardex/screens/K6-Dashboard.dart';
import 'package:kardex/widgets/kardex_logo.dart';

class K9ReportsScreen extends StatefulWidget {
  const K9ReportsScreen({super.key});

  @override
  State<K9ReportsScreen> createState() => _K9ReportsScreenState();
}

class _K9ReportsScreenState extends State<K9ReportsScreen> {
  int _currentIndex = 2; // Reports is index 2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  const KardexLogo(size: 32),
                  const SizedBox(width: 10),
                  const Text(
                    'Monthly report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Headline
                    const Text(
                      'Your detailed reports',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Transaction Explorer
                    const Text(
                      'Transaction Explorer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Explore your PayPal subscription payments, charges, and billing history.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const K11Reports2Screen(),
                          ),
                        );
                      },
                      child: Text(
                        'VIEW',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Spending Explorer
                    const Text(
                      'Spending Explorer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Analyze subscriptions, usage, and recurring spending with AI.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const K11Reports2Screen(),
                          ),
                        );
                      },
                      child: Text(
                        'VIEW',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xFFE5E5DF), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                  _buildNavItem(1, Icons.layers_outlined, Icons.layers, 'Subscriptions'),
                  _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart, 'Reports'),
                  _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const K6DashboardScreen()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const K12SubscriptionsScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const K13ProfileScreen()),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEBF3EE) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF777777),
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}
