import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class FRSBCalculatorScreen extends StatefulWidget {
  const FRSBCalculatorScreen({super.key});
  @override
  State<FRSBCalculatorScreen> createState() => _FRSBCalculatorScreenState();
}

class _FRSBCalculatorScreenState extends State<FRSBCalculatorScreen> {
  double _investment = 500000;
  double _rate = 8.05; // Current rate is 8.05% (NSC rate + 0.35%)

  static const Color _accent = Color(0xFFDC2626);
  static const int _tenureYears = 7;

  double get _halfYearlyInterest => _investment * (_rate / 100) / 2;
  double get _annualInterest => _investment * (_rate / 100);
  double get _totalInterest => _annualInterest * _tenureYears;
  double get _totalMaturity => _investment + _totalInterest;

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
          title: Text('Floating Rate Savings Bonds', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Half-Yearly Interest Payout', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
            TextSpan(text: AppSettings.instance.formatNumber(_halfYearlyInterest), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Principal Invested', AppSettings.instance.formatShort(_investment)),
        _vDiv(),
        _stat('Annual Interest', AppSettings.instance.formatShort(_annualInterest)),
        _vDiv(),
        _stat('Total Interest (7 Yrs)', AppSettings.instance.formatShort(_totalInterest)),
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
        label: 'Investment Amount',
        value: _investment,
        min: 1000,
        max: 50000000,
        divisions: 499,
        color: _accent,
        minLabel: '₹1K',
        maxLabel: '₹5Cr',
        isRupee: true,
        onChanged: (v) => setState(() => _investment = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Interest Rate (% p.a. Floating)',
        value: _rate,
        min: 4,
        max: 12,
        divisions: 160,
        color: const Color(0xFF059669),
        minLabel: '4%',
        maxLabel: '12%',
        suffix: '%',
        isDecimal: true,
        onChanged: (v) => setState(() => _rate = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Principal Investment', AppSettings.instance.formatRupee(_investment, noDecimals: true), context.text),
      ('Current Floating Interest Rate', '${_rate.toStringAsFixed(2)}% p.a.', context.text),
      ('Tenure (Lock-in)', '7 Years', context.text),
      ('Half-Yearly Payout Schedule', 'Every Jan 1st and July 1st', context.text),
      ('Half-Yearly Interest Payout', AppSettings.instance.formatRupee(_halfYearlyInterest, noDecimals: true), const Color(0xFF059669)),
      ('Annual Interest Earnings', AppSettings.instance.formatRupee(_annualInterest, noDecimals: true), const Color(0xFF059669)),
      ('Total Interest over 7 Years', AppSettings.instance.formatRupee(_totalInterest, noDecimals: true), const Color(0xFF059669)),
      ('Total Payout + Principal Returned', AppSettings.instance.formatRupee(_totalMaturity, noDecimals: true), const Color(0xFFDC2626)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bonds Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
          const SizedBox(height: 10),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About FRSB', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is FRSB?', blocks: [
      InfoBlock.paragraph('Floating Rate Savings Bonds (FRSB) 2020 are taxable bonds issued by the Government of India. The interest rate on these bonds is not fixed and changes semi-annually, tied to the prevailing National Savings Certificate (NSC) rate + 0.35%.'),
    ]),
    InfoItem(icon: Icons.info_outline, title: 'Key Terms', blocks: [
      InfoBlock.bullets([
        'Minimum Investment: ₹1,000 (No maximum limit).',
        'Tenure: 7 Years (Premature withdrawal allowed only for senior citizens over 60, subject to lock-in).',
        'Interest Payout: Paid semi-annually on 1st January and 1st July. There is no cumulative interest option.',
        'Taxation: Interest is fully taxable under your income slab. TDS is applicable.',
        'Safety: 100% safe as they are sovereign bonds backed by the Government of India.',
      ]),
    ]),
  ]);
}
