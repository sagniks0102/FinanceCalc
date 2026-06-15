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

class PPFCalculatorScreen extends StatefulWidget {
  const PPFCalculatorScreen({super.key});

  @override
  State<PPFCalculatorScreen> createState() => _PPFCalculatorScreenState();
}

class _PPFCalculatorScreenState extends State<PPFCalculatorScreen> {
  double _annual = 50000;
  double _rate = 7.1;
  double _years = 15;

  static const Color _accent = Color(0xFF8B5CF6);
  static const Color _accent2 = Color(0xFFA78BFA);

  // PPF compounding formula: each year's deposit compounds for remaining years
  double get _maturity {
    double total = 0;
    for (int y = 1; y <= _years.toInt(); y++) {
      final power = _years.toInt() - y + 1;
      total += _annual * pow15(1 + _rate / 100, power);
    }
    return total;
  }

  double pow15(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) result *= base;
    return result;
  }

  double get _invested => _annual * _years;
  double get _interest => _maturity - _invested;
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
            'PPF Calculator'.tr,
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
      gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
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
        _vDiv(), _stat('Interest Earned'.tr, AppSettings.instance.formatShort(_interest)),
        _vDiv(), _stat('Rate'.tr, '${_rate.toStringAsFixed(1)}%'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(90, 90),
              painter: _PPFDonut(fraction: _interestFraction,
                  c1: Colors.white, c2: const Color(0xFFDDD6FE))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(_interestFraction * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            Text('interest'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
          ]),
        ])),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Amount invested'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFFDDD6FE), 'Interest earned'.tr),
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
        label: 'Annual Investment'.tr,
        value: _annual, min: 500, max: 150000, divisions: 299,
        color: _accent, minLabel: '₹500', maxLabel: '₹1.5L',
        isRupee: true,
        onChanged: (v) => setState(() => _annual = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Interest Rate (p.a.)'.tr,
        value: _rate, min: 6, max: 10, divisions: 40,
        color: _accent2, minLabel: '6%', maxLabel: '10%',
        suffix: '%', isDecimal: true,
        onChanged: (v) => setState(() => _rate = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Tenure'.tr,
        value: _years, min: 15, max: 50, divisions: 35,
        color: const Color(0xFF06B6D4), minLabel: '15 yrs', maxLabel: '50 yrs',
        suffix: ' yrs',
        onChanged: (v) => setState(() => _years = v),
      ),
    ]),
  );

  Widget _breakdown() {
    final rows = [
      ('Yearly deposit'.tr, AppSettings.instance.formatRupee(_annual, noDecimals: true), context.text),
      ('Total investment period'.tr, '${_years.toInt()} years', context.text),
      ('Total invested'.tr, AppSettings.instance.formatRupee(_invested, noDecimals: true), context.text),
      ('Interest earned'.tr, AppSettings.instance.formatRupee(_interest, noDecimals: true), const Color(0xFF7C3AED)),
      ('Maturity amount'.tr, AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF7C3AED)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Yearly Schedule'.tr,
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
    final double monthlyRate = _rate / 12 / 100;
    
    double balance = 0;
    
    // Financial year months
    const monthNames = ['Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'];
    int currentYear = DateTime.now().year;

    final Map<int, List<Map<String, dynamic>>> byYear = {};
    
    for (int y = 0; y < _years.toInt(); y++) {
      double yearInterestAccrued = 0;
      for (int m = 0; m < 12; m++) {
        double dep = (m == 0) ? _annual : 0;
        double minBalanceForMonth = balance + dep; 
        double interestThisMonth = minBalanceForMonth * monthlyRate;
        yearInterestAccrued += interestThisMonth;
        
        double displayBalance = balance + dep;
        if (m == 11) {
          // credit interest at end of year
          displayBalance += yearInterestAccrued;
          balance = displayBalance;
        } else {
          balance += dep;
        }
        
        byYear.putIfAbsent(currentYear + y, () => []).add({
          'monthName': monthNames[m],
          'invested': dep,
          'interest': interestThisMonth,
          'balance': displayBalance,
        });
      }
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
    title: 'About PPF Calculator',
    accentColor: const Color(0xFF8B5CF6),
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is PPF?',
        blocks: [
          InfoBlock.paragraph(
            'The Public Provident Fund (PPF) is a long-term government-backed savings scheme with a 15-year lock-in period. '
            'It offers tax-free returns under the EEE (Exempt-Exempt-Exempt) category — meaning contributions, interest, and maturity are all tax-free.',
          ),
          InfoBlock.paragraph('PPF is managed by the Indian government, making it one of the safest investment instruments available.'),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is PPF maturity calculated?',
        blocks: [
          InfoBlock.formula(
            'Maturity = Σ [A × (1 + r)^y]  for y = 1 to n\n\n'
            'A = Annual deposit\n'
            'r = Annual interest rate (e.g., 7.1% = 0.071)\n'
            'n = Tenure in years (minimum 15)',
          ),
          InfoBlock.tip('Each year\'s deposit earns compounding interest for the remaining years. Depositing early in April maximizes returns.'),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'EEE tax status — completely tax-free returns',
              'Government-backed — zero risk of default',
              'Loan against PPF available from year 3–6',
              'Partial withdrawal allowed after 7th year',
              'Can extend in 5-year blocks after 15 years',
            ],
            cons: [
              '15-year lock-in limits liquidity significantly',
              'Annual investment capped at ₹1.5 lakh',
              'Interest rate set by government, can change',
              'Cannot pledge as security for loans outside PPF rules',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Deposit before April 5 each year to earn interest for the full month of April.',
            'Invest the full ₹1.5L annually to maximize tax benefit under Section 80C.',
            'Open PPF accounts for your spouse and children (minor) for family tax planning.',
            'Continue PPF indefinitely in 5-year blocks after 15 years for tax-free compounding.',
            'Use PPF as the debt/safe portion of your overall investment portfolio.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information (EEE)',
        blocks: [
          InfoBlock.bullets([
            'Contributions: deductible up to ₹1.5L under Section 80C.',
            'Interest earned: completely tax-free every year.',
            'Maturity amount: fully tax-free — no tax at withdrawal.',
            'Partial withdrawals from year 7: also tax-free.',
          ]),
          InfoBlock.tip('PPF is the only instrument with guaranteed, risk-free, EEE tax status. Ideal for building a tax-free retirement corpus.'),
        ],
      ),
    ],
  );
}

class _PPFDonut extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _PPFDonut({required this.fraction, required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 8;
    const sw = 12.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(rect, 0, 6.28, false,
        Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = sw);
    final a1 = (1 - fraction) * 6.28318;
    canvas.drawArc(rect, -1.5708, a1, false,
        Paint()..color = c1..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -1.5708 + a1, fraction * 6.28318, false,
        Paint()..color = c2..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PPFDonut old) => old.fraction != fraction;
}
