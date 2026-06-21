import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class GratuityCalculatorScreen extends StatefulWidget {
  const GratuityCalculatorScreen({super.key});
  @override
  State<GratuityCalculatorScreen> createState() => _GratuityCalculatorScreenState();
}

class _GratuityCalculatorScreenState extends State<GratuityCalculatorScreen> {
  double _salary = 50000; // Last drawn basic + DA
  double _years = 15;
  bool _isCovered = true; // Covered under Payment of Gratuity Act

  static const Color _accent = Color(0xFF9333EA);

  // Gratuity formula:
  // Covered: (15 × last salary × years) / 26
  // Not covered: (15 × last salary × years) / 30
  double get _gratuity => _isCovered
      ? (15 * _salary * _years) / 26
      : (15 * _salary * _years) / 30;
  
  // Tax-free limit is ₹20 lakh
  double get _taxFree => _gratuity.clamp(0, 2000000);
  double get _taxable => (_gratuity - 2000000).clamp(0, double.infinity);

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
          title: Text('Gratuity Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(child: Column(children: [
            _resultCard(), _sliders(), _coveredToggle(), _breakdown(),
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
      const Text('Gratuity Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_gratuity), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Last Salary', AppSettings.instance.formatShort(_salary)),
        _vDiv(), _stat('Service', '${_years.toInt()} yrs'),
        _vDiv(), _stat('Tax-Free\n(up to ₹20L)', AppSettings.instance.formatShort(_taxFree)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Last Drawn Salary (Basic + DA)', value: _salary, min: 5000, max: 500000, divisions: 99, color: _accent, minLabel: '₹5K', maxLabel: '₹5L', isRupee: true, onChanged: (v) => setState(() => _salary = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Years of Service', value: _years, min: 5, max: 40, divisions: 35, color: const Color(0xFF059669), minLabel: '5 yrs', maxLabel: '40 yrs', suffix: ' yrs', onChanged: (v) => setState(() => _years = v)),
  ]));

  Widget _coveredToggle() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Text('Covered under Gratuity Act?', style: TextStyle(fontSize: 13, color: context.text))),
      Switch(value: _isCovered, onChanged: (v) => setState(() => _isCovered = v), activeColor: _accent),
    ]),
  ));

  Widget _breakdown() {
    final rows = [
      ('Last drawn salary', AppSettings.instance.formatRupee(_salary, noDecimals: true), context.text),
      ('Years of service', '${_years.toInt()} years', context.text),
      ('Type', _isCovered ? 'Covered (÷26)' : 'Not covered (÷30)', context.text),
      ('Gratuity amount', AppSettings.instance.formatRupee(_gratuity, noDecimals: true), const Color(0xFF059669)),
      ('Tax-free (up to ₹20L)', AppSettings.instance.formatRupee(_taxFree, noDecimals: true), const Color(0xFF059669)),
      if (_taxable > 0) ('Taxable amount', AppSettings.instance.formatRupee(_taxable, noDecimals: true), const Color(0xFFDC2626)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Gratuity Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About Gratuity', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is Gratuity?', blocks: [
      InfoBlock.paragraph('Gratuity is a lump sum amount paid by an employer to an employee for continuous service of 5+ years. It is calculated on the last drawn salary and years of service.'),
    ]),
    InfoItem(icon: Icons.functions_rounded, title: 'Formula', blocks: [
      InfoBlock.formula('Gratuity = (15 × Last Salary × Years) / 26\n\nFor employees NOT covered under Act:\nGratuity = (15 × Last Salary × Years) / 30'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Rules', blocks: [
      InfoBlock.bullets([
        'Minimum 5 years of continuous service required',
        'Tax exemption up to ₹20 lakh (govt employees fully exempt)',
        'Applies to companies with 10+ employees',
        'Includes Basic Pay + Dearness Allowance',
      ]),
    ]),
  ]);
}
