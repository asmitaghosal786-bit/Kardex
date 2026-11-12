import 'package:flutter/material.dart';
import 'package:kardex/screens/K12-Subscriptions.dart';
import 'package:kardex/screens/K14-Privacy.dart';
import 'package:kardex/screens/K15-manageuseraccess.dart';
import 'package:kardex/screens/K4-connectpaypal.dart';
import 'package:kardex/screens/K6-Dashboard.dart';
import 'package:kardex/screens/K9-Reports.dart';
import 'package:kardex/screens/K16-Login.dart';
import 'package:kardex/widgets/kardex_logo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class K13ProfileScreen extends StatefulWidget {
  const K13ProfileScreen({super.key});

  @override
  State<K13ProfileScreen> createState() => _K13ProfileScreenState();
}

class _K13ProfileScreenState extends State<K13ProfileScreen> {
  int _currentIndex = 3; // Profile is index 3
  String _displayName = 'Kardex user';
  String _email = 'No email available';

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final name = metadata['full_name'] ?? metadata['name'] ?? metadata['display_name'];
    _displayName = name is String && name.trim().isNotEmpty ? name : (user?.email ?? _displayName);
    _email = user?.email ?? _email;
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const K16LoginScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not log out: $error')),
      );
    }
  }

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
                    'Profile',
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
                    // User Name & Email
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section 1: Recent Cancellations
                    const Text(
                      'Recent Cancellations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCancellationItem('Dropbox Plus · 22 Sep', '\$9.99 · confirmed demo'),
                    const SizedBox(height: 12),
                    _buildCancellationItem('Notion Plus · 24 Sep', '\$8.00 · +\$1.00'),
                    const SizedBox(height: 16),
                    const Text(
                      'PayPal sandbox synced 11 Oct, 09:32 UTC. Notion rose from \$7.00 to \$8.00 in September. Cloud recommendation is still pending; no \$6.50 saving realized.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section 2: Connected PayPal demo
                    const Text(
                      'Connected PayPal demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connected · last sync 11 Oct, 09:32 IST.\nRead available payments only. Merchant coverage can be incomplete; recurring detections need review. No PayPal partnership implied.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton('Reconnect / reauthorize'),
                    const SizedBox(height: 12),
                    _buildActionButton('Disconnect PayPal'),
                    const SizedBox(height: 32),

                    // Section 3: Android Usage Access
                    const Text(
                      'Android Usage Access',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Granted · explicit consent on 4 Oct. Foreground signals from this phone only; no paid-feature or cross-device certainty. No signals before consent. Android Settings controls access.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton('Manage Usage Access'),
                    const SizedBox(height: 12),
                    _buildActionButton('Enter usage manually'),
                    const SizedBox(height: 32),

                    // Section 4: Privacy and control
                    const Text(
                      'Privacy and control',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Data sources -> payments / manual entries / foreground signals. View the evidence used by each insight.\nConsent history -> view and withdraw.\nImported payment history -> delete separately.\nUsage history -> delete separately.\nExport and deletion stay under your control. Deleting KARDEX data does not cancel merchant subscriptions.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton('Privacy and data policy'),
                    const SizedBox(height: 12),
                    _buildActionButton('Delete demo account data'),
                    const SizedBox(height: 32),

                    // Section 5: Account security
                    const Text(
                      'Account security',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Authentication -> email + device lock.\nActive sessions -> Pixel 9, this device.\nLast reauthentication -> 6 Oct, 10:14 IST.\nSensitive exports and deletion require reauthentication. Device lock is not permission to change merchant plans.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton('Manage sessions'),
                    const SizedBox(height: 12),
                    _buildActionButton('Reauthenticate account'),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        child: const Text('Log out'),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section 6: Support
                    const Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help center -> data and billing FAQs.\nReport an issue -> exclude sensitive details.\nAbout KARDEX -> fictional demo, version 1.0.\n\nEvery renewal, reconsidered.\nAll accounts, transactions, merchants and actions here are fictional demo examples.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
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

  Widget _buildActionButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          if (label == 'Privacy and data policy') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const K14PrivacyScreen()),
            );
          } else if (label == 'Manage Usage Access') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const K15ManageUserAccessScreen()),
            );
          } else if (label == 'Reconnect / reauthorize') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const K4ConnectPaypalScreen()),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111111),
          side: const BorderSide(color: Color(0xFFD0D0C8), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCancellationItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111),
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
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const K6DashboardScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const K12SubscriptionsScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const K9ReportsScreen()),
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
