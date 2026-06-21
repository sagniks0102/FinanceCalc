import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class ELSSCalculatorScreen extends StatefulWidget {
  const ELSSCalculatorScreen({super.key});
  @override
  State<ELSSCalculatorScreen> createState() => _ELSSCalculatorScreenState();
}

class _ELSSCalculatorScreenState extends State<ELSSCalculatorScreen> {
  double _monthly = 5000;
  double _rate = 12.0;
  double _years = 10;

  static const Color _accent = Color(0xFF0D9488);

  double get _totalInvested => _monthly * 12 * _years;
  double get _maturity {
    final r = _rate / 100 / 12;
    final n = _years * 12;
    if (r == 0) return _totalInvested;
    return _monthly * ((pow(1 + r, n) - 1) / r) * (1 + r);
  }
  double get _returns => _maturity - _totalInvested;
  double get _taxSaved => (_monthly * 12).clamp(0, 150000) * 0.312; // ~31.2% for 30% slab + cess

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
          title: Text('ELSS Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Expected Maturity Value', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_maturity), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Invested', AppSettings.instance.formatShort(_totalInvested)),
        _vDiv(), _stat('Est. Returns', AppSettings.instance.formatShort(_returns)),
        _vDiv(), _stat('Tax Saved\n/Year', AppSettings.instance.formatShort(_taxSaved)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Monthly SIP Amount', value: _monthly, min: 500, max: 100000, divisions: 199, color: _accent, minLabel: '₹500', maxLabel: '₹1L', isRupee: true, onChanged: (v) => setState(() => _monthly = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Expected Return Rate (% p.a.)', value: _rate, min: 5, max: 25, divisions: 200, color: const Color(0xFF059669), minLabel: '5%', maxLabel: '25%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Investment Period (Years)', value: _years, min: 3, max: 30, divisions: 27, color: const Color(0xFF6366F1), minLabel: '3 yrs', maxLabel: '30 yrs', suffix: ' yrs', onChanged: (v) => setState(() => _years = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Monthly SIP', AppSettings.instance.formatRupee(_monthly, noDecimals: true), context.text),
      ('Investment period', '${_years.toInt()} years (lock-in: 3 years)', context.text),
      ('Total invested', AppSettings.instance.formatRupee(_totalInvested, noDecimals: true), context.text),
      ('Expected returns', AppSettings.instance.formatRupee(_returns, noDecimals: true), const Color(0xFF0D9488)),
      ('Expected maturity', AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
      ('Tax saved per year (80C)', AppSettings.instance.formatRupee(_taxSaved, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ELSS Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About ELSS', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is ELSS?', blocks: [
      InfoBlock.paragraph('Equity Linked Savings Scheme (ELSS) is a type of mutual fund that invests primarily in equities. It offers tax benefits under Section 80C with the shortest lock-in period among 80C investments (3 years).'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Lock-in period: 3 years (shortest among 80C)',
        'Tax benefit up to ₹1.5 lakh under Section 80C',
        'Market-linked returns (historically 12-15% CAGR)',
        'LTCG above ₹1 lakh taxed at 10%',
        'Can invest via SIP or lump sum',
        'No upper limit on investment',
      ]),
    ]),
  ]);
}
