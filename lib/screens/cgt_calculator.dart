import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class CGTCalculatorScreen extends StatefulWidget {
  const CGTCalculatorScreen({super.key});
  @override
  State<CGTCalculatorScreen> createState() => _CGTCalculatorScreenState();
}

class _CGTCalculatorScreenState extends State<CGTCalculatorScreen> {
  double _purchasePrice = 500000;
  double _salePrice = 800000;
  double _holdingMonths = 18;
  String _assetType = 'Equity'; // 'Equity', 'Debt/Gold', 'Real Estate'

  static const Color _accent = Color(0xFF0D9488);

  bool get _isLTCG {
    if (_assetType == 'Equity') {
      return _holdingMonths > 12;
    } else if (_assetType == 'Real Estate') {
      return _holdingMonths > 24;
    } else {
      // Debt / Gold
      return _holdingMonths > 36;
    }
  }

  double get _gains => (_salePrice - _purchasePrice).clamp(0, double.infinity);

  double get _taxRate {
    if (_assetType == 'Equity') {
      return _isLTCG ? 12.5 : 20.0;
    } else if (_assetType == 'Real Estate') {
      return _isLTCG ? 12.5 : 30.0; // STCG is slab rate, assume 30% for illustration
    } else {
      // Debt / Gold (new rules tax debt funds at slab rate, gold LTCG at 12.5% or 20% with indexation. Let's use standard rates)
      return _isLTCG ? 20.0 : 30.0;
    }
  }

  double get _taxPayable {
    final g = _gains;
    if (g <= 0) return 0;
    if (_assetType == 'Equity' && _isLTCG) {
      // LTCG exemption on Equity is ₹1.25 Lakhs (New Budget)
      final taxableGains = (g - 125000).clamp(0, double.infinity);
      return taxableGains * (_taxRate / 100);
    }
    return g * (_taxRate / 100);
  }

  double get _netProfit => _gains - _taxPayable;

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
          title: Text('Capital Gains Tax', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [
              _resultCard(),
              _assetTypeSelector(),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Estimated Tax Payable', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
            TextSpan(text: AppSettings.instance.formatNumber(_taxPayable), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Total Capital Gains', AppSettings.instance.formatShort(_gains)),
        _vDiv(),
        _stat('Tax Category', _isLTCG ? 'LTCG' : 'STCG'),
        _vDiv(),
        _stat('Net Earnings', AppSettings.instance.formatShort(_netProfit)),
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

  Widget _assetTypeSelector() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['Equity', 'Debt/Gold', 'Real Estate'].map((type) {
          final isSelected = _assetType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _assetType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : context.textSub,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );

  Widget _sliders() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      SliderInputCard(
        label: 'Purchase Price',
        value: _purchasePrice,
        min: 10000,
        max: 50000000,
        divisions: 499,
        color: _accent,
        minLabel: '₹10K',
        maxLabel: '₹5Cr',
        isRupee: true,
        onChanged: (v) {
          setState(() {
            _purchasePrice = v;
            if (_salePrice < _purchasePrice) _salePrice = _purchasePrice;
          });
        },
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Sale Price',
        value: _salePrice,
        min: 10000,
        max: 50000000,
        divisions: 499,
        color: const Color(0xFF059669),
        minLabel: '₹10K',
        maxLabel: '₹5Cr',
        isRupee: true,
        onChanged: (v) {
          setState(() {
            _salePrice = v;
            if (_purchasePrice > _salePrice) _purchasePrice = _salePrice;
          });
        },
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Holding Period (Months)',
        value: _holdingMonths,
        min: 1,
        max: 120,
        divisions: 119,
        color: const Color(0xFF6366F1),
        minLabel: '1 mo',
        maxLabel: '10 yrs',
        suffix: ' months',
        onChanged: (v) => setState(() => _holdingMonths = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Asset Class', _assetType, context.text),
      ('Holding period', '${_holdingMonths.toInt()} months (${_isLTCG ? "Long Term" : "Short Term"})', context.text),
      ('Purchase Price', AppSettings.instance.formatRupee(_purchasePrice, noDecimals: true), context.text),
      ('Sale Price', AppSettings.instance.formatRupee(_salePrice, noDecimals: true), context.text),
      ('Gross Capital Gains', AppSettings.instance.formatRupee(_gains, noDecimals: true), const Color(0xFF0D9488)),
      ('Applicable Tax Rate', '${_taxRate.toStringAsFixed(1)}%', context.text),
      if (_assetType == 'Equity' && _isLTCG)
        ('Exemption Limit (LTCG Equity)', AppSettings.instance.formatRupee(125000, noDecimals: true), const Color(0xFF059669)),
      ('Estimated Tax', AppSettings.instance.formatRupee(_taxPayable, noDecimals: true), const Color(0xFFDC2626)),
      ('Net Gains (Post Tax)', AppSettings.instance.formatRupee(_netProfit, noDecimals: true), const Color(0xFF059669)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tax Calculation Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About Capital Gains Tax', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is Capital Gains Tax?', blocks: [
      InfoBlock.paragraph('Any profit or gain that arises from the sale of a \'capital asset\' is a capital gain. This gain is charged to tax under the Income Tax Act under \'Capital Gains\'.'),
    ]),
    InfoItem(icon: Icons.info_outline, title: 'Classification and Tax Rules (FY 2024-25)', blocks: [
      InfoBlock.bullets([
        'Equity: Short-term (STCG) if held <= 12 months (taxed at 20%). Long-term (LTCG) if held > 12 months (taxed at 12.5% on gains exceeding ₹1.25 Lakhs).',
        'Real Estate: STCG if held <= 24 months (taxed at slab rates). LTCG if held > 24 months (taxed at 12.5% without indexation).',
        'Debt Mutual Funds: Capital gains on debt mutual funds are taxed at the investor\'s income tax slab rates regardless of holding period (STCG/LTCG classified by holding periods for other assets).',
        'Gold & Bonds: STCG if held <= 36 months (taxed at slab rates). LTCG if held > 36 months (taxed at 12.5% without indexation).',
      ]),
    ]),
  ]);
}
