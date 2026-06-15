import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/breakdown_table.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/ad_helper.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class RDCalculatorScreen extends StatefulWidget {
  const RDCalculatorScreen({super.key});

  @override
  State<RDCalculatorScreen> createState() => _RDCalculatorScreenState();
}

class _RDCalculatorScreenState extends State<RDCalculatorScreen> {
  double _monthly = 5000;
  double _rate = 7.0;
  double _months = 12;

  static const Color _accent = Color(0xFF3B82F6);
  static const Color _accent2 = Color(0xFF60A5FA);

  // Standard Indian RD maturity formula (quarterly compounding):
  // Step 1: quarterly rate  r = annual_rate / 4 / 100
  // Step 2: equivalent monthly rate  m = (1+r)^(1/3) - 1
  // Step 3: FV of annuity-due = M × [(1+m)^n - 1] / m × (1+m)
  //         where n = total months
  double get _maturity {
    final r = _rate / 400; // quarterly rate
    final m = pow(1 + r, 1 / 3).toDouble() - 1; // effective monthly rate
    final n = _months.toInt();
    if (m == 0) return _monthly * n;
    return _monthly * (pow(1 + m, n) - 1) / m * (1 + m);
  }

  double get _invested => _monthly * _months;
  double get _interest => (_maturity - _invested).clamp(0.0, double.infinity);
  double get _interestFraction =>
      _maturity > 0 ? (_interest / _maturity).clamp(0.0, 1.0) : 0.0;

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
            'RD Calculator'.tr,
            style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [
              _resultCard(),
              _sliders(),
              _breakdown(),
              const SizedBox(height: 12),
              _amortizationTable(),
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
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Maturity Amount'.tr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: '₹ ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              TextSpan(
                text: AppSettings.instance.formatNumber(_maturity),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: '  (${AppSettings.instance.formatShortWord(_maturity)})',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 2.4,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Invested'.tr, AppSettings.instance.formatShort(_invested)),
        _vDiv(),
        _stat('Interest Earned'.tr, AppSettings.instance.formatShort(_interest)),
        _vDiv(),
        _stat('Rate'.tr, '${_rate.toStringAsFixed(1)}%'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(90, 90),
              painter: _RDDonut(fraction: _interestFraction,
                  c1: Colors.white, c2: const Color(0xFF93C5FD))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(_interestFraction * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            Text('interest'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
          ]),
        ])),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Total deposited'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFF93C5FD), 'Interest earned'.tr),
        ]),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));

  Widget _vDiv() => Container(width: 1, height: 32,
      color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _lgd(Color c, String l) => Row(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Widget _sliders() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      SliderInputCard(
        label: 'Monthly Deposit'.tr,
        value: _monthly, min: 100, max: 100000, divisions: 199,
        color: _accent, minLabel: '₹100', maxLabel: '₹1L',
        isRupee: true,
        onChanged: (v) => setState(() => _monthly = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Annual Interest Rate'.tr,
        value: _rate, min: 1, max: 15, divisions: 140,
        color: _accent2, minLabel: '1%', maxLabel: '15%',
        suffix: '%', isDecimal: true,
        onChanged: (v) => setState(() => _rate = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Tenure'.tr,
        value: _months, min: 1, max: 120, divisions: 119,
        color: const Color(0xFF06B6D4), minLabel: '1 mo', maxLabel: '120 mo',
        suffix: ' mo',
        onChanged: (v) => setState(() => _months = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Monthly deposit'.tr, AppSettings.instance.formatRupee(_monthly, noDecimals: true), context.text),
      ('Tenure'.tr, '${_months.toInt()} months', context.text),
      ('Interest rate'.tr, '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Total investment'.tr, AppSettings.instance.formatRupee(_invested, noDecimals: true), context.text),
      ('Total interest earned'.tr, AppSettings.instance.formatRupee(_interest, noDecimals: true), _accent),
      ('Maturity value'.tr, AppSettings.instance.formatRupee(_maturity, noDecimals: true), _accent),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RD Breakdown'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
          const SizedBox(height: 10),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub)),
              Text(r.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: r.$3)),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _amortizationTable() {
    final int totalMonths = _months.toInt();
    final double r = _rate / 400; // quarterly rate
    final double m = pow(1 + r, 1 / 3).toDouble() - 1; // effective monthly rate
    
    double balance = 0;
    
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();

    final Map<int, List<Map<String, dynamic>>> byYear = {};
    for (int i = 0; i < totalMonths; i++) {
      final date = DateTime(now.year, now.month + i - 1 + 1);
      final prevBalance = balance;
      
      balance = (balance + _monthly) * (1 + m);
      final interest = balance - prevBalance - _monthly;
      
      byYear.putIfAbsent(date.year, () => []).add({
        'monthName': monthNames[date.month - 1],
        'invested': _monthly,
        'interest': interest,
        'balance': balance,
      });
    }

    return BreakdownTable(
      title: 'Deposit Details (Yearly/Monthly)',
      accentColor: _accent,
      columns: [
        BreakdownColumn(title: 'Month', color: context.textSub, key: 'monthName', align: TextAlign.left, width: 44),
        BreakdownColumn(title: 'Deposit', color: _accent, key: 'invested'),
        BreakdownColumn(title: 'Interest', color: _accent2, key: 'interest'),
        BreakdownColumn(title: 'Balance', color: context.textSub, key: 'balance', align: TextAlign.right),
      ],
      byYear: byYear,
    );
  }

  Widget _infoSection() => CalculatorInfoSection(
    title: 'About RD Calculator',
    accentColor: const Color(0xFF3B82F6),
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is a Recurring Deposit?',
        blocks: [
          InfoBlock.paragraph(
            'A Recurring Deposit (RD) is a savings scheme offered by banks where you deposit a fixed amount every month for a predetermined period and earn interest. '
            'It combines the discipline of SIP with the safety of a fixed deposit.',
          ),
          InfoBlock.paragraph('Banks typically compound RD interest quarterly, and the maturity amount is paid at the end of the tenure.'),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is RD maturity calculated?',
        blocks: [
          InfoBlock.formula(
            'Maturity = M × [(1+r)ⁿ − 1] / [1 − (1+r)^(−1/3)]\n\n'
            'M  = Monthly deposit\n'
            'r  = Quarterly interest rate (Annual rate ÷ 400)\n'
            'n  = Number of quarters',
          ),
          InfoBlock.tip('The RD formula uses quarterly compounding as per standard Indian bank practice.'),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'Builds savings habit with small monthly amounts',
              'Guaranteed returns — not market-linked',
              'DICGC insured up to ₹5L',
              'Flexible tenures from 6 months to 10 years',
              'Loan against RD available',
            ],
            cons: [
              'Interest is fully taxable as income',
              'Penalty on missed monthly instalment',
              'Lower returns than equity or mutual funds',
              'Premature closure penalty typically 1%',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Compare RD rates across banks — small finance banks often give higher rates.',
            'Consider a SIP in debt funds instead of RD for potentially better post-tax returns.',
            'Set auto-debit on salary date to never miss an instalment.',
            'Senior citizens get higher interest rates — check with your bank.',
            'Use RD for short-term goals (6 months to 3 years) where safety matters most.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information',
        blocks: [
          InfoBlock.bullets([
            'RD interest is taxable as income, added to your total income and taxed at slab rate.',
            'TDS of 10% is deducted if annual interest across all deposits in a bank exceeds ₹40,000.',
            'Submit Form 15G (or 15H for seniors) to avoid TDS if income is below taxable limit.',
            'No Section 80C benefit available on RDs (unlike Tax-Saving FD).',
          ]),
        ],
      ),
    ],
  );
}

class _RDDonut extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _RDDonut({required this.fraction, required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 8;
    const sw = 12.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(rect, 0, 2 * pi, false,
        Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = sw);
    final a1 = (1 - fraction) * 2 * pi;
    canvas.drawArc(rect, -pi / 2, a1, false,
        Paint()..color = c1..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -pi / 2 + a1, fraction * 2 * pi, false,
        Paint()..color = c2..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RDDonut old) => old.fraction != fraction;
}
