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

class FDCalculatorScreen extends StatefulWidget {
  const FDCalculatorScreen({super.key});

  @override
  State<FDCalculatorScreen> createState() => _FDCalculatorScreenState();
}

class _FDCalculatorScreenState extends State<FDCalculatorScreen> {
  double _principal = 100000;
  double _rate = 7.0;
  double _months = 12;
  int _compFreq = 4; // 1=yearly 2=half 4=quarterly 12=monthly

  static const Color _accent = Color(0xFF14B8A6);
  static const Color _accent2 = Color(0xFF2DD4BF);

  final _freqLabels = {1: 'Yearly', 2: 'Half-Yearly', 4: 'Quarterly', 12: 'Monthly'};

  double get _maturity {
    final n = _compFreq * (_months / 12);
    final r = _rate / 100 / _compFreq;
    return _principal * pow(1 + r, n);
  }

  double get _interest => _maturity - _principal;
  double get _interestFraction => _interest / _maturity;

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
            'FD Calculator'.tr,
            style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [
              _resultCard(),
              _sliders(),
              _freqSelector(),
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
      gradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
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
        _stat('Principal'.tr, AppSettings.instance.formatShort(_principal)),
        _vDiv(), _stat('Interest Earned'.tr, AppSettings.instance.formatShort(_interest)),
        _vDiv(), _stat('Rate'.tr, '${_rate.toStringAsFixed(1)}%'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(90, 90),
              painter: _FDDonut(fraction: _interestFraction,
                  c1: Colors.white, c2: const Color(0xFF99F6E4))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(_interestFraction * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            Text('interest'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
          ]),
        ])),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Principal'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFF99F6E4), 'Interest earned'.tr),
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
        label: 'Principal Amount'.tr,
        value: _principal, min: 1000, max: 5000000, divisions: 99,
        color: _accent, minLabel: '₹1K', maxLabel: '₹50L',
        isRupee: true,
        onChanged: (v) => setState(() => _principal = v),
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
        color: const Color(0xFF6366F1), minLabel: '1 mo', maxLabel: '120 mo',
        suffix: ' mo',
        onChanged: (v) => setState(() => _months = v),
      ),
    ]),
  );

  Widget _freqSelector() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Compounding Frequency'.tr,
              style: TextStyle(fontSize: 12, color: context.textSub)),
        ),
        const SizedBox(height: 12),
        Row(children: _freqLabels.entries.map((e) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _compFreq = e.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _compFreq == e.key ? _accent : context.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(e.value, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: _compFreq == e.key ? Colors.white : context.textSub)),
            ),
          ),
        )).toList()),
      ]),
    ),
  );

  Widget _breakdown() {
    final rows = [
      ('Principal amount'.tr, AppSettings.instance.formatRupee(_principal, noDecimals: true), context.text),
      ('Total investment period'.tr, '${_months.toInt()} months', context.text),
      ('Interest earned'.tr, AppSettings.instance.formatRupee(_interest, noDecimals: true), const Color(0xFF059669)),
      ('Maturity amount'.tr, AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FD Breakdown'.tr,
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
    
    double balance = _principal;
    final r = _rate / 100 / _compFreq;
    
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();

    final Map<int, List<Map<String, dynamic>>> byYear = {};
    for (int i = 0; i < totalMonths; i++) {
      final date = DateTime(now.year, now.month + i - 1 + 1);
      final prevBalance = balance;
      
      final periods = (i + 1) / 12 * _compFreq;
      balance = _principal * pow(1 + r, periods);
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
        BreakdownColumn(title: 'Interest', color: _accent2, key: 'interest'),
        BreakdownColumn(title: 'Balance', color: context.textSub, key: 'balance', align: TextAlign.right),
      ],
      byYear: byYear,
    );
  }

  Widget _infoSection() => CalculatorInfoSection(
    title: 'About FD Calculator',
    accentColor: const Color(0xFF14B8A6),
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is a Fixed Deposit?',
        blocks: [
          InfoBlock.paragraph(
            'A Fixed Deposit (FD) is a financial instrument offered by banks and NBFCs where you deposit a lump sum for a fixed period at a predetermined interest rate. '
            'It is one of the safest investment options in India, backed by DICGC insurance up to ₹5 lakh.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is FD maturity calculated?',
        blocks: [
          InfoBlock.formula(
            'Maturity = P × (1 + r/n)^(n×t)\n\n'
            'P = Principal amount\n'
            'r = Annual interest rate (decimal)\n'
            'n = Compounding frequency per year\n'
            't = Tenure in years',
          ),
          InfoBlock.tip('Quarterly compounding gives slightly more than yearly compounding for the same rate. Always check the effective yield, not just the stated rate.'),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'Guaranteed returns — not market-linked',
              'DICGC insured up to ₹5L per bank',
              'Flexible tenure from 7 days to 10 years',
              'Senior citizens get 0.25–0.50% extra rate',
              'Loan against FD available (up to 90%)',
            ],
            cons: [
              'Lower returns vs. equity over long term',
              'Interest is fully taxable as per income slab',
              'TDS deducted if interest > ₹40K/year (non-senior)',
              'Premature withdrawal penalty (0.5–1%)',
              'Returns may not beat inflation over long periods',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Ladder your FDs (e.g., 1yr + 2yr + 3yr) for liquidity and better average rates.',
            'Compare small finance banks — they often offer 0.5–1% higher rates than large banks.',
            'Senior citizens should always request the senior citizen rate before booking.',
            'Submit Form 15G/15H to avoid TDS if your total income is below the taxable limit.',
            'Reinvest maturity amount immediately to avoid losing compounding days.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information',
        blocks: [
          InfoBlock.bullets([
            'Interest from FD is fully taxable — added to income and taxed at your slab rate.',
            'TDS of 10% deducted if annual interest exceeds ₹40,000 (₹50,000 for senior citizens).',
            'Tax-Saving FD (5-year lock-in): deduction up to ₹1.5L under Section 80C.',
            'Tax-Saving FD interest is still taxable — only the principal qualifies for 80C.',
          ]),
        ],
      ),
    ],
  );
}

class _FDDonut extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _FDDonut({required this.fraction, required this.c1, required this.c2});

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
  bool shouldRepaint(_FDDonut old) => old.fraction != fraction;
}
