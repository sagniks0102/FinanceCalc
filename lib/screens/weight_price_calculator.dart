import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class WeightPriceCalculatorScreen extends StatefulWidget {
  const WeightPriceCalculatorScreen({super.key});

  @override
  State<WeightPriceCalculatorScreen> createState() =>
      _WeightPriceCalculatorScreenState();
}

class _WeightPriceCalculatorScreenState
    extends State<WeightPriceCalculatorScreen> {
  // ── Given Rate ─────────────────────────────────────────────────────
  final _givenWeightCtrl = TextEditingController(text: '1');
  final _givenPriceCtrl  = TextEditingController(text: '50');
  String _givenUnit = 'kg';

  // ── Target ─────────────────────────────────────────────────────────
  final _calcWeightCtrl = TextEditingController(text: '3.5');
  final _calcPriceCtrl  = TextEditingController();
  String _calcUnit = 'kg';

  // ── Focus nodes (select-all on tap) ───────────────────────────────
  late final FocusNode _givenWeightFocus;
  late final FocusNode _givenPriceFocus;
  late final FocusNode _calcWeightFocus;
  late final FocusNode _calcPriceFocus;

  bool _isUpdating = false;

  static const Color _accent = Color(0xFFEAB308);

  FocusNode _selectAllFocus(TextEditingController ctrl) {
    final node = FocusNode();
    node.addListener(() {
      if (node.hasFocus) {
        ctrl.selection = TextSelection(
            baseOffset: 0, extentOffset: ctrl.text.length);
      }
    });
    return node;
  }

  @override
  void initState() {
    super.initState();
    _givenWeightFocus = _selectAllFocus(_givenWeightCtrl);
    _givenPriceFocus  = _selectAllFocus(_givenPriceCtrl);
    _calcWeightFocus  = _selectAllFocus(_calcWeightCtrl);
    _calcPriceFocus   = _selectAllFocus(_calcPriceCtrl);
    _calcPrice();
  }

  @override
  void dispose() {
    _givenWeightCtrl.dispose();
    _givenPriceCtrl.dispose();
    _calcWeightCtrl.dispose();
    _calcPriceCtrl.dispose();
    _givenWeightFocus.dispose();
    _givenPriceFocus.dispose();
    _calcWeightFocus.dispose();
    _calcPriceFocus.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────
  double get _givenWeightKg {
    final w = double.tryParse(_givenWeightCtrl.text) ?? 0;
    return _givenUnit == 'kg' ? w : w / 1000;
  }

  double get _givenPrice => double.tryParse(_givenPriceCtrl.text) ?? 0;

  double get _pricePerKg {
    final w = _givenWeightKg;
    return w == 0 ? 0 : _givenPrice / w;
  }

  void _calcPrice() {
    if (_isUpdating) return;
    _isUpdating = true;
    final tW   = double.tryParse(_calcWeightCtrl.text) ?? 0;
    final tWkg = _calcUnit == 'kg' ? tW : tW / 1000;
    final tp   = tWkg * _pricePerKg;
    _calcPriceCtrl.text = (tp <= 0 || tp.isNaN || tp.isInfinite)
        ? ''
        : tp.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    _isUpdating = false;
    setState(() {});
  }

  void _calcWeight() {
    if (_isUpdating) return;
    _isUpdating = true;
    final ppkg = _pricePerKg;
    final tp   = double.tryParse(_calcPriceCtrl.text) ?? 0;
    if (ppkg == 0) {
      _calcWeightCtrl.text = '';
    } else {
      final wkg = tp / ppkg;
      final w   = _calcUnit == 'kg' ? wkg : wkg * 1000;
      String s  = w.toStringAsFixed(3);
      s = s.replaceAll(RegExp(r'0+$'), '');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
      _calcWeightCtrl.text = s;
    }
    _isUpdating = false;
    setState(() {});
  }

  // ── Build ──────────────────────────────────────────────────────────
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
            'Weight & Price Calculator'.tr,
            style: TextStyle(
                color: context.text,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(children: [
              _resultCard(),
              const SizedBox(height: 16),
              _givenCard(),
              const SizedBox(height: 12),
              _targetCard(),
            ]),
          ),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }

  // ── Result Card ────────────────────────────────────────────────────
  Widget _resultCard() {
    final calcPrice = double.tryParse(_calcPriceCtrl.text) ?? 0;
    final hasResult = calcPrice > 0 && !calcPrice.isNaN && !calcPrice.isInfinite;
    final ppkg = _pricePerKg;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCA8A04), Color(0xFFEAB308)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Calculated Price'.tr,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: hasResult
                  ? AppSettings.instance.formatNumber(calcPrice)
                  : '0',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          _statBox(
            'Unit Price'.tr,
            ppkg == 0 || ppkg.isNaN || ppkg.isInfinite
                ? '₹ 0 / kg'
                : '₹ ${AppSettings.instance.formatNumber(ppkg)} / kg',
            const Color(0xFFFEF08A),
          ),
          const SizedBox(width: 12),
          _statBox(
            'Target Weight'.tr,
            _calcWeightCtrl.text.isEmpty ? '—' : '${_calcWeightCtrl.text} $_calcUnit',
            const Color(0xFFFEF08A),
          ),
          const SizedBox(width: 12),
          _statBox(
            'Given Price'.tr,
            '₹ ${_givenPriceCtrl.text.isEmpty ? '0' : _givenPriceCtrl.text}',
            const Color(0xFFFEF08A),
          ),
        ]),
      ]),
    );
  }

  Widget _statBox(String label, String value, Color valueColor) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  // ── Given Rate Card ────────────────────────────────────────────────
  Widget _givenCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: _accent),
          const SizedBox(width: 6),
          Text('Given Rate'.tr,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.text)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _inputField(
              label: 'Weight'.tr,
              controller: _givenWeightCtrl,
              focusNode: _givenWeightFocus,
              onChanged: (_) => _calcPrice(),
              unit: _givenUnit,
              onUnitChanged: (v) {
                setState(() => _givenUnit = v!);
                _calcPrice();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _inputField(
              label: 'Price'.tr,
              controller: _givenPriceCtrl,
              focusNode: _givenPriceFocus,
              onChanged: (_) => _calcPrice(),
              prefix: '₹',
            ),
          ),
        ]),
      ]),
    ),
  );

  // ── Calculated Result Card ─────────────────────────────────────────
  Widget _targetCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.calculate_rounded, size: 14, color: _accent),
          const SizedBox(width: 6),
          Text('Calculated Result'.tr,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.text)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _inputField(
              label: 'Weight'.tr,
              controller: _calcWeightCtrl,
              focusNode: _calcWeightFocus,
              onChanged: (_) => _calcPrice(),
              unit: _calcUnit,
              onUnitChanged: (v) {
                setState(() => _calcUnit = v!);
                _calcPrice();
              },
              accentColor: _accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _inputField(
              label: 'Price'.tr,
              controller: _calcPriceCtrl,
              focusNode: _calcPriceFocus,
              onChanged: (_) => _calcWeight(),
              prefix: '₹',
              accentColor: _accent,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
          'Enter Weight or Price — the other auto-fills.'.tr,
          style: TextStyle(color: context.textSub, fontSize: 10),
        ),
      ]),
    ),
  );

  // ── Single Input Field with label + bordered box ───────────────────
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    String? prefix,
    String? unit,
    ValueChanged<String?>? onUnitChanged,
    Color? accentColor,
  }) {
    final color = accentColor ?? context.text;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: context.textSub)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor != null
                ? _accent.withValues(alpha: 0.45)
                : context.border,
          ),
        ),
        child: Row(children: [
          // ₹ prefix badge
          if (prefix != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: context.border)),
              ),
              child: Text(prefix,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ),
          // text input
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 12),
                hintText: '0',
                hintStyle: TextStyle(color: context.textSub),
              ),
              onChanged: onChanged,
            ),
          ),
          // kg / g dropdown
          if (unit != null && onUnitChanged != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: unit,
                  isDense: true,
                  dropdownColor: context.card,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: context.textSub),
                  items: ['kg', 'g']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.text)),
                          ))
                      .toList(),
                  onChanged: onUnitChanged,
                ),
              ),
            ),
        ]),
      ),
    ]);
  }
}
