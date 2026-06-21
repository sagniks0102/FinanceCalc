import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class PLICalculatorScreen extends StatefulWidget {
  const PLICalculatorScreen({super.key});
  @override
  State<PLICalculatorScreen> createState() => _PLICalculatorScreenState();
}

class _PLICalculatorScreenState extends State<PLICalculatorScreen> {
  double _sumAssured = 500000;
  double _entryAge = 25;
  double _maturityAge = 55;
  String _policyType = 'Endowment'; // 'Endowment' or 'Whole Life'

  static const Color _accent = Color(0xFF0D9488);

  double get _termYears => (_maturityAge - _entryAge).clamp(5, 50).toDouble();

  // Premium per ₹1000 sum assured approx rate based on age & term
  double get _premiumRate {
    final term = _termYears;
    if (_policyType == 'Endowment') {
      // Shorter term means higher premium
      return (1000 / (term * 12)) * 1.05;
    } else {
      // Whole Life has lower premium rate factor
      return (1000 / (term * 12)) * 0.85;
    }
  }

  double get _monthlyPremium => (_sumAssured / 1000) * _premiumRate;
  double get _gst => _monthlyPremium * 0.045; // 4.5% GST first year
  double get _totalMonthly => _monthlyPremium + _gst;

  // PLI has high bonus rates (approx ₹52 per ₹1000 SA for Endowment, ₹76 for Whole Life)
  double get _bonusRatePer1000 {
    return _policyType == 'Endowment' ? 52.0 : 76.0;
  }

  double get _annualBonus => (_sumAssured / 1000) * _bonusRatePer1000;
  double get _totalBonus => _annualBonus * _termYears;
  double get _maturityAmount => _sumAssured + _totalBonus;
  double get _totalPremiumPaid => _totalMonthly * _termYears * 12;

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
          title: Text('Postal Life Insurance', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [
              _resultCard(),
              _policyTypeSelector(),
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
      const Text('Expected Maturity Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
            TextSpan(text: AppSettings.instance.formatNumber(_maturityAmount), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Monthly Premium', AppSettings.instance.formatShort(_totalMonthly)),
        _vDiv(),
        _stat('Total Bonus', AppSettings.instance.formatShort(_totalBonus)),
        _vDiv(),
        _stat('Premium Paid', AppSettings.instance.formatShort(_totalPremiumPaid)),
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

  Widget _policyTypeSelector() => Padding(
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
              onTap: () => setState(() => _policyType = 'Endowment'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _policyType == 'Endowment' ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Endowment (Santhosh)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _policyType == 'Endowment' ? FontWeight.w600 : FontWeight.normal,
                    color: _policyType == 'Endowment' ? Colors.white : context.textSub,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _policyType = 'Whole Life';
                // Whole life maturity is age 80, but premium can stop at 55 or 60. Let's make it 60
                if (_maturityAge < 60) _maturityAge = 60;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _policyType == 'Whole Life' ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Whole Life (Suraksha)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _policyType == 'Whole Life' ? FontWeight.w600 : FontWeight.normal,
                    color: _policyType == 'Whole Life' ? Colors.white : context.textSub,
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
        label: 'Sum Assured',
        value: _sumAssured,
        min: 20000,
        max: 5000000,
        divisions: 249,
        color: _accent,
        minLabel: '₹20K',
        maxLabel: '₹50L',
        isRupee: true,
        onChanged: (v) => setState(() => _sumAssured = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Age at Entry',
        value: _entryAge,
        min: 19,
        max: 55,
        divisions: 36,
        color: const Color(0xFF059669),
        minLabel: '19 yrs',
        maxLabel: '55 yrs',
        suffix: ' yrs',
        onChanged: (v) {
          setState(() {
            _entryAge = v;
            if (_maturityAge <= _entryAge) {
              _maturityAge = _entryAge + 5;
            }
          });
        },
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Age of Premium Cessation / Maturity',
        value: _maturityAge,
        min: _entryAge + 5,
        max: 60,
        divisions: (60 - (_entryAge + 5)).toInt().clamp(1, 100),
        color: const Color(0xFF6366F1),
        minLabel: '${(_entryAge + 5).toInt()} yrs',
        maxLabel: '60 yrs',
        suffix: ' yrs',
        onChanged: (v) => setState(() => _maturityAge = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Policy Type', _policyType == 'Endowment' ? 'Endowment Assurance (Santhosh)' : 'Whole Life Assurance (Suraksha)', context.text),
      ('Policy Term', '${_termYears.toInt()} years', context.text),
      ('Sum Assured', AppSettings.instance.formatRupee(_sumAssured, noDecimals: true), context.text),
      ('Monthly Basic Premium', AppSettings.instance.formatRupee(_monthlyPremium, noDecimals: true), context.text),
      ('GST (4.5%)', AppSettings.instance.formatRupee(_gst, noDecimals: true), context.text),
      ('Total Monthly Premium', AppSettings.instance.formatRupee(_totalMonthly, noDecimals: true), const Color(0xFF0D9488)),
      ('Annual Bonus Rate', '₹${_bonusRatePer1000.toInt()} per ₹1000 SA', context.text),
      ('Estimated Annual Bonus', AppSettings.instance.formatRupee(_annualBonus, noDecimals: true), context.text),
      ('Total Bonus (Accrued)', AppSettings.instance.formatRupee(_totalBonus, noDecimals: true), const Color(0xFF0D9488)),
      ('Maturity Amount (SA + Bonus)', AppSettings.instance.formatRupee(_maturityAmount, noDecimals: true), const Color(0xFF059669)),
      ('Total Premiums Paid', AppSettings.instance.formatRupee(_totalPremiumPaid, noDecimals: true), const Color(0xFFDC2626)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PLI Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
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

  Widget _infoSection() => CalculatorInfoSection(title: 'About Postal Life Insurance (PLI)', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is PLI?', blocks: [
      InfoBlock.paragraph('Postal Life Insurance (PLI) was introduced in 1884. It is the oldest life insurance scheme in India, offering high bonus rates and low premiums. Initially for postal employees, it is now open to professionals, employees of government, semi-government, and listed public companies.'),
    ]),
    InfoItem(icon: Icons.check_circle_outline, title: 'Eligibility & Limits', blocks: [
      InfoBlock.bullets([
        'Minimum Age: 19 Years, Maximum Age: 55 Years',
        'Minimum Sum Assured: ₹20,000, Maximum Sum Assured: ₹50 Lakhs',
        'Tax savings under Section 80C on premium paid',
        'Loan facility available after 3 years for Endowment policies',
        'Surrender facility available after 3 years (reduced sum assured & no bonus if surrendered before 5 years)',
      ]),
    ]),
  ]);
}
