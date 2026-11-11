import 'package:flutter/material.dart';
import 'package:kardex/screens/K13-Profile.dart';
import 'package:kardex/screens/K6-Dashboard.dart';
import 'package:kardex/screens/K9-Reports.dart';
import 'package:kardex/widgets/kardex_logo.dart';

class K12SubscriptionsScreen extends StatefulWidget {
  const K12SubscriptionsScreen({super.key});

  @override
  State<K12SubscriptionsScreen> createState() => _K12SubscriptionsScreenState();
}

class _K12SubscriptionsScreenState extends State<K12SubscriptionsScreen> {
  int _currentIndex = 1; // Subscriptions is index 1
  String _selectedFilter = 'All';
  String _selectedSort = 'Renewal date';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _subscriptions = [
    {'initial': 'N', 'name': 'Netflix', 'category': 'Streaming', 'date': 'Renews 14 Oct', 'amount': '₹499 /mo', 'status': 'In 3 days', 'statusColor': const Color(0xFF1B4332)},
    {'initial': 'S', 'name': 'Spotify', 'category': 'Music', 'date': 'Renews 16 Oct', 'amount': '₹119 /mo', 'status': 'Active', 'statusColor': Color(0xFF777777)},
    {'initial': 'Y', 'name': 'YouTube Premium', 'category': 'Streaming', 'date': 'Renews 18 Oct', 'amount': '₹149 /mo', 'status': 'Active', 'statusColor': Color(0xFF777777)},
    {'initial': 'M', 'name': 'Microsoft 365', 'category': 'Productivity', 'date': 'Renews 20 Oct', 'amount': '₹489 /mo', 'status': 'Active', 'statusColor': Color(0xFF777777)},
    {'initial': 'D', 'name': 'Dropbox Plus', 'category': 'Cloud storage', 'date': 'Renews 22 Oct', 'amount': '₹999 /mo', 'status': 'Needs review', 'statusColor': const Color(0xFF1B4332)},
    {'initial': 'N', 'name': 'Notion Plus', 'category': 'Productivity', 'date': 'Renews 24 Oct', 'amount': '₹800 /mo', 'status': 'Active', 'statusColor': Color(0xFF777777)},
    {'initial': 'A', 'name': 'Adobe Photography', 'category': 'Software', 'date': 'Renews 26 Oct', 'amount': '₹888 /mo', 'status': 'Active', 'statusColor': Color(0xFF777777)},
    {'initial': 'G', 'name': 'Google One', 'category': 'Cloud storage', 'date': 'Renews 28 Oct', 'amount': '₹337 /mo', 'status': 'Active', 'statusColor': Color(0xFF777777)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: SafeArea(
        child: Column(
          children: [
            // Static Top Header Section (Top Bar, Summary Header, Search Bar, Filter Chips, Sort Chips)
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    children: [
                      const KardexLogo(size: 32),
                      const SizedBox(width: 10),
                      const Text(
                        'Subscriptions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Summary Header
                  const Text(
                    '8 ACTIVE SUBSCRIPTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF777777),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '₹4,280',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monthly · ₹51,360 annualized',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search your subscriptions',
                      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E5DF), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Active'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Needs review'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Trial'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Paused'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sort by section
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSortChip('Renewal date'),
                      const SizedBox(width: 8),
                      _buildSortChip('Cost'),
                      const SizedBox(width: 8),
                      _buildSortChip('Recently updated'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E5DF)),

            // Scrollable Content Below (Subscription List, Info Box, Footer)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subscription List
                    ..._subscriptions.map((sub) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildSubscriptionCard(sub),
                        )),

                    // Info Box at Bottom
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3EE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.info_outline,
                              color: Color(0xFF1B4332),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'A complete list, not an automatic verdict',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Recurring payments are reviewed detections or manual entries. Payment confirmation does not prove a service is useful. Trials and paused services are excluded from active totals.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Footer Note
                    const Center(
                      child: Text(
                        'All amounts in INR. Monthly frequency for these eight\nfictional services. Last reviewed 11 Oct 2026.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                          height: 1.4,
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

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B4332) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B4332) : const Color(0xFFE5E5DF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label) {
    bool isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF3EE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B4332) : const Color(0xFFE5E5DF),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> sub) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          // Initial Circle Icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                sub['initial'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name, Category, Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub['category'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub['date'],
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
                sub['amount'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub['status'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sub['statusColor'],
                ),
              ),
            ],
          ),
        ],
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
        } else if (index == 2) {
          Navigator.pushReplacement(
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
