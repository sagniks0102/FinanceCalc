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

class SIPCalculatorScreen extends StatefulWidget {
  const SIPCalculatorScreen({super.key});

  @override
  State<SIPCalculatorScreen> createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  double _monthly = 5000;
  double _rate = 12;
  double _years = 10;
  double _stepUp = 10; // % increase per year

  static const Color _accent = Color(0xFF10B981);
  static const Color _accent2 = Color(0xFF34D399);

  // Step-up SIP: each year monthly investment grows by _stepUp %
  // Total invested = sum of (monthly * 12 * (1+g)^y) for y=0..n-1
  // Maturity = sum over each year of FV of that year's annuity at end
  double get _invested {
    if (_stepUp == 0) return _monthly * _years * 12;
    double total = 0;
    double m = _monthly;
    for (int y = 0; y < _years.toInt(); y++) {
      total += m * 12;
      m *= (1 + _stepUp / 100);
    }
    return total;
  }

  double get _maturity {
    if (_stepUp == 0) {
      final r = _rate / 12 / 100;
      final n = _years * 12;
      return _monthly * ((pow(1 + r, n) - 1) / r) * (1 + r);
    }
    // Step-up: each year contributes its own FV
    final r = _rate / 12 / 100;
    double total = 0;
    double m = _monthly;
    final totalMonths = _years.toInt() * 12;
    for (int y = 0; y < _years.toInt(); y++) {
      final monthsRemaining = totalMonths - (y * 12);
      // FV of an annuity-due for this year's monthly amount
      final fv = m * ((pow(1 + r, monthsRemaining) - 1) / r) * (1 + r);
      total += fv;
      m *= (1 + _stepUp / 100);
    }
    return total;
  }
  double get _totalGains => _maturity - _invested;
  double get _gainsFraction =>
      _maturity > 0 ? _totalGains / _maturity : 0;

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
            'SIP Calculator'.tr,
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
      gradient: LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Maturity Value'.tr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
        _stat('Est. Returns'.tr, AppSettings.instance.formatShort(_totalGains)),
        _vDiv(),
        _stat('Return Rate'.tr, '${_rate.toStringAsFixed(1)}% p.a.'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(90, 90),
              painter: _SIPDonut(fraction: _gainsFraction,
                  c1: Colors.white, c2: const Color(0xFF6EE7B7))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(_gainsFraction * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            Text('returns'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
          ]),
        ])),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Amount invested'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFF6EE7B7), 'Est. returns'.tr),
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
        label: 'Monthly Investment'.tr,
        value: _monthly, min: 100, max: 100000, divisions: 999,
        color: _accent, minLabel: '₹100', maxLabel: '₹1L',
        isRupee: true,
        onChanged: (v) => setState(() => _monthly = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Expected Return Rate (p.a.)'.tr,
        value: _rate, min: 1, max: 30, divisions: 58,
        color: _accent2, minLabel: '1%', maxLabel: '30%',
        suffix: '%', isDecimal: true,
        onChanged: (v) => setState(() => _rate = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Investment Period'.tr,
        value: _years, min: 1, max: 40, divisions: 39,
        color: const Color(0xFF06B6D4), minLabel: '1 yr', maxLabel: '40 yrs',
        suffix: ' yrs',
        onChanged: (v) => setState(() => _years = v),
      ),
      const SizedBox(height: 12),
      _stepUpCard(),
    ]),
  );

  Widget _stepUpCard() {
    final nextYearAmt = _monthly * (1 + _stepUp / 100);
    return Column(children: [
      SliderInputCard(
        label: 'Yearly Step-up'.tr,
        value: _stepUp, min: 0, max: 50, divisions: 50,
        color: const Color(0xFFF59E0B),
        minLabel: '0% (No step-up)', maxLabel: '50%',
        suffix: '%',
        onChanged: (v) => setState(() => _stepUp = v),
      ),
      if (_stepUp > 0) ...[  
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD97706)),
          ),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded,
                size: 16, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 11, color: Color(0xFFD97706)),
                  children: [
                    const TextSpan(text: 'Year 1: '),
                    TextSpan(
                      text: '${AppSettings.instance.formatRupee(_monthly)}/mo',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: '  →  Year 2: '),
                    TextSpan(
                      text: '${AppSettings.instance.formatRupee(nextYearAmt)}/mo',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ],
    ]);
  }

  Widget _breakdown() {
    final multiplier = _maturity / _invested;
    final absReturn = (_totalGains / _invested) * 100;
    final rows = [
      ('Starting monthly SIP'.tr, AppSettings.instance.formatRupee(_monthly), context.text),
      if (_stepUp > 0)
        ('Step-up rate'.tr, '${_stepUp.toStringAsFixed(0)}% per year', context.text),
      ('Total investment'.tr, AppSettings.instance.formatRupee(_invested, noDecimals: true), context.text),
      ('Expected return rate'.tr, '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Investment period'.tr, '${_years.toInt()} years', context.text),
      ('Est. returns'.tr, AppSettings.instance.formatRupee(_totalGains, noDecimals: true), const Color(0xFF10B981)),
      ('Maturity value'.tr, AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF10B981)),
      ('Wealth multiplier'.tr, '${multiplier.toStringAsFixed(2)}x', const Color(0xFF10B981)),
      ('Absolute returns'.tr, '${absReturn.toStringAsFixed(1)}%', const Color(0xFF10B981)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SIP Breakdown'.tr,
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
    final int totalMonths = (_years * 12).toInt();
    final double r = _rate / 12 / 100;
    
    double balance = 0;
    double m = _monthly;
    
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();

    final Map<int, List<Map<String, dynamic>>> byYear = {};
    for (int i = 0; i < totalMonths; i++) {
      if (i > 0 && i % 12 == 0) {
        m *= (1 + _stepUp / 100);
      }
      
      final date = DateTime(now.year, now.month + i - 1 + 1); // just to match month
      final interest = (balance + m) * r;
      balance = balance + m + interest;
      
      byYear.putIfAbsent(date.year, () => []).add({
        'monthName': monthNames[date.month - 1],
        'invested': m,
        'interest': interest,
        'balance': balance,
      });
    }

    return BreakdownTable(
      title: 'Investment Details (Yearly/Monthly)',
      accentColor: _accent,
      columns: [
        BreakdownColumn(title: 'Month', color: context.textSub, key: 'monthName', align: TextAlign.left, width: 44),
        BreakdownColumn(title: 'Invested', color: _accent, key: 'invested'),
        BreakdownColumn(title: 'Returns', color: _accent2, key: 'interest'),
        BreakdownColumn(title: 'Balance', color: context.textSub, key: 'balance', align: TextAlign.right),
      ],
      byYear: byYear,
    );
  }

  Widget _infoSection() => CalculatorInfoSection(
    title: 'About SIP Calculator',
    accentColor: const Color(0xFF10B981),
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is SIP?',
        blocks: [
          InfoBlock.paragraph(
            'A Systematic Investment Plan (SIP) is a disciplined way to invest a fixed amount in mutual funds at regular intervals — typically monthly. '
            'It leverages rupee cost averaging and the power of compounding to build long-term wealth.',
          ),
          InfoBlock.paragraph(
            'SIP is ideal for salaried individuals who want to invest a portion of their income regularly without trying to time the market.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is SIP calculated?',
        blocks: [
          InfoBlock.formula(
            'Maturity = M × [((1+r)ⁿ − 1) / r] × (1+r)\n\n'
            'M = Monthly investment amount\n'
            'r = Monthly return rate (Annual rate ÷ 12 ÷ 100)\n'
            'n = Total months (Years × 12)',
          ),
          InfoBlock.tip('The Step-up SIP feature increases your monthly investment each year by a percentage, amplifying your wealth creation significantly.'),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'Rupee cost averaging — buy more units when price is low',
              'Power of compounding grows wealth exponentially',
              'Start with as little as ₹100/month',
              'Flexible — pause, stop, or increase anytime',
              'No need to time the market',
            ],
            cons: [
              'Returns not guaranteed — depend on market performance',
              'Short-term volatility can cause temporary losses',
              'Requires patience — best results over 7+ years',
              'Exit load may apply on early redemption',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Increase SIP amount by 10% every year (Step-up SIP) to outpace inflation.',
            'Stay invested through market corrections — don\'t stop SIP when markets fall.',
            'Choose Direct plans over Regular plans — lower expense ratio, higher returns.',
            'Diversify across large-cap, mid-cap, and flexi-cap funds.',
            'Set a clear goal (retirement, education, home) before starting a SIP.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information',
        blocks: [
          InfoBlock.paragraph('Each SIP instalment is treated as a separate investment for tax calculation purposes.'),
          InfoBlock.bullets([
            'Equity funds held > 1 year: 12.5% LTCG on gains above ₹1.25L/year.',
            'Equity funds held < 1 year: 20% STCG.',
            'ELSS (Tax-Saving) funds: up to ₹1.5L deduction under Section 80C with 3-year lock-in.',
            'Debt funds: taxed as per income slab (post Apr 2023).',
          ]),
        ],
      ),
    ],
  );
}

class _SIPDonut extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _SIPDonut({required this.fraction, required this.c1, required this.c2});

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
  bool shouldRepaint(_SIPDonut old) => old.fraction != fraction;
}
