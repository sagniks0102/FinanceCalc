import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class MISCalculatorScreen extends StatefulWidget {
  const MISCalculatorScreen({super.key});
  @override
  State<MISCalculatorScreen> createState() => _MISCalculatorScreenState();
}

class _MISCalculatorScreenState extends State<MISCalculatorScreen> {
  double _deposit = 500000;
  double _rate = 7.4;

  static const Color _accent = Color(0xFF059669);
  static const int _tenureYears = 5;

  double get _monthlyIncome => _deposit * (_rate / 100) / 12;
  double get _yearlyIncome => _deposit * (_rate / 100);
  double get _totalInterest => _yearlyIncome * _tenureYears;
  double get _maturity => _deposit; // MIS returns principal at maturity

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
          title: Text('MIS Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Monthly Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_monthlyIncome), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const TextSpan(text: ' /month', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500, height: 2.4)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Deposit', AppSettings.instance.formatShort(_deposit)),
        _vDiv(), _stat('Total Interest\n(5 yrs)', AppSettings.instance.formatShort(_totalInterest)),
        _vDiv(), _stat('Rate', '${_rate.toStringAsFixed(1)}%'),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Deposit Amount', value: _deposit, min: 1000, max: 900000, divisions: 179, color: _accent, minLabel: '₹1K', maxLabel: '₹9L', isRupee: true, onChanged: (v) => setState(() => _deposit = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Interest Rate (% p.a.)', value: _rate, min: 5, max: 12, divisions: 70, color: const Color(0xFF6366F1), minLabel: '5%', maxLabel: '12%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Deposit amount', AppSettings.instance.formatRupee(_deposit, noDecimals: true), context.text),
      ('Interest rate', '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Tenure', '5 years (fixed)', context.text),
      ('Monthly income', AppSettings.instance.formatRupee(_monthlyIncome, noDecimals: true), const Color(0xFF059669)),
      ('Yearly income', AppSettings.instance.formatRupee(_yearlyIncome, noDecimals: true), const Color(0xFF059669)),
      ('Total interest (5 yrs)', AppSettings.instance.formatRupee(_totalInterest, noDecimals: true), const Color(0xFF059669)),
      ('Principal returned at maturity', AppSettings.instance.formatRupee(_maturity, noDecimals: true), context.text),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MIS Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About MIS', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is Post Office MIS?', blocks: [
      InfoBlock.paragraph('Post Office Monthly Income Scheme (MIS) provides a steady monthly income. You deposit a lump sum, and receive interest every month. Principal is returned at maturity after 5 years.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Single account max: ₹9 lakh; Joint: ₹15 lakh',
        'Fixed tenure of 5 years',
        'Interest credited monthly to savings account',
        'Premature withdrawal after 1 year (with penalty)',
        'Current rate: 7.4% p.a.',
        'No tax benefit — interest is fully taxable',
      ]),
    ]),
  ]);
}
