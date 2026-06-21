import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class SGBCalculatorScreen extends StatefulWidget {
  const SGBCalculatorScreen({super.key});
  @override
  State<SGBCalculatorScreen> createState() => _SGBCalculatorScreenState();
}

class _SGBCalculatorScreenState extends State<SGBCalculatorScreen> {
  double _goldPricePerGram = 6500;
  double _grams = 50;
  double _expectedGrowth = 8.0;

  static const Color _accent = Color(0xFF059669);
  static const int _tenureYears = 8;
  static const double _interestRate = 2.5;

  double get _initialInvestment => _goldPricePerGram * _grams;
  double get _annualInterest => _initialInvestment * (_interestRate / 100);
  double get _totalInterest => _annualInterest * _tenureYears;

  double get _futureGoldPrice => _goldPricePerGram * pow(1 + _expectedGrowth / 100, _tenureYears);
  double get _maturityValue => _futureGoldPrice * _grams;

  double get _totalReturns => _maturityValue + _totalInterest;
  double get _netProfit => _totalReturns - _initialInvestment;

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
          title: Text('Sovereign Gold Bonds', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Expected Total Returns (Gold + Interest)', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
            TextSpan(text: AppSettings.instance.formatNumber(_totalReturns), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Initial Investment', AppSettings.instance.formatShort(_initialInvestment)),
        _vDiv(),
        _stat('Total Interest (2.5%)', AppSettings.instance.formatShort(_totalInterest)),
        _vDiv(),
        _stat('Est. Maturity Gold', AppSettings.instance.formatShort(_maturityValue)),
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
        label: 'Gold Price per Gram (Purchase)',
        value: _goldPricePerGram,
        min: 3000,
        max: 12000,
        divisions: 180,
        color: _accent,
        minLabel: '₹3K',
        maxLabel: '₹12K',
        isRupee: true,
        onChanged: (v) => setState(() => _goldPricePerGram = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Quantity (Grams of Gold)',
        value: _grams,
        min: 1,
        max: 1000,
        divisions: 999,
        color: const Color(0xFFEAB308),
        minLabel: '1g',
        maxLabel: '1Kg',
        suffix: ' g',
        onChanged: (v) => setState(() => _grams = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Expected Gold Growth Rate (% p.a.)',
        value: _expectedGrowth,
        min: -5,
        max: 15,
        divisions: 200,
        color: const Color(0xFF6366F1),
        minLabel: '-5%',
        maxLabel: '15%',
        suffix: '%',
        isDecimal: true,
        onChanged: (v) => setState(() => _expectedGrowth = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Initial Gold Price (Per Gram)', AppSettings.instance.formatRupee(_goldPricePerGram, noDecimals: true), context.text),
      ('Grams Purchased', '${_grams.toInt()} g', context.text),
      ('Initial Investment', AppSettings.instance.formatRupee(_initialInvestment, noDecimals: true), context.text),
      ('Annual Interest Rate', '2.5% p.a.', context.text),
      ('Annual Interest Payout', AppSettings.instance.formatRupee(_annualInterest, noDecimals: true), context.text),
      ('Total Interest Received (8 Yrs)', AppSettings.instance.formatRupee(_totalInterest, noDecimals: true), const Color(0xFF059669)),
      ('Est. Maturity Gold Price (Per Gram)', AppSettings.instance.formatRupee(_futureGoldPrice, noDecimals: true), context.text),
      ('Est. Maturity Gold Value', AppSettings.instance.formatRupee(_maturityValue, noDecimals: true), const Color(0xFF059669)),
      ('Total Returns (Value + Interest)', AppSettings.instance.formatRupee(_totalReturns, noDecimals: true), const Color(0xFF059669)),
      ('Net Profits (Post Tax)', AppSettings.instance.formatRupee(_netProfit, noDecimals: true), const Color(0xFF059669)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SGB Growth Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About Sovereign Gold Bonds (SGB)', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What are Sovereign Gold Bonds?', blocks: [
      InfoBlock.paragraph('Sovereign Gold Bonds (SGBs) are government securities denominated in grams of gold. They are issued by the Reserve Bank of India (RBI) on behalf of the Government of India. They act as a safe alternative to holding physical gold.'),
    ]),
    InfoItem(icon: Icons.info_outline, title: 'Key Benefits', blocks: [
      InfoBlock.bullets([
        'Earn interest: Fixed interest of 2.50% p.a. paid semi-annually on the initial investment amount.',
        'Tax-free Capital Gains: Capital gains tax on redemption of SGB at maturity (8 years) is completely exempt for individuals.',
        'No making charges or storage risks associated with physical gold.',
        'Tenure: 8 Years (Premature redemption allowed after 5th year).',
        'Limit: Min 1 gram, Max 4 kg per individual per financial year.',
      ]),
    ]),
  ]);
}
