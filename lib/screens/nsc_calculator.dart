import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class NSCCalculatorScreen extends StatefulWidget {
  const NSCCalculatorScreen({super.key});
  @override
  State<NSCCalculatorScreen> createState() => _NSCCalculatorScreenState();
}

class _NSCCalculatorScreenState extends State<NSCCalculatorScreen> {
  double _investment = 100000;
  double _rate = 7.7;

  static const Color _accent = Color(0xFFDB2777);
  static const int _tenure = 5;

  // NSC: compounded annually but reinvested (not paid out)
  double get _maturity => _investment * pow(1 + _rate / 100, _tenure);
  double get _interest => _maturity - _investment;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance.updateListener,
      builder: (_, __) => Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(backgroundColor: context.bg, elevation: 0,
          leading: GestureDetector(onTap: () => Navigator.maybePop(context),
            child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: context.text.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: context.text, size: 20))),
          title: Text('NSC Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(child: Column(children: [
            _resultCard(), _sliders(), _breakdown(), _yearlyGrowth(),
            const SizedBox(height: 16), _infoSection(), const SizedBox(height: 24),
          ])),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  Widget _resultCard() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFEC4899)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Maturity Amount (5 Years)', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_maturity), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Invested', AppSettings.instance.formatShort(_investment)),
        _vDiv(), _stat('Interest', AppSettings.instance.formatShort(_interest)),
        _vDiv(), _stat('Rate', '${_rate.toStringAsFixed(1)}%'),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10)), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Investment Amount', value: _investment, min: 1000, max: 5000000, divisions: 199, color: _accent, minLabel: '₹1K', maxLabel: '₹50L', isRupee: true, onChanged: (v) => setState(() => _investment = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Interest Rate (% p.a.)', value: _rate, min: 5, max: 12, divisions: 70, color: const Color(0xFF059669), minLabel: '5%', maxLabel: '12%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Investment', AppSettings.instance.formatRupee(_investment, noDecimals: true), context.text),
      ('Interest rate', '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Tenure', '5 years (fixed)', context.text),
      ('Interest earned', AppSettings.instance.formatRupee(_interest, noDecimals: true), const Color(0xFFDB2777)),
      ('Maturity amount', AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NSC Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
        const SizedBox(height: 10),
        ...rows.map((r) => Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub)),
            Text(r.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: r.$3)),
          ]),
        )),
      ]),
    ));
  }

  Widget _yearlyGrowth() {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Year-wise Growth', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
        const SizedBox(height: 10),
        ...List.generate(_tenure, (i) {
          final y = i + 1;
          final bal = _investment * pow(1 + _rate / 100, y);
          final yearInterest = _investment * pow(1 + _rate / 100, y) - _investment * pow(1 + _rate / 100, y - 1);
          return Container(padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Year $y', style: TextStyle(fontSize: 12, color: context.textSub, fontWeight: FontWeight.w600)),
              Text('Interest: ${AppSettings.instance.formatRupee(yearInterest, noDecimals: true)}', style: TextStyle(fontSize: 11, color: _accent)),
              Text(AppSettings.instance.formatRupee(bal, noDecimals: true), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.text)),
            ]),
          );
        }),
      ]),
    ));
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About NSC', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is NSC?', blocks: [
      InfoBlock.paragraph('National Savings Certificate (NSC) is a fixed-income investment scheme by the Government of India, available at post offices. Interest is compounded annually but paid at maturity.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Fixed tenure: 5 years',
        'Min investment: ₹1,000 (no upper limit)',
        'Interest compounded annually, paid at maturity',
        'Tax benefit under Section 80C up to ₹1.5 lakh',
        'Accrued interest (years 1-4) also qualifies for 80C reinvestment',
        'Only 5th year interest is taxable',
        'Current rate: 7.7% p.a.',
        'Can be pledged as collateral for loans',
      ]),
    ]),
  ]);
}
