import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class SCSSCalculatorScreen extends StatefulWidget {
  const SCSSCalculatorScreen({super.key});
  @override
  State<SCSSCalculatorScreen> createState() => _SCSSCalculatorScreenState();
}

class _SCSSCalculatorScreenState extends State<SCSSCalculatorScreen> {
  double _deposit = 500000;
  double _rate = 8.2;
  double _tenure = 5; // years

  static const Color _accent = Color(0xFF9333EA);

  // SCSS pays quarterly interest
  double get _quarterlyInterest => _deposit * (_rate / 100) / 4;
  double get _yearlyInterest => _deposit * (_rate / 100);
  double get _totalInterest => _yearlyInterest * _tenure;
  double get _maturity => _deposit + _totalInterest;

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
          title: Text('SCSS Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(child: Column(children: [
            _resultCard(), _sliders(), _breakdown(),
            const SizedBox(height: 16), _infoSection(), const SizedBox(height: 24),
          ])),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  Widget _resultCard() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFA855F7)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Maturity Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_maturity), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Deposit', AppSettings.instance.formatShort(_deposit)),
        _vDiv(), _stat('Total Interest', AppSettings.instance.formatShort(_totalInterest)),
        _vDiv(), _stat('Quarterly\nPayout', AppSettings.instance.formatShort(_quarterlyInterest)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Deposit Amount', value: _deposit, min: 1000, max: 3000000, divisions: 299, color: _accent, minLabel: '₹1K', maxLabel: '₹30L', isRupee: true, onChanged: (v) => setState(() => _deposit = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Interest Rate (% p.a.)', value: _rate, min: 5, max: 12, divisions: 70, color: const Color(0xFF059669), minLabel: '5%', maxLabel: '12%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Tenure (Years)', value: _tenure, min: 5, max: 8, divisions: 3, color: const Color(0xFF6366F1), minLabel: '5 yrs', maxLabel: '8 yrs', suffix: ' yrs', onChanged: (v) => setState(() => _tenure = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Deposit amount', AppSettings.instance.formatRupee(_deposit, noDecimals: true), context.text),
      ('Interest rate', '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Tenure', '${_tenure.toInt()} years', context.text),
      ('Quarterly interest payout', AppSettings.instance.formatRupee(_quarterlyInterest, noDecimals: true), const Color(0xFF9333EA)),
      ('Yearly interest', AppSettings.instance.formatRupee(_yearlyInterest, noDecimals: true), const Color(0xFF9333EA)),
      ('Total interest earned', AppSettings.instance.formatRupee(_totalInterest, noDecimals: true), const Color(0xFF059669)),
      ('Maturity amount', AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SCSS Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
        const SizedBox(height: 10),
        ...rows.map((r) => Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub))),
            Text(r.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: r.$3)),
          ]),
        )),
      ]),
    ));
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About SCSS', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is SCSS?', blocks: [
      InfoBlock.paragraph('Senior Citizens Savings Scheme (SCSS) is a government-backed savings scheme for individuals aged 60+. It offers regular quarterly income with one of the highest interest rates.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Eligibility: 60+ years (55+ for retired defense/govt employees)',
        'Max deposit: ₹30 lakh (increased from ₹15L in Budget 2023)',
        'Tenure: 5 years, extendable by 3 years',
        'Interest paid quarterly (Apr, Jul, Oct, Jan)',
        'Tax benefit under Section 80C up to ₹1.5 lakh',
        'TDS applicable if interest > ₹50,000/year',
        'Current rate: 8.2% p.a. (Q1 FY 2024-25)',
      ]),
    ]),
  ]);
}
