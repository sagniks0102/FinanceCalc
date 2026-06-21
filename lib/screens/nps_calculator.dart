import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class NPSCalculatorScreen extends StatefulWidget {
  const NPSCalculatorScreen({super.key});
  @override
  State<NPSCalculatorScreen> createState() => _NPSCalculatorScreenState();
}

class _NPSCalculatorScreenState extends State<NPSCalculatorScreen> {
  double _monthly = 5000;
  double _rate = 10.0;
  double _currentAge = 30;
  double _retirementAge = 60;
  double _annuityPercent = 40;

  static const Color _accent = Color(0xFF6366F1);

  double get _years => _retirementAge - _currentAge;
  double get _totalInvested => _monthly * 12 * _years;
  double get _corpus {
    final r = _rate / 100 / 12;
    final n = _years * 12;
    if (r == 0) return _totalInvested;
    return _monthly * ((pow(1 + r, n) - 1) / r) * (1 + r);
  }
  double get _annuityCorpus => _corpus * _annuityPercent / 100;
  double get _lumpsum => _corpus - _annuityCorpus;
  double get _estimatedPension => _annuityCorpus * 0.06 / 12; // ~6% annuity rate

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
          title: Text('NPS Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Total Corpus at Retirement', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_corpus), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Invested', AppSettings.instance.formatShort(_totalInvested)),
        _vDiv(), _stat('Lumpsum\n(${(100 - _annuityPercent).toInt()}%)', AppSettings.instance.formatShort(_lumpsum)),
        _vDiv(), _stat('Est. Monthly\nPension', AppSettings.instance.formatShort(_estimatedPension)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Monthly Contribution', value: _monthly, min: 500, max: 100000, divisions: 199, color: _accent, minLabel: '₹500', maxLabel: '₹1L', isRupee: true, onChanged: (v) => setState(() => _monthly = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Expected Return Rate (% p.a.)', value: _rate, min: 5, max: 15, divisions: 100, color: const Color(0xFF059669), minLabel: '5%', maxLabel: '15%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Current Age', value: _currentAge, min: 18, max: 55, divisions: 37, color: const Color(0xFFD97706), minLabel: '18', maxLabel: '55', suffix: ' yrs', onChanged: (v) => setState(() => _currentAge = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Retirement Age', value: _retirementAge, min: 50, max: 75, divisions: 25, color: const Color(0xFFDC2626), minLabel: '50', maxLabel: '75', suffix: ' yrs', onChanged: (v) => setState(() => _retirementAge = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Annuity Purchase (%)', value: _annuityPercent, min: 40, max: 100, divisions: 60, color: const Color(0xFF7C3AED), minLabel: '40%', maxLabel: '100%', suffix: '%', onChanged: (v) => setState(() => _annuityPercent = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Monthly contribution', AppSettings.instance.formatRupee(_monthly, noDecimals: true), context.text),
      ('Investment period', '${_years.toInt()} years', context.text),
      ('Total invested', AppSettings.instance.formatRupee(_totalInvested, noDecimals: true), context.text),
      ('Total corpus', AppSettings.instance.formatRupee(_corpus, noDecimals: true), const Color(0xFF059669)),
      ('Annuity purchase (${_annuityPercent.toInt()}%)', AppSettings.instance.formatRupee(_annuityCorpus, noDecimals: true), _accent),
      ('Lumpsum withdrawal', AppSettings.instance.formatRupee(_lumpsum, noDecimals: true), const Color(0xFF059669)),
      ('Estimated monthly pension', AppSettings.instance.formatRupee(_estimatedPension, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NPS Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About NPS', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is NPS?', blocks: [
      InfoBlock.paragraph('National Pension System (NPS) is a government-sponsored pension scheme. It invests in a mix of equity, government bonds, and corporate debt to build a retirement corpus.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Min 40% must be used to buy annuity at 60',
        'Up to 60% can be withdrawn as lumpsum (tax-free)',
        'Tax benefit: ₹1.5L under 80C + extra ₹50K under 80CCD(1B)',
        'Choice of fund managers and asset allocation',
        'Tier-I (locked till 60) and Tier-II (flexible) accounts',
        'Partial withdrawal allowed for specific purposes after 3 years',
      ]),
    ]),
  ]);
}
