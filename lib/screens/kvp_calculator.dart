import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class KVPCalculatorScreen extends StatefulWidget {
  const KVPCalculatorScreen({super.key});
  @override
  State<KVPCalculatorScreen> createState() => _KVPCalculatorScreenState();
}

class _KVPCalculatorScreenState extends State<KVPCalculatorScreen> {
  double _investment = 100000;
  double _rate = 7.5;

  static const Color _accent = Color(0xFF7C3AED);

  // KVP doubles the money. Time to double = 72/rate (approx) or exact: ln(2)/ln(1+r/4)*4 quarters -> months
  double get _monthsToDouble {
    final r = _rate / 100 / 4; // quarterly compounding
    return (log(2) / log(1 + r)) * 3; // quarters * 3 months
  }
  int get _yearsToDouble => (_monthsToDouble / 12).floor();
  int get _remainingMonths => (_monthsToDouble % 12).round();
  double get _maturity => _investment * 2;
  double get _interest => _investment;

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
          title: Text('KVP Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Maturity Amount (Doubled)', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
        _vDiv(), _stat('Time to\nDouble', '$_yearsToDouble yr $_remainingMonths mo'),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Investment Amount', value: _investment, min: 1000, max: 5000000, divisions: 499, color: _accent, minLabel: '₹1K', maxLabel: '₹50L', isRupee: true, onChanged: (v) => setState(() => _investment = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Interest Rate (% p.a.)', value: _rate, min: 5, max: 12, divisions: 70, color: const Color(0xFF059669), minLabel: '5%', maxLabel: '12%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Investment', AppSettings.instance.formatRupee(_investment, noDecimals: true), context.text),
      ('Interest rate', '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Time to double', '$_yearsToDouble years $_remainingMonths months', context.text),
      ('Interest earned', AppSettings.instance.formatRupee(_interest, noDecimals: true), const Color(0xFF7C3AED)),
      ('Maturity amount', AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('KVP Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About KVP', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is KVP?', blocks: [
      InfoBlock.paragraph('Kisan Vikas Patra (KVP) is a government savings certificate that doubles your investment in a fixed period. Available at any post office, it\'s one of the safest investment options.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Min investment: ₹1,000 (no upper limit)',
        'Current rate: 7.5% p.a. (compounded annually)',
        'Money doubles in approximately 115 months',
        'Can be encashed after 2.5 years (with penalty)',
        'Can be transferred between post offices',
        'Available in denominations of ₹1,000, ₹5,000, ₹10,000, ₹50,000',
        'Interest is taxable — no tax benefit under 80C',
      ]),
    ]),
  ]);
}
