import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class APSCalculatorScreen extends StatefulWidget {
  const APSCalculatorScreen({super.key});
  @override
  State<APSCalculatorScreen> createState() => _APSCalculatorScreenState();
}

class _APSCalculatorScreenState extends State<APSCalculatorScreen> {
  double _age = 30;
  double _pensionAmount = 3000; // 1000, 2000, 3000, 4000, 5000

  static const Color _accent = Color(0xFF059669);

  // APS contribution table (approximate monthly contribution based on age & pension)
  double get _monthlyContribution {
    final pensionIdx = ((_pensionAmount / 1000) - 1).toInt().clamp(0, 4);
    // Simplified contribution table
    final contributions = <int, List<double>>{
      18: [42, 84, 126, 168, 210], 20: [50, 100, 150, 198, 248],
      25: [76, 151, 226, 301, 376], 30: [116, 231, 347, 462, 577],
      35: [181, 362, 543, 722, 902], 40: [291, 582, 873, 1164, 1454],
    };
    // Find closest age bracket
    final ages = contributions.keys.toList()..sort();
    int closeAge = ages.first;
    for (final a in ages) { if (a <= _age.toInt()) closeAge = a; }
    return contributions[closeAge]![pensionIdx];
  }

  double get _totalContribution => _monthlyContribution * 12 * (60 - _age);
  double get _spousePension => _pensionAmount;
  double get _nomineeLumpsum => _pensionAmount == 1000 ? 170000 : _pensionAmount == 2000 ? 340000 : _pensionAmount == 3000 ? 510000 : _pensionAmount == 4000 ? 680000 : 850000;

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
          title: Text('APS Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
      const Text('Guaranteed Monthly Pension (at age 60)', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_pensionAmount), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const TextSpan(text: ' /month', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500, height: 2.4)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Your\nContribution', '₹${_monthlyContribution.toInt()}/mo'),
        _vDiv(), _stat('Spouse\nPension', '₹${_pensionAmount.toInt()}/mo'),
        _vDiv(), _stat('Nominee\nReturn', AppSettings.instance.formatShort(_nomineeLumpsum)),
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
    const SizedBox(height: 12),
    SliderInputCard(label: 'Desired Monthly Pension (₹)', value: _pensionAmount, min: 1000, max: 5000, divisions: 4, color: const Color(0xFF6366F1), minLabel: '₹1K', maxLabel: '₹5K', isRupee: true, onChanged: (v) => setState(() => _pensionAmount = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Your age', '${_age.toInt()} years', context.text),
      ('Desired pension', '₹ ${_pensionAmount.toInt()}/month', context.text),
      ('Monthly contribution', '₹ ${_monthlyContribution.toInt()}', _accent),
      ('Contribution years', '${(60 - _age).toInt()} years (till age 60)', context.text),
      ('Total contribution', AppSettings.instance.formatRupee(_totalContribution, noDecimals: true), context.text),
      ('Govt co-contributes', '50% of your contribution', const Color(0xFF059669)),
      ('Spouse pension', '₹ ${_pensionAmount.toInt()}/month (after subscriber)', const Color(0xFF059669)),
      ('Nominee lumpsum', AppSettings.instance.formatRupee(_nomineeLumpsum, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('APS Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About APS', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is Atal Pension Scheme?', blocks: [
      InfoBlock.paragraph('Atal Pension Scheme (APS/APY) is a government pension scheme for unorganized sector workers. It guarantees a fixed monthly pension of ₹1,000 to ₹5,000 starting at age 60.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        'Age: 18-40 years can join',
        'Fixed pension: ₹1,000 to ₹5,000/month',
        'Government co-contributes 50% (for non-taxpayers, joined before Oct 2022)',
        'Tax benefit under Section 80CCD',
        'Same pension continues for spouse after death',
        'Nominee gets lumpsum corpus amount',
      ]),
    ]),
  ]);
}
