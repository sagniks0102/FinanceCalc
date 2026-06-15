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

class LumpsumCalculatorScreen extends StatefulWidget {
  const LumpsumCalculatorScreen({super.key});

  @override
  State<LumpsumCalculatorScreen> createState() => _LumpsumCalculatorScreenState();
}

class _LumpsumCalculatorScreenState extends State<LumpsumCalculatorScreen> {
  double _investment = 100000;   // One-time investment amount
  double _rate       = 12.0;    // Expected annual return rate (%)
  double _years      = 10.0;    // Investment duration (years)

  static const Color _accent  = Color(0xFF0EA5E9); // sky blue
  static const Color _accent2 = Color(0xFF38BDF8);

  // FV = PV × (1 + r)^n
  double get _maturityValue => _investment * pow(1 + _rate / 100, _years);
  double get _totalGains    => _maturityValue - _investment;
  double get _gainsFraction => _maturityValue > 0 ? _totalGains / _maturityValue : 0;
  double get _cagr          => _rate; // simple: user sets expected rate

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
            'Lumpsum Calculator'.tr,
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
      gradient: LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Maturity Value'.tr,
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
              text: AppSettings.instance.formatNumber(_maturityValue),
              style: const TextStyle(color: Colors.white, fontSize: 38,
                  fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
            TextSpan(
              text: '  (${AppSettings.instance.formatShortWord(_maturityValue)})',
              style: const TextStyle(color: Colors.white70, fontSize: 15,
                  fontWeight: FontWeight.w500, height: 2.4),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Invested'.tr, AppSettings.instance.formatShort(_investment)),
        _vDiv(),
        _stat('Est. Returns'.tr, AppSettings.instance.formatShort(_totalGains)),
        _vDiv(),
        _stat('Return Rate'.tr, '${_rate.toStringAsFixed(1)}% p.a.'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: const Size(90, 90),
              painter: _LumpsumDonut(
                fraction: _gainsFraction,
                c1: Colors.white,
                c2: const Color(0xFFBAE6FD),
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                '${(_gainsFraction * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              Text('gains'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
            ]),
          ]),
        ),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Amount invested'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFFBAE6FD), 'Est. returns'.tr),
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
      SliderInputCard(
        label: 'Total Investment (Lump Sum)'.tr,
        value: _investment, min: 1000, max: 10000000, divisions: 999,
        color: _accent, minLabel: '₹1K', maxLabel: '₹1Cr',
        isRupee: true,
        onChanged: (v) => setState(() => _investment = v),
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
        label: 'Investment Duration'.tr,
        value: _years, min: 1, max: 40, divisions: 39,
        color: const Color(0xFF8B5CF6), minLabel: '1 yr', maxLabel: '40 yrs',
        suffix: ' yrs',
        onChanged: (v) => setState(() => _years = v),
      ),
    ]),
  );

  Widget _breakdown() {
    // Wealth multiplier: how many times money grew
    final multiplier = _maturityValue / _investment;
    // Absolute returns %
    final absReturn = (_totalGains / _investment) * 100;

    final rows = [
      ('Total investment'.tr,     AppSettings.instance.formatRupee(_investment, noDecimals: true),   context.text),
      ('Expected return rate'.tr, '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Investment period'.tr,    '${_years.toInt()} years', context.text),
      ('Est. returns'.tr,         AppSettings.instance.formatRupee(_totalGains, noDecimals: true),   const Color(0xFF0EA5E9)),
      ('Maturity value'.tr,       AppSettings.instance.formatRupee(_maturityValue, noDecimals: true), const Color(0xFF059669)),
      ('Wealth multiplier'.tr,    '${multiplier.toStringAsFixed(2)}x', const Color(0xFF0EA5E9)),
      ('Absolute returns'.tr,     '${absReturn.toStringAsFixed(1)}%', const Color(0xFF059669)),
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
          Text('Investment Summary'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: context.text)),
          const SizedBox(height: 10),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub)),
              Text(r.$2, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w500, color: r.$3)),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _amortizationTable() {
    final int totalMonths = (_years * 12).toInt();
    
    double balance = _investment;
    
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();

    final Map<int, List<Map<String, dynamic>>> byYear = {};
    for (int i = 0; i < totalMonths; i++) {
      final date = DateTime(now.year, now.month + i - 1 + 1); // just to match month
      final prevBalance = balance;
      balance = _investment * pow(1 + _rate / 100, (i + 1) / 12);
      final interest = balance - prevBalance;
      
      byYear.putIfAbsent(date.year, () => []).add({
        'monthName': monthNames[date.month - 1],
        'interest': interest,
        'balance': balance,
      });
    }

    return BreakdownTable(
      title: 'Growth Details (Yearly/Monthly)',
      accentColor: _accent,
      columns: [
        BreakdownColumn(title: 'Month', color: context.textSub, key: 'monthName', align: TextAlign.left, width: 44),
        BreakdownColumn(title: 'Returns', color: _accent2, key: 'interest'),
        BreakdownColumn(title: 'Balance', color: context.textSub, key: 'balance', align: TextAlign.right),
      ],
      byYear: byYear,
    );
  }

  Widget _infoSection() => CalculatorInfoSection(
    title: 'About Lumpsum Calculator',
    accentColor: _accent,
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is a Lumpsum Investment?',
        blocks: [
          InfoBlock.paragraph(
            'A lumpsum investment means investing the entire amount at once rather than in instalments (like SIP). '
            'You invest a single large sum and let it grow at the expected rate of return over a chosen period.',
          ),
          InfoBlock.paragraph(
            'Lumpsum investments are ideal when you have a large windfall (bonus, inheritance, sale proceeds) and want to put it to work immediately.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is it calculated?',
        blocks: [
          InfoBlock.formula(
            'Maturity Value = P × (1 + r)ⁿ\n\n'
            'P = Principal (lump sum invested)\n'
            'r = Expected annual return rate (decimal)\n'
            'n = Investment duration in years',
          ),
          InfoBlock.tip(
            'The power of compounding means your money grows exponentially. '
            'At 12% p.a., ₹1L doubles roughly every 6 years (Rule of 72).',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Lumpsum vs SIP',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'Entire corpus invested immediately — earns returns from day one',
              'Higher maturity value if market performs well over the period',
              'No need to track monthly instalments',
              'Simple one-time decision',
            ],
            cons: [
              'Market timing risk — investing at a peak can reduce returns',
              'No rupee cost averaging benefit',
              'Requires a large sum available upfront',
              'Emotionally harder to invest large amounts at once',
            ],
          ),
          InfoBlock.tip(
            'Use SIP for regular income; use Lumpsum for windfalls. '
            'The best strategy: Lumpsum for short-to-medium goals + SIP for long-term wealth.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Use the Rule of 72: divide 72 by return rate to estimate years to double your money.',
            'Invest lumpsum in equity funds via STP (Systematic Transfer Plan) to reduce timing risk.',
            'For amounts > ₹5L, consider splitting across 3–6 months to average entry price.',
            'Review the fund NAV trend before investing — avoid investing at all-time highs.',
            'Stay invested for the full tenure — premature exit is the #1 wealth destroyer.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information',
        blocks: [
          InfoBlock.bullets([
            'Equity mutual funds (held > 1 year): 12.5% LTCG on gains above ₹1.25L/year.',
            'Equity mutual funds (held < 1 year): 20% STCG.',
            'Debt funds: taxed as per income slab (post Apr 2023).',
            'ELSS funds: 3-year lock-in, ₹1.5L deduction under Section 80C.',
          ]),
          InfoBlock.caution(
            'Past returns are not indicative of future performance. Always check fund ratings, '
            'expense ratios, and fund manager track record before investing.',
          ),
        ],
      ),
    ],
  );
}

class _LumpsumDonut extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _LumpsumDonut({required this.fraction, required this.c1, required this.c2});

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
        Paint()..color = c1..style = PaintingStyle.stroke..strokeWidth = sw
            ..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -pi / 2 + a1, fraction * 2 * pi, false,
        Paint()..color = c2..style = PaintingStyle.stroke..strokeWidth = sw
            ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_LumpsumDonut old) => old.fraction != fraction;
}
