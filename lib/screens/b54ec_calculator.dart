import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class B54ECCalculatorScreen extends StatefulWidget {
  const B54ECCalculatorScreen({super.key});
  @override
  State<B54ECCalculatorScreen> createState() => _B54ECCalculatorScreenState();
}

class _B54ECCalculatorScreenState extends State<B54ECCalculatorScreen> {
  double _bondInvestment = 1000000; // 10 Lakhs default
  double _taxRate = 12.5; // 12.5% or 20% LTCG rate on real estate

  static const Color _accent = Color(0xFFDC2626);
  static const int _tenureYears = 5;
  static const double _interestRate = 5.25;

  double get _taxSaved => _bondInvestment * (_taxRate / 100);
  double get _annualInterest => _bondInvestment * (_interestRate / 100);
  double get _totalInterest => _annualInterest * _tenureYears;
  double get _maturityAmount => _bondInvestment;
  double get _totalBenefit => _taxSaved + _totalInterest;
  double get _effectiveReturnsPct => (_totalBenefit / _bondInvestment) * 100 / _tenureYears;

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
          title: Text('54EC Capital Gains Bonds', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [
              _resultCard(),
              _taxRateSelector(),
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
      const Text('Total Net Benefit (Tax Saved + Interest)', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
            TextSpan(text: AppSettings.instance.formatNumber(_totalBenefit), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Tax Saved Instantly', AppSettings.instance.formatShort(_taxSaved)),
        _vDiv(),
        _stat('Total Interest (5 Yrs)', AppSettings.instance.formatShort(_totalInterest)),
        _vDiv(),
        _stat('Effective Return/Yr', '${_effectiveReturnsPct.toStringAsFixed(2)}%'),
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

  Widget _taxRateSelector() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _taxRate = 12.5),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _taxRate == 12.5 ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '12.5% Tax Rate (LTCG without Indexation)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _taxRate == 12.5 ? FontWeight.w600 : FontWeight.normal,
                    color: _taxRate == 12.5 ? Colors.white : context.textSub,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _taxRate = 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _taxRate == 20.0 ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '20.0% Tax Rate (With Indexation)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _taxRate == 20.0 ? FontWeight.w600 : FontWeight.normal,
                    color: _taxRate == 20.0 ? Colors.white : context.textSub,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sliders() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      SliderInputCard(
        label: 'Bond Investment Amount',
        value: _bondInvestment,
        min: 20000,
        max: 5000000, // Section 54EC has a cap of ₹50 Lakhs
        divisions: 249,
        color: _accent,
        minLabel: '₹20K',
        maxLabel: '₹50L (Cap)',
        isRupee: true,
        onChanged: (v) => setState(() => _bondInvestment = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Bond Face Value (Maturity)', AppSettings.instance.formatRupee(_bondInvestment, noDecimals: true), context.text),
      ('LTCG Tax Saved', AppSettings.instance.formatRupee(_taxSaved, noDecimals: true), const Color(0xFF059669)),
      ('Interest Rate', '5.25% p.a.', context.text),
      ('Annual Interest Payout', AppSettings.instance.formatRupee(_annualInterest, noDecimals: true), context.text),
      ('Total Interest Received (5 Yrs)', AppSettings.instance.formatRupee(_totalInterest, noDecimals: true), const Color(0xFF059669)),
      ('Total Net Benefit', AppSettings.instance.formatRupee(_totalBenefit, noDecimals: true), const Color(0xFF059669)),
      ('Total Cash Inflow on Maturity', AppSettings.instance.formatRupee(_bondInvestment + _totalInterest, noDecimals: true), const Color(0xFFDC2626)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bonds Benefit Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About 54EC Bonds', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What are Section 54EC Bonds?', blocks: [
      InfoBlock.paragraph('Section 54EC Bonds, also known as Capital Gains Bonds, are investment instruments that allow you to claim tax exemption on long-term capital gains (LTCG) arising from the sale of land or building or both. The investment must be made within 6 months of the sale date.'),
    ]),
    InfoItem(icon: Icons.info_outline, title: 'Key Features & Lock-in', blocks: [
      InfoBlock.bullets([
        'Eligible Issuers: NHAI, REC, PFC, and IRFC.',
        'Lock-in Period: 5 Years (Non-transferable and cannot be pledged).',
        'Maximum Investment Limit: ₹50 Lakhs per financial year.',
        'Interest rate is 5.25% p.a. paid annually.',
        'Taxation: The capital gains invested are exempt from tax, but the annual interest received is taxable according to your income slab.',
      ]),
    ]),
  ]);
}
