import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/slider_input_card.dart';
import '../widgets/calculator_info_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});
  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  double _principal = 100000;
  double _rate = 8.0;
  double _years = 5;
  int _compFreq = 4;

  static const Color _accent = Color(0xFFD97706);
  static const Color _accent2 = Color(0xFFF59E0B);

  final _freqLabels = {1: 'Yearly', 2: 'Half-Yearly', 4: 'Quarterly', 12: 'Monthly'};

  double get _maturity {
    final n = _compFreq * _years;
    final r = _rate / 100 / _compFreq;
    return _principal * pow(1 + r, n);
  }
  double get _interest => _maturity - _principal;
  double get _interestFraction => _maturity > 0 ? _interest / _maturity : 0;

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
          title: Text('Compound Interest', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: GestureDetector(onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(child: Column(children: [
            _resultCard(), _sliders(), _freqSelector(), _breakdown(),
            const SizedBox(height: 16), _infoSection(), const SizedBox(height: 24),
          ])),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  Widget _resultCard() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)])),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Future Value', style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: '₹ ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500, height: 1.6)),
          TextSpan(text: AppSettings.instance.formatNumber(_maturity), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          TextSpan(text: '  (${AppSettings.instance.formatShortWord(_maturity)})', style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500, height: 2.4)),
        ]))),
      const SizedBox(height: 16),
      Row(children: [
        _stat('Principal', AppSettings.instance.formatShort(_principal)),
        _vDiv(), _stat('Interest', AppSettings.instance.formatShort(_interest)),
        _vDiv(), _stat('Rate', '${_rate.toStringAsFixed(1)}%'),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(90, 90), painter: _Donut(fraction: _interestFraction, c1: Colors.white, c2: const Color(0xFFFDE68A))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(_interestFraction * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            const Text('interest', style: TextStyle(color: Colors.white60, fontSize: 9)),
          ]),
        ])),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lgd(Colors.white, 'Principal'), const SizedBox(height: 8), _lgd(const Color(0xFFFDE68A), 'Interest earned'),
        ]),
      ]),
    ]),
  );

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10)), const SizedBox(height: 2),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  ]));
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));
  Widget _lgd(Color c, String l) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8), Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Widget _sliders() => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    SliderInputCard(label: 'Principal Amount', value: _principal, min: 1000, max: 10000000, divisions: 199, color: _accent, minLabel: '₹1K', maxLabel: '₹1Cr', isRupee: true, onChanged: (v) => setState(() => _principal = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Interest Rate (per annum)', value: _rate, min: 1, max: 30, divisions: 290, color: _accent2, minLabel: '1%', maxLabel: '30%', suffix: '%', isDecimal: true, onChanged: (v) => setState(() => _rate = v)),
    const SizedBox(height: 12),
    SliderInputCard(label: 'Time Period (Years)', value: _years, min: 1, max: 30, divisions: 29, color: const Color(0xFF6366F1), minLabel: '1 yr', maxLabel: '30 yrs', suffix: ' yrs', onChanged: (v) => setState(() => _years = v)),
  ]));

  Widget _freqSelector() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Compounding Frequency', style: TextStyle(fontSize: 12, color: context.textSub))),
      const SizedBox(height: 12),
      Row(children: _freqLabels.entries.map((e) => Expanded(child: GestureDetector(
        onTap: () => setState(() => _compFreq = e.key),
        child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: _compFreq == e.key ? _accent : context.card, borderRadius: BorderRadius.circular(20)),
          child: Text(e.value, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _compFreq == e.key ? Colors.white : context.textSub)),
        ),
      ))).toList()),
    ]),
  ));

  Widget _breakdown() {
    final rows = [
      ('Principal amount', AppSettings.instance.formatRupee(_principal, noDecimals: true), context.text),
      ('Rate of interest', '${_rate.toStringAsFixed(1)}% p.a.', context.text),
      ('Time period', '${_years.toInt()} years', context.text),
      ('Compounding', _freqLabels[_compFreq]!, context.text),
      ('Interest earned', AppSettings.instance.formatRupee(_interest, noDecimals: true), const Color(0xFFD97706)),
      ('Future value', AppSettings.instance.formatRupee(_maturity, noDecimals: true), const Color(0xFF059669)),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CI Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.text)),
        const SizedBox(height: 10),
        ...rows.map((r) => Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub)),
            Text(r.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: r.$3)),
          ]),
        )),
      ]),
    ));
  }

  Widget _infoSection() => CalculatorInfoSection(title: 'About Compound Interest', accentColor: _accent, items: const [
    InfoItem(icon: Icons.help_outline_rounded, title: 'What is Compound Interest?', blocks: [
      InfoBlock.paragraph('Compound Interest (CI) is calculated on both the initial principal and the accumulated interest from previous periods. It makes your money grow faster than simple interest.'),
    ]),
    InfoItem(icon: Icons.functions_rounded, title: 'Formula', blocks: [
      InfoBlock.formula('A = P × (1 + r/n)^(n×t)\n\nA = Future value\nP = Principal\nr = Annual rate (decimal)\nn = Compounding frequency\nt = Time in years'),
    ]),
    InfoItem(icon: Icons.lightbulb_rounded, title: 'Key Facts', blocks: [
      InfoBlock.bullets(['Higher compounding frequency = more interest', 'Used in FDs, mutual funds, savings accounts', 'The "8th wonder of the world" — Einstein', 'Monthly compounding > Quarterly > Half-yearly > Yearly']),
    ]),
  ]);
}

class _Donut extends CustomPainter {
  final double fraction; final Color c1, c2;
  const _Donut({required this.fraction, required this.c1, required this.c2});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2; final r = size.width / 2 - 8; const sw = 12.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(rect, 0, 2 * pi, false, Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = sw);
    final a1 = (1 - fraction) * 2 * pi;
    canvas.drawArc(rect, -pi / 2, a1, false, Paint()..color = c1..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -pi / 2 + a1, fraction * 2 * pi, false, Paint()..color = c2..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_Donut old) => old.fraction != fraction;
}
