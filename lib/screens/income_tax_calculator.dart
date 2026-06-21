import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class IncomeTaxCalculatorScreen extends StatefulWidget {
  const IncomeTaxCalculatorScreen({super.key});
  @override
  State<IncomeTaxCalculatorScreen> createState() => _IncomeTaxCalculatorScreenState();
}

class _IncomeTaxCalculatorScreenState extends State<IncomeTaxCalculatorScreen> {
  double _income = 1000000;
  double _deductions80C = 150000;
  double _deductions80D = 25000;
  double _hra = 0;
  bool _isNewRegime = true;
  double _age = 35;

  static const Color _accent = Color(0xFF059669);

  // New Regime (FY 2024-25) slabs
  double get _newRegimeTax {
    double taxable = _income;
    // Standard deduction of 75000 in new regime
    taxable -= 75000;
    if (taxable <= 0) return 0;
    
    double tax = 0;
    if (taxable > 2400000) { tax += (taxable - 2400000) * 0.30; taxable = 2400000; }
    if (taxable > 2000000) { tax += (taxable - 2000000) * 0.25; taxable = 2000000; }
    if (taxable > 1600000) { tax += (taxable - 1600000) * 0.20; taxable = 1600000; }
    if (taxable > 1200000) { tax += (taxable - 1200000) * 0.15; taxable = 1200000; }
    if (taxable > 800000) { tax += (taxable - 800000) * 0.10; taxable = 800000; }
    if (taxable > 400000) { tax += (taxable - 400000) * 0.05; taxable = 400000; }
    
    // Rebate u/s 87A: No tax if income up to ₹12 lakh (new regime)
    if (_income <= 1200000) tax = 0;
    
    return tax + tax * 0.04; // +4% cess
  }

  // Old Regime slabs
  double get _oldRegimeTax {
    double taxable = _income - 50000; // standard deduction
    taxable -= _deductions80C.clamp(0, 150000);
    taxable -= _deductions80D.clamp(0, 75000);
    taxable -= _hra;
    if (taxable <= 0) return 0;

    double exemptLimit = _age >= 80 ? 500000 : (_age >= 60 ? 300000 : 250000);
    double tax = 0;
    if (taxable > 1000000) { tax += (taxable - 1000000) * 0.30; taxable = 1000000; }
    if (taxable > 500000) { tax += (taxable - 500000) * 0.20; taxable = 500000; }
    if (taxable > exemptLimit) { tax += (taxable - exemptLimit) * 0.05; }

    // Rebate u/s 87A
    if ((_income - _deductions80C - _deductions80D - _hra - 50000) <= 500000) tax = 0;

    return tax + tax * 0.04;
  }

  double get _tax => _isNewRegime ? _newRegimeTax : _oldRegimeTax;
  double get _effectiveRate => _income > 0 ? (_tax / _income * 100) : 0;
  double get _netIncome => _income - _tax;

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
          title: Text('Income Tax Calculator', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(child: Column(children: [
            _resultCard(), _regimeToggle(), _sliders(), _breakdown(),
            const SizedBox(height: 8), _comparisonCard(),
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
      Text('Tax Payable (${_isNewRegime ? "New" : "Old"} Regime)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_tax), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Gross Income', AppSettings.instance.formatShort(_income)),
        _vDiv(), _stat('Net Income', AppSettings.instance.formatShort(_netIncome)),
        _vDiv(), _stat('Effective\nRate', '${_effectiveRate.toStringAsFixed(1)}%'),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _regimeToggle() => Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.border)),
    child: Row(children: [
      _regimeBtn('New Regime', true), _regimeBtn('Old Regime', false),
    ]),
  ));

  Widget _regimeBtn(String label, bool isNew) => Expanded(child: GestureDetector(
    onTap: () => setState(() => _isNewRegime = isNew),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _isNewRegime == isNew ? _accent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _isNewRegime == isNew ? Colors.white : context.textSub)),
    ),
  ));

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Annual Gross Income', value: _income, min: 100000, max: 10000000, divisions: 198, color: _accent, minLabel: '₹1L', maxLabel: '₹1Cr', isRupee: true, onChanged: (v) => setState(() => _income = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Your Age', value: _age, min: 18, max: 85, divisions: 67, color: const Color(0xFF6366F1), minLabel: '18', maxLabel: '85', suffix: ' yrs', onChanged: (v) => setState(() => _age = v)),
    if (!_isNewRegime) ...[
      const SizedBox(height: 12),
      SliderInputCard(label: '80C Deductions (LIC, PPF, ELSS...)', value: _deductions80C, min: 0, max: 150000, divisions: 30, color: const Color(0xFFD97706), minLabel: '₹0', maxLabel: '₹1.5L', isRupee: true, onChanged: (v) => setState(() => _deductions80C = v)),
      const SizedBox(height: 12),
      SliderInputCard(label: '80D Deductions (Health Insurance)', value: _deductions80D, min: 0, max: 75000, divisions: 15, color: const Color(0xFFDC2626), minLabel: '₹0', maxLabel: '₹75K', isRupee: true, onChanged: (v) => setState(() => _deductions80D = v)),
      const SizedBox(height: 12),
      SliderInputCard(label: 'HRA Exemption', value: _hra, min: 0, max: 500000, divisions: 100, color: const Color(0xFF7C3AED), minLabel: '₹0', maxLabel: '₹5L', isRupee: true, onChanged: (v) => setState(() => _hra = v)),
    ],
  ]));

  Widget _breakdown() {
    final rows = <(String, String, Color)>[
      ('Gross income', AppSettings.instance.formatRupee(_income, noDecimals: true), context.text),
      if (!_isNewRegime) ...[
        ('80C deductions', '- ${AppSettings.instance.formatRupee(_deductions80C, noDecimals: true)}', const Color(0xFFD97706)),
        ('80D deductions', '- ${AppSettings.instance.formatRupee(_deductions80D, noDecimals: true)}', const Color(0xFFD97706)),
        if (_hra > 0) ('HRA exemption', '- ${AppSettings.instance.formatRupee(_hra, noDecimals: true)}', const Color(0xFFD97706)),
        ('Standard deduction', '- ₹ 50,000', const Color(0xFFD97706)),
      ] else ...[
        ('Standard deduction', '- ₹ 75,000', const Color(0xFFD97706)),
      ],
      ('Tax payable (incl. 4% cess)', AppSettings.instance.formatRupee(_tax, noDecimals: true), const Color(0xFFDC2626)),
      ('Net income after tax', AppSettings.instance.formatRupee(_netIncome, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tax Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _comparisonCard() {
    final oldTax = _oldRegimeTax;
    final newTax = _newRegimeTax;
    final savings = (oldTax - newTax).abs();
    final betterRegime = newTax <= oldTax ? 'New Regime' : 'Old Regime';
    return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.compare_arrows_rounded, color: Color(0xFF059669), size: 18),
          const SizedBox(width: 8),
          Text('Regime Comparison', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.text)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Old Regime Tax:', style: TextStyle(fontSize: 12, color: context.textSub)),
          Text(AppSettings.instance.formatRupee(oldTax, noDecimals: true), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.text)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('New Regime Tax:', style: TextStyle(fontSize: 12, color: context.textSub)),
          Text(AppSettings.instance.formatRupee(newTax, noDecimals: true), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.text)),
        ]),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF059669).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text('$betterRegime saves you ${AppSettings.instance.formatRupee(savings, noDecimals: true)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669)))),
          ]),
        ),
      ]),
    ));
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About Income Tax', accentColor: _accent, items: const [
    InfoItem(icon: Icons.lightbulb_rounded, title: 'New vs Old Regime', blocks: [
      InfoBlock.bullets([
        'New Regime: Lower rates but fewer deductions',
        'Old Regime: Higher rates but 80C, 80D, HRA deductions available',
        'New Regime is default from FY 2023-24',
        'Choose based on your deduction profile',
      ]),
    ]),
  ]);
}
