import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class JJBCalculatorScreen extends StatefulWidget {
  const JJBCalculatorScreen({super.key});
  @override
  State<JJBCalculatorScreen> createState() => _JJBCalculatorScreenState();
}

class _JJBCalculatorScreenState extends State<JJBCalculatorScreen> {
  double _memberCount = 1;
  double _age = 30;

  static const Color _accent = Color(0xFF0D9488);

  double get _annualPremiumPerPerson => 436.0;
  double get _coverPerPerson => 200000.0;

  double get _totalPremium => _memberCount * _annualPremiumPerPerson;
  double get _totalCover => _memberCount * _coverPerPerson;

  bool get _isEligible => _age >= 18 && _age <= 50;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance.updateListener,
      builder: (_, __) => Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.text.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: context.text, size: 20),
            ),
          ),
          title: Text('PM Jeevan Jyoti Bima', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [
              _resultCard(),
              _sliders(),
              _breakdown(),
              const SizedBox(height: 16),
              _infoSection(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  Widget _resultCard() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: _isEligible
            ? [Color(0xFF0D9488), Color(0xFF14B8A6)]
            : [Colors.grey.shade700, Colors.grey.shade600],
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Total Annual Premium', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
            TextSpan(text: AppSettings.instance.formatNumber(_totalPremium), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Total Life Cover', AppSettings.instance.formatShort(_totalCover)),
        _vDiv(),
        _stat('Eligibility Status', _isEligible ? 'Eligible ✓' : 'Not Eligible ✗'),
        _vDiv(),
        _stat('Premium /Month', AppSettings.instance.formatShort(_totalPremium / 12)),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(
    child: Column(children: [
      Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center),
      const SizedBox(height: 2),
      Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sliders() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      SliderInputCard(
        label: 'Number of Members',
        value: _memberCount,
        min: 1,
        max: 10,
        divisions: 9,
        color: _accent,
        minLabel: '1',
        maxLabel: '10',
        onChanged: (v) => setState(() => _memberCount = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Your Age (for Eligibility Check)',
        value: _age,
        min: 1,
        max: 100,
        divisions: 99,
        color: const Color(0xFF6366F1),
        minLabel: '1 yr',
        maxLabel: '100 yrs',
        suffix: ' yrs',
        onChanged: (v) => setState(() => _age = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Scheme Name', 'Pradhan Mantri Jeevan Jyoti Bima Yojana (PMJJBY)', context.text),
      ('Cover Type', 'Life Insurance Cover (Death due to any reason)', context.text),
      ('Sum Assured (Per Person)', AppSettings.instance.formatRupee(_coverPerPerson, noDecimals: true), context.text),
      ('Annual Premium (Per Person)', AppSettings.instance.formatRupee(_annualPremiumPerPerson, noDecimals: true), context.text),
      ('Equivalent Monthly Cost (Per Person)', AppSettings.instance.formatRupee(_annualPremiumPerPerson / 12), context.text),
      ('Number of Persons Insured', '${_memberCount.toInt()}', context.text),
      ('Total Annual Premium Payable', AppSettings.instance.formatRupee(_totalPremium, noDecimals: true), const Color(0xFF0D9488)),
      ('Total Family Life Coverage', AppSettings.instance.formatRupee(_totalCover, noDecimals: true), const Color(0xFF059669)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Policy Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
          const SizedBox(height: 10),
          if (!_isEligible)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Note: Age must be between 18 and 50 years to join this scheme.',
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub))),
              Text(r.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: r.$3)),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About PMJJBY', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is PMJJBY?', blocks: [
      InfoBlock.paragraph('Pradhan Mantri Jeevan Jyoti Bima Yojana (PMJJBY) is a government-backed life insurance scheme in India. It is a one-year term life insurance scheme, renewable from year to year, offering life insurance cover for death due to any reason.'),
    ]),
    InfoItem(icon: Icons.check_circle_outline, title: 'Key Features & Terms', blocks: [
      InfoBlock.bullets([
        'Eligibility: Savings bank account holders aged between 18 and 50 years.',
        'Premium: ₹436 per annum per member, auto-debited from the account.',
        'Policy Term: 1st June to 31st May of the subsequent year.',
        'Coverage: ₹2,000,000 (2 Lakhs) paid to the nominee upon the death of the insured.',
        'Risk cover starts 30 days after enrollment (excluding death by accident).',
      ]),
    ]),
  ]);
}
