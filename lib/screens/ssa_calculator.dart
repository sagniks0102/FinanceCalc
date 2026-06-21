import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/breakdown_table.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class SSACalculatorScreen extends StatefulWidget {
  const SSACalculatorScreen({super.key});
  @override
  State<SSACalculatorScreen> createState() => _SSACalculatorScreenState();
}

class _SSACalculatorScreenState extends State<SSACalculatorScreen> {
  double _yearlyDeposit = 50000;
  double _rate = 8.2;
  double _girlAge = 5;

  static const Color _accent = Color(0xFF6366F1);

  // SSA: deposit for 15 years, maturity at 21 years from account opening
  int get _depositYears => 15;
  int get _maturityYears => (21 - _girlAge.toInt()).clamp(15, 21);

  double get _totalDeposited => _yearlyDeposit * _depositYears;

  double get _maturity {
    double balance = 0;
    final r = _rate / 100;
    for (int y = 1; y <= _maturityYears; y++) {
      if (y <= _depositYears) balance += _yearlyDeposit;
      balance *= (1 + r);
    }
    return balance;
  }

  double get _interest => _maturity - _totalDeposited;

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
          title: Text('SSA Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(child: Column(children: [
            _resultCard(), _sliders(), _breakdown(),
            const SizedBox(height: 12), _yearlyTable(),
            const SizedBox(height: 16), _infoSection(), const SizedBox(height: 24),
          ])),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  Widget _resultCard() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)])),
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
        _stat('Invested', AppSettings.instance.formatShort(_totalDeposited)),
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
    SliderInputCard(label: 'Yearly Deposit', value: _yearlyDeposit, min: 250, max: 150000, divisions: 149, color: _accent, minLabel: '₹250', maxLabel: '₹1.5L', isRupee: true, onChanged: (v) => setState(() => _yearlyDeposit = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Interest Rate (% p.a.)', value: _rate, min: 5, max: 12, divisions: 70, color: const Color(0xFF059669), minLabel: '5%', maxLabel: '12%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Girl\'s Age (years)', value: _girlAge, min: 0, max: 10, divisions: 10, color: const Color(0xFFDB2777), minLabel: '0', maxLabel: '10', suffix: ' yrs', onChanged: (v) => setState(() => _girlAge = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Yearly deposit', AppSettings.instance.formatRupee(_yearlyDeposit, noDecimals: true), context.text),
      ('Deposit period', '$_depositYears years', context.text),
      ('Total deposited', AppSettings.instance.formatRupee(_totalDeposited, noDecimals: true), context.text),
      ('Maturity period', '$_maturityYears years (age 21)', context.text),
      ('Interest earned', AppSettings.instance.formatRupee(_interest, noDecimals: true), const Color(0xFF059669)),
      ('Maturity amount', AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SSA Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _yearlyTable() {
    final Map<int, List<Map<String, dynamic>>> byYear = {};
    double balance = 0;
    final r = _rate / 100;
    final now = DateTime.now();
    for (int y = 1; y <= _maturityYears; y++) {
      final dep = y <= _depositYears ? _yearlyDeposit : 0.0;
      balance += dep;
      final interest = balance * r;
      balance += interest;
      byYear[now.year + y - 1] = [{'monthName': 'Year $y', 'interest': interest, 'balance': balance}];
    }
    return BreakdownTable(title: 'Yearly Schedule', accentColor: _accent,
      columns: [
        BreakdownColumn(title: 'Year', color: context.textSub, key: 'monthName', align: TextAlign.left, width: 60),
        BreakdownColumn(title: 'Interest', color: const Color(0xFF059669), key: 'interest'),
        BreakdownColumn(title: 'Balance', color: context.textSub, key: 'balance', align: TextAlign.right),
      ], byYear: byYear);
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About SSA', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is SSA?', blocks: [
      InfoBlock.paragraph('Sukanya Samriddhi Account (SSA) is a government-backed savings scheme under Beti Bachao, Beti Padhao for the girl child. It offers one of the highest interest rates among small savings schemes.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Account can be opened for girl child below 10 years',
        'Min deposit ₹250/year, Max ₹1.5 lakh/year',
        'Deposit required for first 15 years only',
        'Account matures when girl turns 21',
        'Partial withdrawal (50%) allowed after girl turns 18',
        'Tax-free under Section 80C (EEE status)',
        'Current rate: 8.2% p.a. (Q1 FY 2024-25)',
      ]),
    ]),
  ]);
}
