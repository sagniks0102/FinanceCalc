import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';
import '../widgets/banner_ad_widget.dart';
import 'frsb_calculator.dart';
import 'sgb_calculator.dart';
import 'b54ec_calculator.dart';

class BondsOverviewScreen extends StatelessWidget {
  const BondsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance.updateListener,
      builder: (_, __) => Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.text.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: context.text, size: 20),
            ),
          ),
          title: Text('Bonds Overview', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _bondCard(
                context,
                title: 'Sovereign Gold Bonds (SGB)',
                subtitle: 'Government securities denominated in grams of gold.',
                interest: '2.50% p.a.',
                payout: 'Semi-Annually',
                lockin: '8 Years (Exit option from 5th year)',
                tax: 'Tax-free Capital Gains on maturity',
                color: const Color(0xFF059669),
                calculatorScreen: const SGBCalculatorScreen(),
              ),
              const SizedBox(height: 16),
              _bondCard(
                context,
                title: 'Floating Rate Savings Bonds (FRSB)',
                subtitle: 'Government taxable bonds with interest rates changing semi-annually.',
                interest: '8.05% p.a. (Current)',
                payout: 'Semi-Annually (Jan & July)',
                lockin: '7 Years',
                tax: 'Fully taxable under your income slab',
                color: const Color(0xFFDC2626),
                calculatorScreen: const FRSBCalculatorScreen(),
              ),
              const SizedBox(height: 16),
              _bondCard(
                context,
                title: '54EC Capital Gains Bonds',
                subtitle: 'Exempt long-term capital gains tax on the sale of land/building.',
                interest: '5.25% p.a.',
                payout: 'Annually',
                lockin: '5 Years',
                tax: 'Principal tax-exempt, interest is taxable',
                color: const Color(0xFF4F46E5),
                calculatorScreen: const B54ECCalculatorScreen(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: Color(0xFF0D9488), size: 24),
            const SizedBox(width: 10),
            Text(
              'Government & Tax Savings Bonds',
              style: TextStyle(color: context.text, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Government bonds offer high safety, stable returns, and attractive tax exemptions. Compare them below and tap on any to use its custom calculator.',
          style: TextStyle(color: context.textSub, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );

  Widget _bondCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String interest,
    required String payout,
    required String lockin,
    required String tax,
    required Color color,
    required Widget calculatorScreen,
  }) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top colored header stripe
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: context.text, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: context.textSub, fontSize: 11),
              ),
              const SizedBox(height: 14),
              _bondDetailRow(context, Icons.percent_rounded, 'Interest Rate', interest, color),
              _bondDetailRow(context, Icons.payment_rounded, 'Payout Mode', payout, color),
              _bondDetailRow(context, Icons.lock_clock_rounded, 'Lock-in Period', lockin, color),
              _bondDetailRow(context, Icons.gavel_rounded, 'Tax Treatment', tax, color),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => calculatorScreen),
                    );
                  },
                  icon: const Icon(Icons.calculate_rounded, size: 16),
                  label: const Text('Open Calculator'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withOpacity(0.1),
                    foregroundColor: color,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bondDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(color: context.textSub, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: context.text, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
