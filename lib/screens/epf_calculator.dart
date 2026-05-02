import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class EPFCalculatorScreen extends StatefulWidget {
  const EPFCalculatorScreen({super.key});

  @override
  State<EPFCalculatorScreen> createState() => _EPFCalculatorScreenState();
}

class _EPFCalculatorScreenState extends State<EPFCalculatorScreen> {
  double _basicSalary = 30000;      // Monthly salary (Basic + DA)
  double _currentAge  = 26;         // Current age
  double _retirementAge = 58;       // Retirement age (fixed default)
  double _employeeContrib = 12.0;   // Employee contribution %
  double _salaryGrowth = 5.0;       // Annual salary increase %

  // Fixed by EPFO — not user-editable
  static const double _rate = 8.25;
  static const double _employerEpfRate = 3.67; // actual EPF portion

  static const Color _accent  = Color(0xFFF59E0B);
  static const Color _accent2 = Color(0xFFFBBF24);

  double get _years => (_retirementAge - _currentAge).clamp(0, 42).toDouble();

  // Month-by-month corpus calculation with salary growth
  double get _totalCorpus {
    final r = _rate / 12 / 100;
    final totalMonths = (_years * 12).toInt();
    double corpus = 0;
    for (int month = 0; month < totalMonths; month++) {
      final yearIndex = month ~/ 12;
      final salary = _basicSalary * pow(1 + _salaryGrowth / 100, yearIndex);
      final monthlyEmployee = salary * _employeeContrib / 100;
      final monthlyEmployer = salary * _employerEpfRate / 100;
      final monthlyTotal = monthlyEmployee + monthlyEmployer;
      final monthsToGrow = totalMonths - month;
      corpus += monthlyTotal * pow(1 + r, monthsToGrow);
    }
    return corpus;
  }

  double get _totalInvested {
    final totalMonths = (_years * 12).toInt();
    double invested = 0;
    for (int month = 0; month < totalMonths; month++) {
      final yearIndex = month ~/ 12;
      final salary = _basicSalary * pow(1 + _salaryGrowth / 100, yearIndex);
      invested += salary * (_employeeContrib + _employerEpfRate) / 100;
    }
    return invested;
  }

  double get _totalInterest => _totalCorpus - _totalInvested;
  double get _interestFraction =>
      _totalCorpus > 0 ? _totalInterest / _totalCorpus : 0;

  // Final year salary
  double get _finalSalary =>
      _basicSalary * pow(1 + _salaryGrowth / 100, _years.toInt());

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
              decoration: BoxDecoration(
                color: context.text.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: context.text, size: 20),
            ),
          ),
          title: Text(
            'EPF Calculator'.tr,
            style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: SingleChildScrollView(
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
    );
  }

  Widget _resultCard() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Total EPF Corpus at Retirement'.tr,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(children: [
            const TextSpan(
              text: '₹ ',
              style: TextStyle(color: Colors.white, fontSize: 25,
                  fontWeight: FontWeight.w500, height: 1.6),
            ),
            TextSpan(
              text: AppSettings.instance.formatNumber(_totalCorpus),
              style: const TextStyle(color: Colors.white, fontSize: 38,
                  fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
            TextSpan(
              text: '  (${AppSettings.instance.formatShortWord(_totalCorpus)})',
              style: const TextStyle(color: Colors.white70, fontSize: 15,
                  fontWeight: FontWeight.w500, height: 2.4),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Invested'.tr, AppSettings.instance.formatShort(_totalInvested)),
        _vDiv(),
        _stat('Interest'.tr, AppSettings.instance.formatShort(_totalInterest)),
        _vDiv(),
        _stat('Years'.tr, '${_years.toInt()} yrs'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(size: const Size(90, 90),
                painter: _EPFDonut(fraction: _interestFraction,
                    c1: Colors.white, c2: const Color(0xFFFDE68A))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(_interestFraction * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const Text('interest', style: TextStyle(color: Colors.white60, fontSize: 9)),
            ]),
          ]),
        ),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Total contributed'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFFFDE68A), 'Interest earned'.tr),
        ]),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13,
        fontWeight: FontWeight.w500)),
  ]));

  Widget _vDiv() => Container(width: 1, height: 32,
      color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _lgd(Color c, String l) => Row(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Widget _sliders() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      // Monthly salary (Basic + DA)
      SliderInputCard(
        label: 'Monthly salary (Basic + DA)'.tr,
        value: _basicSalary, min: 5000, max: 200000, divisions: 195,
        color: _accent, minLabel: '₹5K', maxLabel: '₹2L',
        isRupee: true,
        onChanged: (v) => setState(() => _basicSalary = v),
      ),
      const SizedBox(height: 12),
      // Current Age
      SliderInputCard(
        label: 'Your Age'.tr,
        value: _currentAge,
        min: 18,
        max: (_retirementAge - 1).clamp(18, 57).toDouble(),
        divisions: ((_retirementAge - 1).clamp(18, 57) - 18).toInt().clamp(1, 39),
        color: _accent2, minLabel: '18 yr', maxLabel: '57 yr',
        suffix: ' yr',
        onChanged: (v) => setState(() {
          _currentAge = v;
          if (_retirementAge <= _currentAge) {
            _retirementAge = _currentAge + 1;
          }
        }),
      ),
      const SizedBox(height: 12),
      // Retirement Age
      SliderInputCard(
        label: 'Retirement Age'.tr,
        value: _retirementAge,
        min: (_currentAge + 1).clamp(19, 60).toDouble(),
        max: 60,
        divisions: (60 - (_currentAge + 1).clamp(19, 60)).toInt().clamp(1, 41),
        color: const Color(0xFF6366F1),
        minLabel: '${(_currentAge + 1).toInt()} yr',
        maxLabel: '60 yr',
        suffix: ' yr',
        onChanged: (v) => setState(() => _retirementAge = v),
      ),
      const SizedBox(height: 12),
      // Employee contribution
      SliderInputCard(
        label: 'Your contribution to EPF'.tr,
        value: _employeeContrib, min: 12, max: 20, divisions: 8,
        color: const Color(0xFF06B6D4), minLabel: '12%', maxLabel: '20%',
        suffix: '%', isDecimal: true,
        onChanged: (v) => setState(() => _employeeContrib = v),
      ),
      const SizedBox(height: 12),
      // Annual salary increase
      SliderInputCard(
        label: 'Annual increase in salary'.tr,
        value: _salaryGrowth, min: 0, max: 20, divisions: 40,
        color: const Color(0xFF059669), minLabel: '0%', maxLabel: '20%',
        suffix: '%', isDecimal: true,
        onChanged: (v) => setState(() => _salaryGrowth = v),
      ),
      const SizedBox(height: 12),
      // Fixed Rate of Interest display
      _fixedRateCard(),
    ]),
  );

  /// Non-editable card showing the fixed EPFO interest rate
  Widget _fixedRateCard() => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.border),
    ),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Note: EPF interest is compounded yearly on monthly balances.',
            style: TextStyle(fontSize: 12, color: context.textSub)),
          const SizedBox(height: 4),
          Text('Fixed by EPFO — updated annually',
              style: TextStyle(fontSize: 10, color: context.textSub)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.border),
        ),
        child: Text(
          '${_rate.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.textSub,
          ),
        ),
      ),
    ]),
  );

  Widget _breakdown() {
    final monthlyEmployee = _basicSalary * _employeeContrib / 100;
    final monthlyEmployer = _basicSalary * _employerEpfRate / 100;
    final totalEmployeeCont = _totalInvested * (_employeeContrib / (_employeeContrib + _employerEpfRate));
    final totalEmployerCont = _totalInvested * (_employerEpfRate / (_employeeContrib + _employerEpfRate));

    final rows = [
      ('Current basic salary'.tr,               AppSettings.instance.formatRupee(_basicSalary, noDecimals: true) + '/mo', context.text),
      ('Current total EPF contribution'.tr,     AppSettings.instance.formatRupee(monthlyEmployee + monthlyEmployer, noDecimals: true) + '/mo', context.text),
      ('Total employee contribution'.tr,        AppSettings.instance.formatRupee(totalEmployeeCont, noDecimals: true),   context.text),
      ('Total employer contribution'.tr,        AppSettings.instance.formatRupee(totalEmployerCont, noDecimals: true),   context.text),
      ('Total invested amount'.tr,              AppSettings.instance.formatRupee(_totalInvested, noDecimals: true),      context.text),
      ('Total interest earned'.tr,              AppSettings.instance.formatRupee(_totalInterest, noDecimals: true),      const Color(0xFF059669)),
      ('Total EPF corpus'.tr,                   AppSettings.instance.formatRupee(_totalCorpus, noDecimals: true),        const Color(0xFF059669)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EPF Breakdown'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: context.text)),
          const SizedBox(height: 10),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.border))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(r.$1,
                  style: TextStyle(fontSize: 12, color: context.textSub))),
              const SizedBox(width: 8),
              Text(r.$2, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w500, color: r.$3)),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _infoSection() => CalculatorInfoSection(
    title: 'About EPF Calculator',
    accentColor: _accent,
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is EPF?',
        blocks: [
          InfoBlock.paragraph(
            'The Employees\' Provident Fund (EPF) is a mandatory retirement savings scheme for salaried employees in India, managed by EPFO. '
            'Both you and your employer contribute a % of your Basic + DA salary each month.',
          ),
          InfoBlock.paragraph(
            'Of the employer\'s 12%, only 3.67% goes to your EPF account. The remaining 8.33% goes to EPS (Employee Pension Scheme).',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is EPF corpus calculated?',
        blocks: [
          InfoBlock.paragraph('Calculated month-by-month accounting for salary growth:'),
          InfoBlock.formula(
            'For each month m:\n'
            '  Salary_m = BasicSalary × (1 + Growth%)^year\n'
            '  Contrib_m = Salary_m × (Emp% + 3.67%) / 100\n'
            '  FV_m = Contrib_m × (1 + r)^months_remaining\n\n'
            'Total Corpus = Σ FV_m\n'
            'r = 8.25% ÷ 12 ÷ 100 (monthly rate)',
          ),
          InfoBlock.tip('Rate of interest (8.25% for FY 2023-24) is fixed by EPFO and announced annually.'),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'EEE tax status — contributions, interest & maturity tax-free (5+ years)',
              'Employer contributes too — free retirement savings',
              'Government-guaranteed interest rate',
              'UAN makes it portable across jobs',
              'Emergency withdrawals allowed for specific needs',
            ],
            cons: [
              'Locked until retirement (age 58) with limited access',
              'Rate declared annually — can change',
              'Returns may lag equity over a 30-year horizon',
              'EPS portion gives pension, not a corpus',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Contribute to VPF (Voluntary PF) above 12% for extra tax-free savings.',
            'Never withdraw EPF on job change — transfer via UAN to keep compounding intact.',
            'Link Aadhaar + PAN to UAN for seamless claims.',
            'Higher salary growth assumption = more accurate long-term projection.',
            'EPFO allows partial withdrawal for education, home purchase, and medical needs.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information',
        blocks: [
          InfoBlock.bullets([
            'Employee contribution (up to 12%): deductible under Section 80C (₹1.5L limit).',
            'Interest: tax-free if employee contribution ≤ ₹2.5L/year.',
            'Withdrawal after 5 continuous years: fully tax-free.',
            'Withdrawal before 5 years: taxable + TDS applies.',
          ]),
          InfoBlock.caution(
            'Withdrawing EPF before 5 years of continuous service makes the entire amount taxable — including employer contribution.',
          ),
        ],
      ),
    ],
  );
}

class _EPFDonut extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _EPFDonut({required this.fraction, required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 8;
    const sw = 12.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(rect, 0, 2 * pi, false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);
    final a1 = (1 - fraction) * 2 * pi;
    canvas.drawArc(rect, -pi / 2, a1, false,
        Paint()
          ..color = c1
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -pi / 2 + a1, fraction * 2 * pi, false,
        Paint()
          ..color = c2
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_EPFDonut old) => old.fraction != fraction;
}
