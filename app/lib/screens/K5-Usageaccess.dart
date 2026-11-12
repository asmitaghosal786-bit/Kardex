import 'package:flutter/material.dart';
import 'package:kardex/screens/K6-Dashboard.dart';
import 'package:kardex/services/guardian_api.dart';
import 'package:kardex/services/usage_access.dart';

class K5UsageAccessScreen extends StatefulWidget {
  const K5UsageAccessScreen({super.key});

  @override
  State<K5UsageAccessScreen> createState() => _K5UsageAccessScreenState();
}

class _K5UsageAccessScreenState extends State<K5UsageAccessScreen>
    with WidgetsBindingObserver {
  bool _hasAccess = false;
  bool _consented = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAccess();
    }
  }

  Future<void> _refreshAccess() async {
    final access = await UsageAccess.hasAccess();
    if (mounted) setState(() => _hasAccess = access);
  }

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

                    // Status Text
                    Text(
                      _hasAccess ? 'Granted · measured usage is available' : 'Not granted · no usage collected',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Card: No usage data yet
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
                              Icons.lock_outline,
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
                                  'No usage data yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Until you explicitly grant access in Android Settings, all usage insights remain unavailable. Manual usage is still possible.',
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
                    TextButton.icon(
                      onPressed: () async {
                        final controller = TextEditingController();
                        final minutes = await showDialog<double>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Enter usage manually'),
                            content: TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Minutes used in the latest period'),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, double.tryParse(controller.text)),
                                child: const Text('Save manual usage'),
                              ),
                            ],
                          ),
                        );
                        if (minutes == null || !context.mounted) return;
                        await GuardianApi().addUsage(
                          usageMinutes: minutes,
                          periodStart: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
                          periodEnd: DateTime.now().toIso8601String(),
                          source: 'manual',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual usage saved')));
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Enter usage manually'),
                    ),
                    const SizedBox(height: 28),

                    // Set it up in Android Settings Section
                    const Text(
                      'Set it up in Android Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Numbered Steps
                    _buildStepItem('1.', 'Open Android Usage access settings.'),
                    const SizedBox(height: 12),
                    _buildStepItem('2.', 'Select KARDEX.'),
                    const SizedBox(height: 12),
                    _buildStepItem('3.', 'Enable "Permit usage access".'),
                    const SizedBox(height: 12),
                    _buildStepItem('4.', 'Return here to confirm the status.'),
                    const SizedBox(height: 24),

                    // Footer / Disclaimer Note
                    const Text(
                      'Menu names vary by Android version. No location, screen content or messages are read. Existing signal history can be deleted in Privacy.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_processing) return;
                    setState(() => _processing = true);
                    try {
                      if (!_consented) {
                        final consent = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Share usage signals?'),
                            content: const Text('KARDEX will read foreground time and launch signals only after you consent.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
                              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('I consent')),
                            ],
                          ),
                        );
                        if (consent != true) return;
                        if (mounted) setState(() => _consented = true);
                      }
                      if (!_hasAccess) {
                        await UsageAccess.requestAccess();
                        await _refreshAccess();
                        return;
                      }
                      final rows = await UsageAccess.query();
                      final end = DateTime.now();
                      final start = end.subtract(const Duration(days: 30));
                      for (final row in rows) {
                        await GuardianApi().addUsage(
                          usageMinutes: (row['usage_minutes'] as num).toDouble(),
                          periodStart: start.toIso8601String(),
                          periodEnd: end.toIso8601String(),
                          androidPackage: row['android_package'] as String,
                          source: 'measured',
                        );
                      }
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const K6DashboardScreen(),
                        ),
                      );
                    } catch (error) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
                      );
                    } finally {
                      if (mounted) setState(() => _processing = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _processing
                        ? 'Loading usage…'
                        : _hasAccess
                            ? 'Continue with measured usage'
                            : 'Set up usage access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: _processing
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const K6DashboardScreen(),
                        ),
                      );
                    },
              child: const Text('Continue with usage'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
