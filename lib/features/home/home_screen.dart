
import 'package:flutter/material.dart';

import '../../extensions/app_extensions.dart';
import '../../theme/app_theme.dart';
import '../card_scanner/card_scanner_screen.dart';
import '../passbook_scanner/passbook_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Card & Passbook Scanner',
                style: Theme.of(context).textTheme.displayMedium!,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF2D3561)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.document_scanner_rounded,
                    size: 56,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                addVerticalSpace(8),
                Text(
                  'What would you like to scan?',
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                addVerticalSpace(6),
                Text(
                  'Use OCR to extract structured data from physical documents.',
                  style: Theme.of(context).textTheme.displayMedium!,
                ),

                addVerticalSpace(28),
                _ScanOptionCard(
                  icon: Icons.credit_card_rounded,
                  title: 'Credit / Debit Card',
                  subtitle:
                  'Scan card number, expiry date and cardholder name using your camera.',
                  color: const Color(0xFF4F6EF7),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CardScannerScreen()),
                  ),
                ),
                addVerticalSpace(16),
                _ScanOptionCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Bank Passbook',
                  subtitle:
                  'Upload or scan a passbook page to extract account details and IFSC code.',
                  color: const Color(0xFF0EA5E9),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PassbookScannerScreen()),
                  ),
                ),

                addVerticalSpace(32),
                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppTheme.accent, size: 20),
                      addHorizontalSpace(12),
                      Expanded(
                        child: Text(
                          'All processing is done on-device. No data is sent to any server.',
                          style: Theme.of(context).textTheme.displayMedium!,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ScanOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              addHorizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    addVerticalSpace(16),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.displayMedium!,
                    ),
                  ],
                ),
              ),
              addHorizontalSpace(8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}