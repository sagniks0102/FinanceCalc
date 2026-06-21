import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class SBCalculatorScreen extends StatefulWidget {
  const SBCalculatorScreen({super.key});
  @override
  State<SBCalculatorScreen> createState() => _SBCalculatorScreenState();
}

class _SBCalculatorScreenState extends State<SBCalculatorScreen> {
  double _memberCount = 1;
  double _age = 30;

  static const Color _accent = Color(0xFF059669);

  double get _annualPremiumPerPerson => 20.0;
  double get _maxCoverPerPerson => 200000.0;

  double get _totalPremium => _memberCount * _annualPremiumPerPerson;
  double get _totalCover => _memberCount * _maxCoverPerPerson;

  bool get _isEligible => _age >= 18 && _age <= 70;

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
          title: Text('PM Suraksha Bima', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
            ? [Color(0xFF059669), Color(0xFF10B981)]
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
        _stat('Max Accident Cover', AppSettings.instance.formatShort(_totalCover)),
        _vDiv(),
        _stat('Eligibility Status', _isEligible ? 'Eligible ✓' : 'Not Eligible ✗'),
        _vDiv(),
        _stat('Premium /Person', AppSettings.instance.formatShort(_annualPremiumPerPerson)),
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
      ('Scheme Name', 'Pradhan Mantri Suraksha Bima Yojana (PMSBY)', context.text),
      ('Cover Type', 'Personal Accident Insurance (Death / Disability)', context.text),
      ('Max Benefit (Accidental Death)', AppSettings.instance.formatRupee(200000, noDecimals: true), context.text),
      ('Max Benefit (Total Disability)', AppSettings.instance.formatRupee(200000, noDecimals: true), context.text),
      ('Benefit (Partial Disability)', AppSettings.instance.formatRupee(100000, noDecimals: true), context.text),
      ('Annual Premium (Per Person)', AppSettings.instance.formatRupee(_annualPremiumPerPerson, noDecimals: true), context.text),
      ('Number of Persons Insured', '${_memberCount.toInt()}', context.text),
      ('Total Annual Premium Payable', AppSettings.instance.formatRupee(_totalPremium, noDecimals: true), const Color(0xFF059669)),
      ('Total Accidental Cover', AppSettings.instance.formatRupee(_totalCover, noDecimals: true), const Color(0xFF059669)),
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
                'Note: Age must be between 18 and 70 years to join this scheme.',
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About PMSBY', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is PMSBY?', blocks: [
      InfoBlock.paragraph('Pradhan Mantri Suraksha Bima Yojana (PMSBY) is a government-backed accident insurance scheme in India. It offers coverage for accidental death and disability at an extremely low annual premium.'),
    ]),
    InfoItem(icon: Icons.check_circle_outline, title: 'Eligibility & Coverage details', blocks: [
      InfoBlock.bullets([
        'Eligibility: Savings bank account holders aged between 18 and 70 years.',
        'Premium: ₹20 per annum per member, auto-debited from the account.',
        'Benefit: ₹2 Lakhs in case of Accidental Death or Total Permanent Disability.',
        'Benefit: ₹1 Lakh in case of Permanent Partial Disability (loss of one eye/limb).',
        'Policy Term: 1st June to 31st May of the subsequent year.',
      ]),
    ]),
  ]);
}
