import 'package:flutter/material.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';

class InterestRatesScreen extends StatelessWidget {
  const InterestRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(backgroundColor: context.bg, elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.maybePop(context),
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: context.text.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.arrow_back, color: context.text, size: 20))),
        title: Text('Interest Rates', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(context, 'Small Savings Schemes (Q1 FY 2024-25)', const Color(0xFF6366F1)),
          _rateCard(context, [
            ('Post Office Savings Account', '4.0%'),
            ('1 Year Time Deposit', '6.9%'),
            ('2 Year Time Deposit', '7.0%'),
            ('3 Year Time Deposit', '7.1%'),
            ('5 Year Time Deposit', '7.5%'),
            ('5 Year RD', '6.7%'),
            ('Monthly Income Scheme (MIS)', '7.4%'),
            ('National Savings Certificate (NSC)', '7.7%'),
            ('Public Provident Fund (PPF)', '7.1%'),
            ('Kisan Vikas Patra (KVP)', '7.5%'),
            ('Sukanya Samriddhi Account (SSA)', '8.2%'),
            ('Senior Citizens Savings (SCSS)', '8.2%'),
          ]),
          const SizedBox(height: 16),
          _header(context, 'Major Bank FD Rates (General)', const Color(0xFF059669)),
          _rateCard(context, [
            ('SBI', '6.50% - 7.10%'),
            ('HDFC Bank', '6.60% - 7.25%'),
            ('ICICI Bank', '6.50% - 7.10%'),
            ('Axis Bank', '6.50% - 7.10%'),
            ('Kotak Mahindra', '6.20% - 7.25%'),
            ('PNB', '6.50% - 7.25%'),
            ('Bank of Baroda', '6.50% - 7.15%'),
            ('Canara Bank', '6.50% - 7.25%'),
          ]),
          const SizedBox(height: 16),
          _header(context, 'RBI Policy Rate', const Color(0xFFDC2626)),
          _rateCard(context, [
            ('Repo Rate', '6.50%'),
            ('Reverse Repo Rate', '3.35%'),
            ('Bank Rate', '6.75%'),
            ('CRR', '4.50%'),
            ('SLR', '18.00%'),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Rates are indicative and subject to change. Always verify with the respective institution before investing.',
                style: TextStyle(color: context.textSub, fontSize: 12, height: 1.5),
              )),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _header(BuildContext context, String title, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.text))),
    ]),
  );

  Widget _rateCard(BuildContext context, List<(String, String)> rates) => Container(
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
    child: Column(children: rates.asMap().entries.map((e) {
      final isLast = e.key == rates.length - 1;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: context.border))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(e.value.$1, style: TextStyle(fontSize: 13, color: context.text))),
          const SizedBox(width: 12),
          Text(e.value.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
        ]),
      );
    }).toList()),
  );
}
