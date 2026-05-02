import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  double _p = 500000;
  double _rate = 8.5;
  double _years = 5;
  bool _amortExpanded = false;

  double get _r => _rate / 12 / 100;
  double get _n => _years * 12;
  double get _emi => _r == 0 ? _p / _n : (_p * _r * pow(1 + _r, _n)) / (pow(1 + _r, _n) - 1);
  double get _totalInterest => (_emi * _n) - _p;
  double get _totalAmount => _emi * _n;
  double get _interestFraction => _totalInterest / _totalAmount;

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
            'EMI Calculator'.tr,
            style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            _resultCard(),
            _inputsSection(),
            _breakdownTable(),
            const SizedBox(height: 12),
            _amortizationTable(),
            // _shareButton(),
            const SizedBox(height: 16),
            _infoSection(),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _resultCard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Monthly EMI'.tr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                  text: AppSettings.instance.formatNumber(_emi),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: '  (${AppSettings.instance.formatShortWord(_emi)})',
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
          _stat('Principal'.tr, AppSettings.instance.formatShort(_p)),
          _vDiv(),
          _stat('Interest'.tr, AppSettings.instance.formatShort(_totalInterest)),
          _vDiv(),
          _stat('Total'.tr, AppSettings.instance.formatShort(_totalAmount)),
        ]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 90, height: 90,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(size: const Size(90, 90),
                  painter: _DonutPainter(fraction: _interestFraction,
                      c1: Colors.white, c2: const Color(0xFFC4B5FD))),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(_interestFraction * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text('interest'.tr, style: const TextStyle(color: Colors.white60, fontSize: 9)),
              ]),
            ]),
          ),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _legend(Colors.white, 'Principal amount'.tr),
            const SizedBox(height: 8),
            _legend(const Color(0xFFC4B5FD), 'Interest charged'.tr),
          ]),
        ]),
      ]),
    );
  }

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));

  Widget _vDiv() => Container(width: 1, height: 32,
      color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _legend(Color c, String l) => Row(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Widget _inputsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SliderInputCard(
          label: 'Loan Amount'.tr,
          value: _p, min: 50000, max: 5000000, divisions: 99,
          color: const Color(0xFF6366F1), minLabel: '₹50K', maxLabel: '₹50L',
          isRupee: true,
          onChanged: (v) => setState(() => _p = v),
        ),
        const SizedBox(height: 12),
        SliderInputCard(
          label: 'Interest Rate (per annum)'.tr,
          value: _rate, min: 5, max: 24, divisions: 38,
          color: const Color(0xFF8B5CF6), minLabel: '5%', maxLabel: '24%',
          suffix: '%', isDecimal: true,
          onChanged: (v) => setState(() => _rate = v),
        ),
        const SizedBox(height: 12),
        SliderInputCard(
          label: 'Loan Tenure'.tr,
          value: _years, min: 1, max: 30, divisions: 29,
          color: const Color(0xFF06B6D4), minLabel: '1 yr', maxLabel: '30 yrs',
          suffix: ' yrs',
          onChanged: (v) => setState(() => _years = v),
        ),
      ]),
    );
  }

  Widget _breakdownTable() {
    final _accent = const Color(0xFF6366F1);
    final rows = [
      ('Loan amount'.tr, AppSettings.instance.formatRupee(_p, noDecimals: true), context.text),
      ('Total interest payable'.tr, AppSettings.instance.formatRupee(_totalInterest, noDecimals: true), _accent),
      ('Total amount to pay'.tr, AppSettings.instance.formatRupee(_totalAmount, noDecimals: true), _accent),
      ('Monthly EMI'.tr, AppSettings.instance.formatRupee(_emi, noDecimals: true), const Color(0xFF059669)),
      ('Total instalments'.tr, '${_n.toInt()} months', context.text),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Loan Breakdown'.tr,
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
    final totalMonths = (_years * 12).toInt();
    final r = _rate / 12 / 100;
    double balance = _p;

    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();

    // Group months by calendar year
    final Map<int, List<Map<String, dynamic>>> byYear = {};
    for (int m = 0; m < totalMonths; m++) {
      final date = DateTime(now.year, now.month + m);
      final interest  = balance * r;
      final principal = _emi - interest;
      balance = (balance - principal).clamp(0, double.infinity);
      byYear.putIfAbsent(date.year, () => []).add({
        'monthName': monthNames[date.month - 1],
        'principal': principal,
        'interest' : interest,
        'emi'      : _emi,
        'balance'  : balance,
      });
    }
    final years = byYear.keys.toList()..sort();

    // Column header with accent colors matching the slider colors
    const Color _colPrincipal = Color(0xFF6366F1); // indigo  — matches Loan Amount slider
    const Color _colInterest  = Color(0xFF8B5CF6); // violet  — matches Interest Rate slider
    const Color _colEmi       = Color(0xFF06B6D4); // cyan    — matches Tenure slider

    Widget colHeader() => Container(
      color: context.border.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(children: [
        SizedBox(width: 44,
            child: Text('Month'.tr, style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w700, color: context.textSub))),
        Expanded(child: Text('Principal'.tr, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _colPrincipal))),
        Expanded(child: Text('Interest'.tr, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _colInterest))),
        Expanded(child: Text('EMI', textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _colEmi))),
        Expanded(child: Text('Balance'.tr, textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.textSub))),
      ]),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(children: [
          // ── Title + toggle ────────────────────────────────────────
          GestureDetector(
            onTap: () { setState(() { _amortExpanded = !_amortExpanded; }); },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Amortization Details (Yearly/Monthly)'.tr,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: context.text),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _amortExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF6366F1), size: 22),
                  ),
                ],
              ),
            ),
          ),
          // ── Year list (shown only when _amortExpanded) ────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Column(
                children: [
                  Divider(height: 1, color: context.border),
                  ...years.asMap().entries.map((entry) {
                    final isLast = entry.key == years.length - 1;
                    final year   = entry.value;
                    return _YearAccordion(
                      year: year,
                      rows: byYear[year]!,
                      isLast: isLast,
                      colHeader: colHeader(),
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _amortExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ]),
      ),
    );
  }

  // Widget _shareButton() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
  //     child: SizedBox(width: double.infinity, height: 52,
  //       child: ElevatedButton.icon(
  //         onPressed: () {},
  //         icon: const Icon(Icons.share_rounded, size: 18),
  //         label: Text('Share Result'.tr,
  //             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white,
  //           elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _infoSection() => CalculatorInfoSection(
    title: 'About EMI Calculator',
    accentColor: const Color(0xFF6366F1),
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is EMI?',
        blocks: [
          InfoBlock.paragraph(
            'EMI (Equated Monthly Instalment) is a fixed payment you make to a lender every month to repay a loan. '
            'Each EMI covers both the interest due for that month and a portion of the principal amount.',
          ),
          InfoBlock.paragraph(
            'EMIs are used for home loans, car loans, personal loans, and more. The amount stays fixed throughout the loan tenure, making budgeting easier.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is EMI calculated?',
        blocks: [
          InfoBlock.formula(
            'EMI = P × r × (1+r)ⁿ / [(1+r)ⁿ − 1]\n\n'
            'P = Principal loan amount\n'
            'r = Monthly interest rate (Annual rate ÷ 12 ÷ 100)\n'
            'n = Loan tenure in months',
          ),
          InfoBlock.tip('In the early months, most of your EMI goes toward interest. Over time, the principal portion grows — this is called amortization.'),
        ],
      ),
      InfoItem(
        icon: Icons.balance_rounded,
        title: 'Advantages & Risks',
        blocks: [
          InfoBlock.prosCons(
            pros: [
              'Predictable fixed monthly outflow for budgeting',
              'Access to large assets (home, car) immediately',
              'Home loan interest is tax-deductible (Section 24)',
              'Builds credit score with timely payments',
            ],
            cons: [
              'You pay significantly more than the loan amount',
              'Missed EMI attracts penalties and hurts credit score',
              'Long tenure means more total interest paid',
              'Foreclosure charges may apply on prepayment',
            ],
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Opt for shorter tenure if you can afford higher EMI — you save significantly on interest.',
            'Make partial prepayments whenever possible to reduce outstanding principal.',
            'Compare effective annual rates (EAR), not just the quoted rate, across lenders.',
            'Avoid taking a loan if EMI exceeds 40% of your monthly take-home salary.',
            'Check for a moratorium period — some loans allow 3–6 months before EMI starts.',
          ]),
          InfoBlock.caution('Taking multiple loans simultaneously increases your Debt-to-Income ratio and can hurt your credit eligibility.'),
        ],
      ),
      InfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Tax Benefits',
        blocks: [
          InfoBlock.bullets([
            'Home loan principal (Section 80C): deduction up to ₹1.5L per year.',
            'Home loan interest (Section 24b): deduction up to ₹2L per year for self-occupied property.',
            'Education loan interest (Section 80E): deduction for up to 8 years.',
            'Personal & car loans: no direct tax benefit on EMI.',
          ]),
        ],
      ),
    ],
  );
}


class _DonutPainter extends CustomPainter {
  final double fraction;
  final Color c1, c2;
  const _DonutPainter({required this.fraction, required this.c1, required this.c2});

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
  bool shouldRepaint(_DonutPainter old) => old.fraction != fraction;
}

// ── Year accordion tile for amortization table ────────────────────────────────
class _YearAccordion extends StatefulWidget {
  final int year;
  final List<Map<String, dynamic>> rows;
  final bool isLast;
  final Widget colHeader;
  final bool forceExpand;

  const _YearAccordion({
    required this.year,
    required this.rows,
    required this.isLast,
    required this.colHeader,
    this.forceExpand = false,
  });

  @override
  State<_YearAccordion> createState() => _YearAccordionState();
}

class _YearAccordionState extends State<_YearAccordion>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _sizeFactor;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 260), vsync: this);
    _sizeFactor =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotation = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_YearAccordion old) {
    super.didUpdateWidget(old);
    if (old.forceExpand != widget.forceExpand) {
      setState(() { _open = widget.forceExpand; });
      widget.forceExpand ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  void _toggle() {
    setState(() { _open = !_open; });
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Same accent palette as the sliders
    const Color _colPrincipal = Color(0xFF6366F1);
    const Color _colInterest  = Color(0xFF8B5CF6);
    const Color _colEmi       = Color(0xFF06B6D4);

    // Compute year totals for the summary row
    final yearPrincipal = widget.rows.fold(0.0, (s, r) => s + (r['principal'] as double));
    final yearInterest  = widget.rows.fold(0.0, (s, r) => s + (r['interest']  as double));
    final yearEmi       = widget.rows.fold(0.0, (s, r) => s + (r['emi']       as double));
    final lastBalance   = widget.rows.last['balance'] as double;

    return Column(children: [
      // ── Year header row ──────────────────────────────────────────
      GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: _open
                ? const Color(0xFF6366F1).withValues(alpha: 0.07)
                : Colors.transparent,
            border: widget.isLast && !_open
                ? null
                : Border(bottom: BorderSide(color: context.border)),
          ),
          child: Row(children: [
            // Year badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.year}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Year totals preview (only when collapsed)
            if (!_open) ...[  
              Expanded(
                child: Text(
                  AppSettings.instance.formatNumber(yearPrincipal),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _colPrincipal.withValues(alpha: 0.85)),
                ),
              ),
              Expanded(
                child: Text(
                  AppSettings.instance.formatNumber(yearInterest),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _colInterest.withValues(alpha: 0.85)),
                ),
              ),
              Expanded(
                child: Text(
                  AppSettings.instance.formatNumber(yearEmi),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _colEmi.withValues(alpha: 0.85)),
                ),
              ),
              Expanded(
                child: Text(
                  lastBalance < 1 ? '₹0' : AppSettings.instance.formatNumber(lastBalance),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: context.textSub),
                ),
              ),
            ] else
              const Spacer(),
            RotationTransition(
              turns: _rotation,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6366F1), size: 20),
            ),
          ]),
        ),
      ),
      // ── Expandable monthly table ─────────────────────────────────
      SizeTransition(
        sizeFactor: _sizeFactor,
        child: Container(
          decoration: BoxDecoration(
            color: context.card,
            border: widget.isLast
                ? null
                : Border(bottom: BorderSide(color: context.border)),
          ),
          child: Column(children: [
            widget.colHeader,
            ...widget.rows.asMap().entries.map((entry) {
              final row   = entry.value;
              final isAlt = entry.key % 2 == 1;
              return Container(
                color: isAlt
                    ? const Color(0xFF6366F1).withValues(alpha: 0.03)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(children: [
                  SizedBox(
                    width: 44,
                    child: Text(row['monthName'] as String,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.textSub)),
                  ),
                  Expanded(
                    child: Text(
                        AppSettings.instance.formatNumber(row['principal'] as double),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _colPrincipal)),
                  ),
                  Expanded(
                    child: Text(
                        AppSettings.instance.formatNumber(row['interest'] as double),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _colInterest)),
                  ),
                  Expanded(
                    child: Text(
                        AppSettings.instance.formatNumber(row['emi'] as double),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _colEmi)),
                  ),
                  Expanded(
                    child: Text(
                        (row['balance'] as double) < 1
                            ? '₹0'
                            : AppSettings.instance.formatNumber(row['balance'] as double),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.text)),
                  ),
                ]),
              );
            }),
          ]),
        ),
      ),
    ]);
  }
}

