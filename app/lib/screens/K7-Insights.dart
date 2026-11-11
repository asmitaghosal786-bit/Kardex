import 'package:flutter/material.dart';
import 'package:kardex/screens/K8-Cancellation.dart';

class K7InsightsScreen extends StatefulWidget {
  const K7InsightsScreen({super.key});

  @override
  State<K7InsightsScreen> createState() => _K7InsightsScreenState();
}

class _K7InsightsScreenState extends State<K7InsightsScreen> {
  int? _selectedOption = 0; // 0 for Keep current, 1 for Cancel or manage, or null

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'INSIGHTS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI estimate tag
                    const Text(
                      'AI estimate · medium confidence',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Main Headline
                    const Text(
                      'Review your cloud storage plan.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'Dropbox Plus may be more than you need. This is a decision to review, not a change already made.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // The Evidence Section
                    const Text(
                      'The evidence',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Evidence Container / Box
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E5DF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEvidenceRow('Current plan', 'Plus · 2 TB · ₹999/mo'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          ),
                          _buildEvidenceRow('Storage entered by you', '38 GB · 8 Oct 2026'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          ),
                          _buildEvidenceRow('Android foreground', '12 min · 4–10 Oct'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Potential Reduction Section
                    const Text(
                      'POTENTIAL REDUCTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF777777),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₹650',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Per month · ₹7,800/year if available and retained',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Box: Before switching
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
                                  'Before switching',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Verify backup and sync needs, shared folders, recovery/version history, file limits, capacity, taxes and regional pricing. Moving files can take time. A lower plan may not exist for your account.',
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
                    const SizedBox(height: 28),

                    // Choose an option Section
                    const Text(
                      'Choose an option',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option 1
                    _buildOptionCard(
                      value: 0,
                      title: 'Keep current',
                      subtitle: 'Retain capacity and features. ₹999/month.',
                    ),
                    const SizedBox(height: 12),

                    // Option 2
                    _buildOptionCard(
                      value: 1,
                      title: 'Cancel or manage with provider',
                      subtitle: 'Review file retention and backups first. No universal direct cancellation.',
                    ),
                    const SizedBox(height: 32),

                    // Dismiss for now Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF111111),
                          side: const BorderSide(color: Color(0xFFD0D0C8), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Dismiss for now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Footer Note
                    const Text(
                      'No selection yet. Choosing a change opens a confirmation and provider route; no financial action happens automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF777777),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({required int value, required String title, required String subtitle}) {
    bool isSelected = _selectedOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
        if (value == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const K8CancellationScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B4332) : const Color(0xFFE5E5DF),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF888888),
                  width: isSelected ? 6.5 : 2.0,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
