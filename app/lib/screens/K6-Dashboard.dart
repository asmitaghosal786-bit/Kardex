import 'package:flutter/material.dart';
import 'package:kardex/screens/K12-Subscriptions.dart';
import 'package:kardex/screens/K13-Profile.dart';
import 'package:kardex/screens/K7-Insights.dart';
import 'package:kardex/screens/K9-Reports.dart';
import 'package:kardex/widgets/kardex_logo.dart';

class K6DashboardScreen extends StatefulWidget {
  const K6DashboardScreen({super.key});

  @override
  State<K6DashboardScreen> createState() => _K6DashboardScreenState();
}

class _K6DashboardScreenState extends State<K6DashboardScreen> {
  int _currentIndex = 0;

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
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    const Text(
                      'WELCOME, USER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sunday, 11 October',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Monthly Recurring Spending Section
                    const Text(
                      'MONTHLY RECURRING SPENDING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF777777),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₹4,280',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Based on currently available subscription and payment data.\n8 active · INR.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE5E5DF), thickness: 1),
                    const SizedBox(height: 16),

                    // Projected Monthly Savings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Projected monthly savings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                        ),
                        Text(
                          '₹650',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE5E5DF), thickness: 1),
                    const SizedBox(height: 20),

                    // Recommended to Cancel Header & Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended to Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Calendar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const K7InsightsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Insights',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subscription List Items
                    _buildSubscriptionItem(
                      initial: 'D',
                      name: 'Dropbox Plus',
                      date: '14 Oct',
                      amount: '₹999',
                      status: 'In 3 days',
                      statusColor: const Color(0xFF1B4332),
                    ),
                    const SizedBox(height: 16),
                    _buildSubscriptionItem(
                      initial: 'S',
                      name: 'Spotify',
                      date: '16 Oct',
                      amount: '₹119',
                      status: 'Active',
                      statusColor: const Color(0xFF777777),
                    ),
                    const SizedBox(height: 16),
                    _buildSubscriptionItem(
                      initial: 'Y',
                      name: 'YouTube Premium',
                      date: '18 Oct',
                      amount: '₹149',
                      status: 'Active',
                      statusColor: const Color(0xFF777777),
                    ),
                    const SizedBox(height: 16),

                    // See All Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'SEE ALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

  Widget _buildSubscriptionItem({
    required String initial,
    required String name,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          // Initial Circle Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          // Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // VIEW button
          Text(
            'VIEW',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const K12SubscriptionsScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const K9ReportsScreen()),
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
