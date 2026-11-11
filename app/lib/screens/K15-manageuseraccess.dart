import 'package:flutter/material.dart';

class K15ManageUserAccessScreen extends StatelessWidget {
  const K15ManageUserAccessScreen({super.key});

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
                    'Usage Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
                    // Main Headline
                    const Text(
                      'Understand what you actually use.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Optional Android foreground signals can add context to renewal decisions. You decide whether to share them.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status tag
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 8, color: Color(0xFF1B4332)),
                        SizedBox(width: 6),
                        Text(
                          'Granted · simulated consent',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1B4332),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card: Usage Metrics
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E5DF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Consent enabled', '04 Oct 2026, 09:00'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Measurement period', '04–10 Oct 2026'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Netflix foreground', '2h 14m · 3 days'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Dropbox foreground', '12 min · 2 days'),
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          const Text(
                            'Inferred on this Android device only. These signals do not prove paid-feature use, background backups or activity on other devices.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF777777),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Control your consent Section
                    const Text(
                      'Control your consent',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Turn access off in Settings -> Apps -> Special app access -> Usage access -> KARDEX.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Menu names vary by Android version. No location, screen content or messages are read. Existing signal history can be deleted in Privacy.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Manage Android Usage Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111111),
                        side: const BorderSide(color: Color(0xFFD0D0C8), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Delete usage history',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildDetailRow(String label, String value) {
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
}
