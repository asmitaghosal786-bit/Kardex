import 'package:flutter/material.dart';

class K8CancellationScreen extends StatelessWidget {
  const K8CancellationScreen({super.key});

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
                    'Confirm your choice',
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
                    // Awaiting your action tag
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 8, color: Color(0xFF1B4332)),
                        SizedBox(width: 6),
                        Text(
                          'Awaiting your action',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1B4332),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Main Headline
                    const Text(
                      'Cancel Dropbox plan.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card 1: Action summary
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
                          _buildDetailRow('Merchant', 'Dropbox · Plus'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Exact requested action', 'Cancel Plan'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Current charge', '₹999 / month'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Expected reduction', '₹999 / month'),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Execution route', 'Provider redirect'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: No supported direct integration
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
                              Icons.open_in_new,
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
                                  'No supported direct integration',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'KARDEX cannot cancel this merchant directly. Confirm opens the simulated Dropbox plan-management route. It does not confirm action.',
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

                    // Before you approve section
                    const Text(
                      'Before you approve',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check storage allowance, backups, shared folders, recovery features, taxes and regional pricing.',
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

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for Confirm and open provider
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
                        'Confirm and open provider',
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
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111111),
                        side: const BorderSide(color: Color(0xFFD0D0C8), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
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
