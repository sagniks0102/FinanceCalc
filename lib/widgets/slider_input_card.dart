import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class SliderInputCard extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final String minLabel;
  final String maxLabel;
  final String suffix;   // e.g. '%', ' yrs', ' mo', ''
  final bool isRupee;    // shows ₹ prefix in field
  final bool isDecimal;  // allow one decimal place
  final ValueChanged<double> onChanged;

  const SliderInputCard({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.minLabel,
    required this.maxLabel,
    this.suffix = '',
    this.isRupee = false,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  State<SliderInputCard> createState() => _SliderInputCardState();
}

class _SliderInputCardState extends State<SliderInputCard> {
  late TextEditingController _ctrl;
  late FocusNode _focus;
  late double _val;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
    _ctrl = TextEditingController(text: _fmt(_val));
    _focus = FocusNode()
      ..addListener(() {
        if (_focus.hasFocus) {
          setState(() => _editing = true);
          _ctrl.selection =
              TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
        } else {
          _commit(_ctrl.text);
          setState(() => _editing = false);
        }
      });
  }

  @override
  void didUpdateWidget(SliderInputCard old) {
    super.didUpdateWidget(old);
    // Sync only when parent changed value externally (not us)
    if (widget.value != _val && !_editing) {
      _val = widget.value;
      _ctrl.text = _fmt(_val);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      AppSettings.instance.formatNumber(v, noDecimals: !widget.isDecimal);

  void _commit(String text) {
    final raw = double.tryParse(text.replaceAll(',', ''));
    if (raw == null || text.isEmpty) {
      _ctrl.text = _fmt(_val);
      return;
    }
    final clamped = raw.clamp(widget.min, widget.max).toDouble();
    setState(() => _val = clamped);
    _ctrl.text = _fmt(clamped);
    widget.onChanged(clamped);
  }

  void _onTextChanged(String text) {
    final raw = double.tryParse(text.replaceAll(',', ''));
    if (raw == null) return;
    final clamped = raw.clamp(widget.min, widget.max).toDouble();
    setState(() => _val = clamped);
    widget.onChanged(clamped);
  }

  void _onSliderChanged(double v) {
    setState(() {
      _val = v;
      if (!_editing) _ctrl.text = _fmt(v);
    });
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(widget.label,
                  style: TextStyle(
                      fontSize: 12, color: context.textSub)),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.isDecimal, signed: false),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(widget.isDecimal ? r'[\d.,]' : r'[\d,]')),
                  _NumberFormatter(widget.isDecimal),
                ],
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.color),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  prefixText: widget.isRupee ? '₹ ' : null,
                  prefixStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: widget.color),
                  suffixText:
                      widget.suffix.isNotEmpty ? widget.suffix : null,
                  suffixStyle: TextStyle(
                      fontSize: 12, color: context.textSub),
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: context.border)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: context.border)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: widget.color, width: 2)),
                ),
                onChanged: _onTextChanged,
                onSubmitted: _commit,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: widget.color,
            inactiveTrackColor: widget.color.withValues(alpha: 0.15),
            thumbColor: widget.color,
            overlayColor: widget.color.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: _val.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: _onSliderChanged,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.minLabel,
              style:
                  TextStyle(fontSize: 10, color: context.textSub.withValues(alpha: 0.8))),
          Text(widget.maxLabel,
              style:
                  TextStyle(fontSize: 10, color: context.textSub.withValues(alpha: 0.8))),
        ]),
      ]),
    );
  }
}

class _NumberFormatter extends TextInputFormatter {
  final bool isDecimal;
  _NumberFormatter(this.isDecimal);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    String cleanText = newValue.text.replaceAll(',', '');
    if (cleanText.isEmpty) return newValue;
    
    final parts = cleanText.split('.');
    double? intPart = double.tryParse(parts[0].isEmpty ? '0' : parts[0]);
    if (intPart == null) return oldValue;
    
    String finalString = AppSettings.instance.formatNumber(intPart, noDecimals: true);
    
    if (isDecimal && cleanText.contains('.')) {
      if (parts.length > 1) {
        finalString += '.${parts[1]}';
      } else {
        finalString += '.';
      }
    }
    
    int nonCommaCharsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      if (newValue.text[i] != ',') nonCommaCharsBeforeCursor++;
    }
    
    int newCursorOffset = 0;
    int nonCommaCount = 0;
    for (int i = 0; i < finalString.length; i++) {
      if (finalString[i] != ',') nonCommaCount++;
      if (nonCommaCount == nonCommaCharsBeforeCursor) {
        newCursorOffset = i + 1;
        break;
      }
    }
    if (nonCommaCharsBeforeCursor == 0) newCursorOffset = 0;
    
    return TextEditingValue(
      text: finalString,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}
