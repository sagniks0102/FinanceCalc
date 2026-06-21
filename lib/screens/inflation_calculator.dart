import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class InflationCalculatorScreen extends StatefulWidget {
  const InflationCalculatorScreen({super.key});
  @override
  State<InflationCalculatorScreen> createState() => _InflationCalculatorScreenState();
}

class _InflationCalculatorScreenState extends State<InflationCalculatorScreen> {
  double _currentCost = 100000;
  double _inflationRate = 6.0;
  double _years = 10;

  static const Color _accent = Color(0xFFD97706);

  double get _futureCost => _currentCost * pow(1 + _inflationRate / 100, _years);
  double get _inflationImpact => _futureCost - _currentCost;
  double get _purchasingPower => _currentCost / pow(1 + _inflationRate / 100, _years);

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
          title: Text('Inflation Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Future Cost', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_futureCost), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Current Cost', AppSettings.instance.formatShort(_currentCost)),
        _vDiv(), _stat('Inflation Impact', AppSettings.instance.formatShort(_inflationImpact)),
        _vDiv(), _stat('Purchasing\nPower Today', AppSettings.instance.formatShort(_purchasingPower)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Current Cost / Amount', value: _currentCost, min: 1000, max: 10000000, divisions: 199, color: _accent, minLabel: '₹1K', maxLabel: '₹1Cr', isRupee: true, onChanged: (v) => setState(() => _currentCost = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Expected Inflation Rate (%)', value: _inflationRate, min: 1, max: 20, divisions: 190, color: const Color(0xFFEF4444), minLabel: '1%', maxLabel: '20%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _inflationRate = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Time Period (Years)', value: _years, min: 1, max: 40, divisions: 39, color: const Color(0xFF6366F1), minLabel: '1 yr', maxLabel: '40 yrs', suffix: ' yrs', onChanged: (v) => setState(() => _years = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Current cost', AppSettings.instance.formatRupee(_currentCost, noDecimals: true), context.text),
      ('Inflation rate', '${_inflationRate.toStringAsFixed(1)}% p.a.', context.text),
      ('Time period', '${_years.toInt()} years', context.text),
      ('Future cost', AppSettings.instance.formatRupee(_futureCost, noDecimals: true), const Color(0xFFDC2626)),
      ('Cost increase', AppSettings.instance.formatRupee(_inflationImpact, noDecimals: true), const Color(0xFFDC2626)),
      ('Purchasing power of ₹${_currentCost.toInt()}', AppSettings.instance.formatRupee(_purchasingPower, noDecimals: true), const Color(0xFFD97706)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Inflation Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About Inflation', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is Inflation?', blocks: [
      InfoBlock.paragraph('Inflation is the rate at which the general level of prices for goods and services rises, eroding purchasing power. India\'s average inflation has been around 5-6% in recent years.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Takeaways', blocks: [
      InfoBlock.bullets([
        'Your investments must beat inflation to grow your real wealth',
        'At 6% inflation, prices double every ~12 years',
        'FD returns of 7% with 6% inflation = only 1% real return',
        'Equity/mutual funds historically beat inflation over long term',
      ]),
    ]),
  ]);
}
