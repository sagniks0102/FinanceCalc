import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

/// UPS is similar to NPS but with government guarantee — reuses NPS-like logic
class UPSCalculatorScreen extends StatefulWidget {
  const UPSCalculatorScreen({super.key});
  @override
  State<UPSCalculatorScreen> createState() => _UPSCalculatorScreenState();
}

class _UPSCalculatorScreenState extends State<UPSCalculatorScreen> {
  double _basicPay = 50000;
  double _currentAge = 30;
  double _retirementAge = 60;

  static const Color _accent = Color(0xFF7C3AED);

  double get _yearsOfService => _retirementAge - _currentAge;
  // UPS: 50% of avg basic pay of last 12 months as pension (for 25+ yrs service)
  // Proportional for 10-25 yrs
  double get _pensionPercent => _yearsOfService >= 25 ? 50 : (_yearsOfService >= 10 ? (_yearsOfService / 25 * 50) : 0);
  double get _monthlyPension => _basicPay * _pensionPercent / 100;
  double get _lumpsumGratuity => _basicPay * (_yearsOfService / 6) / 10; // 1/10th of monthly emolument for each 6 months
  double get _familyPension => _monthlyPension * 0.6; // 60% of pension

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
          title: Text('UPS Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
      const Text('Estimated Monthly Pension', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_monthlyPension), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const TextSpan(text: ' /month', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500, height: 2.4)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Service', '${_yearsOfService.toInt()} yrs'),
        _vDiv(), _stat('Pension %', '${_pensionPercent.toStringAsFixed(0)}%'),
        _vDiv(), _stat('Family\nPension', AppSettings.instance.formatShort(_familyPension)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Basic Pay (Monthly)', value: _basicPay, min: 10000, max: 500000, divisions: 98, color: _accent, minLabel: '₹10K', maxLabel: '₹5L', isRupee: true, onChanged: (v) => setState(() => _basicPay = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Current Age', value: _currentAge, min: 18, max: 55, divisions: 37, color: const Color(0xFFD97706), minLabel: '18', maxLabel: '55', suffix: ' yrs', onChanged: (v) => setState(() => _currentAge = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Retirement Age', value: _retirementAge, min: 55, max: 65, divisions: 10, color: const Color(0xFFDC2626), minLabel: '55', maxLabel: '65', suffix: ' yrs', onChanged: (v) => setState(() => _retirementAge = v)),
  ]));

  Widget _breakdown() {
    final rows = [
      ('Basic pay', AppSettings.instance.formatRupee(_basicPay, noDecimals: true), context.text),
      ('Years of service', '${_yearsOfService.toInt()} years', context.text),
      ('Pension percentage', '${_pensionPercent.toStringAsFixed(0)}% of basic pay', context.text),
      ('Monthly pension', AppSettings.instance.formatRupee(_monthlyPension, noDecimals: true), const Color(0xFF059669)),
      ('Family pension (60%)', AppSettings.instance.formatRupee(_familyPension, noDecimals: true), _accent),
      ('Min pension guarantee', '₹ 10,000/month', const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('UPS Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About UPS', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is UPS?', blocks: [
      InfoBlock.paragraph('Unified Pension Scheme (UPS) is a new government pension scheme that assures 50% of the average basic pay (last 12 months) as pension for 25+ years of service, with a minimum guarantee of ₹10,000/month.'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Features', blocks: [
      InfoBlock.bullets([
        '50% of avg basic pay as pension (25+ yrs service)',
        'Proportionate pension for 10-25 years service',
        'Minimum assured pension: ₹10,000/month',
        'Family pension: 60% of employee\'s pension',
        'Inflation indexation linked to AICPI',
        'Lump sum payment at retirement',
        'Government contributes 18.5% of basic pay',
      ]),
    ]),
  ]);
}
