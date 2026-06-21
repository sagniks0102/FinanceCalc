import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class SYMCalculatorScreen extends StatefulWidget {
  const SYMCalculatorScreen({super.key});
  @override
  State<SYMCalculatorScreen> createState() => _SYMCalculatorScreenState();
}

class _SYMCalculatorScreenState extends State<SYMCalculatorScreen> {
  double _age = 30;
  static const Color _accent = Color(0xFF0D9488);
  static const double _pension = 3000; // Fixed pension amount

  // SYM contribution based on age
  double get _monthlyContribution {
    if (_age <= 18) return 55;
    if (_age <= 20) return 66;
    if (_age <= 25) return 100;
    if (_age <= 30) return 150;
    if (_age <= 35) return 200;
    return 300;
  }
  double get _govtContribution => _monthlyContribution;
  double get _totalContribution => _monthlyContribution * 12 * (60 - _age);

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
          title: Text('PM-SYM Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
      const Text('Guaranteed Monthly Pension', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      const Text('₹ 3,000 /month', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Your\nContribution', '₹${_monthlyContribution.toInt()}/mo'),
        _vDiv(), _stat('Govt\nContribution', '₹${_govtContribution.toInt()}/mo'),
        _vDiv(), _stat('Spouse\nPension', '₹1,500/mo'),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Your Age', value: _age, min: 18, max: 40, divisions: 22, color: _accent, minLabel: '18', maxLabel: '40', suffix: ' yrs', onChanged: (v) => setState(() => _age = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Your age', '${_age.toInt()} years', context.text),
      ('Monthly contribution', '₹ ${_monthlyContribution.toInt()}', _accent),
      ('Govt contribution (equal)', '₹ ${_govtContribution.toInt()}/month', const Color(0xFF059669)),
      ('Years till pension', '${(60 - _age).toInt()} years', context.text),
      ('Your total contribution', AppSettings.instance.formatRupee(_totalContribution, noDecimals: true), context.text),
      ('Pension at 60', '₹ 3,000/month (guaranteed)', const Color(0xFF059669)),
      ('Spouse pension', '₹ 1,500/month (50%)', const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PM-SYM Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
        const SizedBox(height: 10),
        ...rows.map((r) => Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub))),
            Flexible(child: Text(r.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: r.$3), textAlign: TextAlign.right)),
          ]),
        )),
      ]),
    ));
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About PM-SYM', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is PM-SYM?', blocks: [
      InfoBlock.paragraph('PM Shram Yogi Maan-dhan (PM-SYM) is a pension scheme for unorganized workers earning up to ₹15,000/month. It guarantees ₹3,000/month pension after age 60.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'For unorganized workers aged 18-40',
        'Monthly income should be ≤ ₹15,000',
        'Government matches 100% of your contribution',
        'Guaranteed pension: ₹3,000/month at age 60',
        'Spouse gets 50% pension (₹1,500)',
        'Auto-debit from savings account',
      ]),
    ]),
  ]);
}
