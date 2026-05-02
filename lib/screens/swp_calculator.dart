import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/breakdown_table.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class SWPCalculatorScreen extends StatefulWidget {
  const SWPCalculatorScreen({super.key});

  @override
  State<SWPCalculatorScreen> createState() => _SWPCalculatorScreenState();
}

class _SWPCalculatorScreenState extends State<SWPCalculatorScreen> {
  double _corpus = 1000000;   // Initial investment / corpus
  double _withdrawal = 10000; // Monthly withdrawal amount
  double _rate = 8;            // Expected annual return rate (%)
  double _years = 10;          // Withdrawal period in years

  static const Color _accent = Color(0xFFEF4444);
  static const Color _accent2 = Color(0xFFF87171);

  // Total amount withdrawn over the period
  double get _totalWithdrawn => _withdrawal * _years * 12;

  // Final corpus remaining after all withdrawals
  // Using the Present Value of Annuity formula in reverse:
  // FV = PV*(1+r)^n - W*[((1+r)^n - 1)/r]*(1+r)
  // where r = monthly rate, n = total months, W = monthly withdrawal
  double get _finalCorpus {
    final r = _rate / 12 / 100;
    final n = (_years * 12).toInt();
    if (r == 0) return _corpus - _totalWithdrawn;
    final fv = _corpus * pow(1 + r, n) -
        _withdrawal * ((pow(1 + r, n) - 1) / r) * (1 + r);
    return fv < 0 ? 0 : fv;
  }

  // Total earnings from returns over the period
  double get _totalEarnings {
    final finalC = _finalCorpus;
    // earnings = final corpus + total withdrawn - initial corpus
    return (finalC + _totalWithdrawn - _corpus).clamp(0, double.infinity);
  }

  // How many months before corpus is exhausted (if applicable)
  int get _exhaustMonths {
    final r = _rate / 12 / 100;
    if (r == 0) {
      return (_corpus / _withdrawal).floor();
    }
    // Solve: PV*(1+r)^n = W*((1+r)^n - 1)/r*(1+r)
    // => n = log(W*(1+r) / (W*(1+r) - PV*r)) / log(1+r)
    final num = _withdrawal * (1 + r);
    final denom = _withdrawal * (1 + r) - _corpus * r;
    if (denom <= 0) return -1; // corpus never exhausted
    return (log(num / denom) / log(1 + r)).ceil();
  }

  bool get _corpusExhausted => _finalCorpus == 0;

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
            'SWP Calculator'.tr,
            style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            _resultCard(),
            _sliders(),
            if (_corpusExhausted) _exhaustionWarning(),
            _breakdown(),
            const SizedBox(height: 12),
            _amortizationTable(),
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
        colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Final Corpus Value'.tr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                text: _corpusExhausted ? '0' : AppSettings.instance.formatNumber(_finalCorpus),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (!_corpusExhausted)
                TextSpan(
                  text: '  (${AppSettings.instance.formatShortWord(_finalCorpus)})',
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
        _stat('Initial Corpus'.tr, AppSettings.instance.formatShort(_corpus)),
        _vDiv(),
        _stat('Total Withdrawn'.tr, AppSettings.instance.formatShort(_totalWithdrawn)),
        _vDiv(),
        _stat('Total Earnings'.tr, AppSettings.instance.formatShort(_totalEarnings)),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: const Size(90, 90),
              painter: _SWPDonut(
                withdrawnFraction: (_totalWithdrawn / (_corpus + _totalEarnings)).clamp(0, 1),
                remainingFraction: (_finalCorpus / (_corpus + _totalEarnings)).clamp(0, 1),
                c1: Colors.white,
                c2: const Color(0xFFFCA5A5),
                c3: const Color(0xFF4ADE80),
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                '${_years.toInt()}yr',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text('plan'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
            ]),
          ]),
        ),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Total withdrawn'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFFFCA5A5), 'Returns earned'.tr),
          const SizedBox(height: 8),
          _lgd(const Color(0xFF4ADE80), 'Remaining corpus'.tr),
        ]),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));

  Widget _vDiv() => Container(
    width: 1, height: 32,
    color: Colors.white.withOpacity(0.2),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );

  Widget _lgd(Color c, String l) => Row(children: [
    Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Widget _sliders() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      SliderInputCard(
        label: 'Total Investment (Corpus)'.tr,
        value: _corpus, min: 100000, max: 50000000, divisions: 499,
        color: _accent, minLabel: '₹1L', maxLabel: '₹5Cr',
        isRupee: true,
        onChanged: (v) => setState(() => _corpus = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Monthly Withdrawal'.tr,
        value: _withdrawal, min: 1000, max: 500000, divisions: 499,
        color: _accent2, minLabel: '₹1K', maxLabel: '₹5L',
        isRupee: true,
        onChanged: (v) => setState(() => _withdrawal = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Expected Return Rate (p.a.)'.tr,
        value: _rate, min: 1, max: 20, divisions: 38,
        color: const Color(0xFFF59E0B), minLabel: '1%', maxLabel: '20%',
        suffix: '%', isDecimal: true,
        onChanged: (v) => setState(() => _rate = v),
      ),
      const SizedBox(height: 12),
      SliderInputCard(
        label: 'Withdrawal Period'.tr,
        value: _years, min: 1, max: 30, divisions: 29,
        color: const Color(0xFF06B6D4), minLabel: '1 yr', maxLabel: '30 yrs',
        suffix: ' yrs',
        onChanged: (v) => setState(() => _years = v),
      ),
    ]),
  );

  Widget _exhaustionWarning() {
    final months = _exhaustMonths;
    final yrs = months ~/ 12;
    final mo = months % 12;
    final durationStr = yrs > 0
        ? (mo > 0 ? '$yrs yr $mo mo' : '$yrs yr')
        : '$mo mo';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEF4444)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                children: [
                  const TextSpan(text: 'Corpus will be exhausted in '),
                  TextSpan(
                    text: durationStr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: '. Reduce withdrawal or increase corpus.'),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _breakdown() {
    final monthlyReturn = _corpus * (_rate / 12 / 100);
    final sustainableWithdrawal = monthlyReturn;
    final rows = [
      ('Initial corpus'.tr, AppSettings.instance.formatRupee(_corpus, noDecimals: true), context.text),
      ('Monthly withdrawal'.tr, AppSettings.instance.formatRupee(_withdrawal, noDecimals: true), context.text),
      ('Expected return rate'.tr, '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Withdrawal period'.tr, '${_years.toInt()} years', context.text),
      ('Total amount withdrawn'.tr, AppSettings.instance.formatRupee(_totalWithdrawn, noDecimals: true), const Color(0xFFDC2626)),
      ('Total returns earned'.tr, AppSettings.instance.formatRupee(_totalEarnings, noDecimals: true), const Color(0xFF059669)),
      ('Final corpus remaining'.tr, AppSettings.instance.formatRupee(_finalCorpus, noDecimals: true), _corpusExhausted ? const Color(0xFFDC2626) : const Color(0xFF059669)),
      ('Sustainable monthly SWP'.tr, AppSettings.instance.formatRupee(sustainableWithdrawal, noDecimals: true), const Color(0xFF0D9488)),
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
          Text('SWP Breakdown'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.border),
            ),
            child: Row(children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 13, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sustainable withdrawal keeps corpus intact indefinitely.',
                  style: TextStyle(fontSize: 10, color: context.textSub),
                ),
              ),
            ]),
          ),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.border)),
            ),
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
    
    double balance = _corpus;
    
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();

    final Map<int, List<Map<String, dynamic>>> byYear = {};
    for (int i = 0; i < totalMonths; i++) {
      if (balance <= 0) break;
      final date = DateTime(now.year, now.month + i - 1 + 1);
      
      double w = _withdrawal;
      if (balance < w) {
        w = balance;
      }
      
      final interest = (balance - w) * r;
      balance = balance - w + interest;
      if (balance < 0) balance = 0;
      
      byYear.putIfAbsent(date.year, () => []).add({
        'monthName': monthNames[date.month - 1],
        'withdrawal': w,
        'interest': interest,
        'balance': balance,
      });
    }

    return BreakdownTable(
      title: 'Withdrawal Details (Yearly/Monthly)',
      accentColor: _accent,
      columns: [
        BreakdownColumn(title: 'Month', color: context.textSub, key: 'monthName', align: TextAlign.left, width: 44),
        BreakdownColumn(title: 'Withdrawn', color: _accent, key: 'withdrawal'),
        BreakdownColumn(title: 'Returns', color: const Color(0xFF059669), key: 'interest'),
        BreakdownColumn(title: 'Balance', color: context.textSub, key: 'balance', align: TextAlign.right),
      ],
      byYear: byYear,
    );
  }

  Widget _infoSection() => CalculatorInfoSection(
    title: 'About SWP Calculator',
    accentColor: _accent,
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is SWP?',
        blocks: [
          InfoBlock.paragraph(
            'A Systematic Withdrawal Plan (SWP) lets you withdraw a fixed amount from your mutual fund at regular intervals. '
            'Unlike SIP where you invest periodically, SWP generates a steady "income" from your invested corpus while the remaining amount continues to earn market returns.',
          ),
          InfoBlock.paragraph(
            'SWP is widely used by retirees, senior citizens, and anyone seeking a regular cash flow from their existing investments without liquidating the entire corpus at once.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is it calculated?',
        blocks: [
          InfoBlock.paragraph('The future value of your corpus after n months of withdrawals:'),
          InfoBlock.formula(
            'FV = PV × (1+r)ⁿ  −  W × [((1+r)ⁿ − 1) / r] × (1+r)\n\n'
            'PV = Initial corpus\n'
            'r  = Monthly return rate (Annual rate ÷ 12 ÷ 100)\n'
            'n  = Total months (Years × 12)\n'
            'W  = Monthly withdrawal amount',
          ),
          InfoBlock.tip(
            'If monthly withdrawal ≤ monthly returns earned, the corpus stays intact (or even grows) indefinitely. '
            'The "Sustainable monthly SWP" shown in the breakdown is exactly this threshold.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'Regular income without selling entire investment',
              'Remaining corpus continues to earn returns',
              'Flexible — change or stop withdrawal anytime',
              'Tax-efficient: only capital gains taxed, not principal',
              'Better than FD interest for long-term inflation-beating',
            ],
            cons: [
              'Corpus depletes if withdrawal exceeds returns',
              'Market downturns can reduce actual returns',
              'Not suitable for short-term or emergency needs',
              'Returns not guaranteed (depends on market)',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Keep monthly withdrawal below your monthly return to make the corpus last forever.',
            'Use equity funds for long-term SWP (10+ years) — they beat inflation.',
            'Use debt or hybrid funds for short-term SWP (1–5 years) — more stable returns.',
            'Review and adjust your withdrawal amount annually to account for inflation.',
            'Start SWP from profits first; avoid touching principal as long as possible.',
            'Combine SIP (accumulation) and SWP (distribution) for a complete financial plan.',
          ]),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Information',
        blocks: [
          InfoBlock.paragraph(
            'Each SWP redemption is treated as a partial sale of units. Only the capital gain portion is taxable — the principal portion is tax-free.',
          ),
          InfoBlock.bullets([
            'Equity funds held > 1 year: 12.5% Long-Term Capital Gains (LTCG) on gains above ₹1.25L per year.',
            'Equity funds held < 1 year: 20% Short-Term Capital Gains (STCG).',
            'Debt funds (post Apr 2023): gains taxed as per your income slab, regardless of holding period.',
          ]),
          InfoBlock.caution(
            'Consult a financial advisor or tax professional for personalized tax planning, especially for large SWP amounts.',
          ),
        ],
      ),
    ],
  );
}

// Custom donut painter for SWP (3-segment: withdrawn, earned returns, remaining)
class _SWPDonut extends CustomPainter {
  final double withdrawnFraction;
  final double remainingFraction;
  final Color c1, c2, c3;

  const _SWPDonut({
    required this.withdrawnFraction,
    required this.remainingFraction,
    required this.c1,
    required this.c2,
    required this.c3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 8;
    const sw = 12.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background track
    canvas.drawArc(rect, 0, 2 * pi, false,
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);

    final earnedFraction = (1 - withdrawnFraction - remainingFraction).clamp(0.0, 1.0);

    double startAngle = -pi / 2;

    // Withdrawn (white)
    final a1 = withdrawnFraction * 2 * pi;
    if (a1 > 0) {
      canvas.drawArc(rect, startAngle, a1, false,
          Paint()
            ..color = c1
            ..style = PaintingStyle.stroke
            ..strokeWidth = sw
            ..strokeCap = StrokeCap.round);
    }
    startAngle += a1;

    // Returns earned (light red)
    final a2 = earnedFraction * 2 * pi;
    if (a2 > 0) {
      canvas.drawArc(rect, startAngle, a2, false,
          Paint()
            ..color = c2
            ..style = PaintingStyle.stroke
            ..strokeWidth = sw
            ..strokeCap = StrokeCap.round);
    }
    startAngle += a2;

    // Remaining corpus (green)
    final a3 = remainingFraction * 2 * pi;
    if (a3 > 0) {
      canvas.drawArc(rect, startAngle, a3, false,
          Paint()
            ..color = c3
            ..style = PaintingStyle.stroke
            ..strokeWidth = sw
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_SWPDonut old) =>
      old.withdrawnFraction != withdrawnFraction ||
      old.remainingFraction != remainingFraction;
}
