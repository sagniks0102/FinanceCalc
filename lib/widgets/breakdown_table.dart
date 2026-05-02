import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class BreakdownColumn {
  final String title;
  final Color color;
  final String key;
  final TextAlign align;
  final int flex;
  final double? width;

  const BreakdownColumn({
    required this.title,
    required this.color,
    required this.key,
    this.align = TextAlign.center,
    this.flex = 1,
    this.width,
  });
}

class BreakdownTable extends StatefulWidget {
  final String title;
  final List<BreakdownColumn> columns;
  final Map<int, List<Map<String, dynamic>>> byYear;
  final Color accentColor;

  const BreakdownTable({
    super.key,
    required this.title,
    required this.columns,
    required this.byYear,
    this.accentColor = const Color(0xFF6366F1),
  });

  @override
  State<BreakdownTable> createState() => _BreakdownTableState();
}

class _BreakdownTableState extends State<BreakdownTable> {
  bool _expanded = false;

  Widget _colHeader() => Container(
    color: context.border.withValues(alpha: 0.5),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    child: Row(
      children: widget.columns.map((c) {
        Widget text = Text(c.title.tr,
            textAlign: c.align,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.color));
        if (c.width != null) {
          return SizedBox(width: c.width, child: text);
        }
        return Expanded(flex: c.flex, child: text);
      }).toList(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.byYear.isEmpty) return const SizedBox();
    final years = widget.byYear.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title.tr,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: context.text),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: widget.accentColor, size: 22),
                  ),
                ],
              ),
            ),
          ),
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
                    return _YearlyBreakdownAccordion(
                      year: year,
                      rows: widget.byYear[year]!,
                      isLast: isLast,
                      colHeader: _colHeader(),
                      columns: widget.columns,
                      accentColor: widget.accentColor,
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ]),
      ),
    );
  }
}

class _YearlyBreakdownAccordion extends StatefulWidget {
  final int year;
  final List<Map<String, dynamic>> rows;
  final bool isLast;
  final Widget colHeader;
  final List<BreakdownColumn> columns;
  final Color accentColor;

  const _YearlyBreakdownAccordion({
    required this.year,
    required this.rows,
    required this.isLast,
    required this.colHeader,
    required this.columns,
    required this.accentColor,
  });

  @override
  State<_YearlyBreakdownAccordion> createState() => _YearlyBreakdownAccordionState();
}

class _YearlyBreakdownAccordionState extends State<_YearlyBreakdownAccordion>
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
    _sizeFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotation = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() { _open = !_open; });
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // We compute totals for numeric columns except 'monthName' and 'balance' (which we take the last value of).
    // Actually, balance shouldn't be summed. We can just use the last value for the last column.
    return Column(children: [
      GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: _open
                ? widget.accentColor.withValues(alpha: 0.07)
                : Colors.transparent,
            border: widget.isLast && !_open
                ? null
                : Border(bottom: BorderSide(color: context.border)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.year}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (!_open)
              Expanded(
                child: Row(
                  children: widget.columns.skip(1).map((c) {
                    final isBalance = c == widget.columns.last;
                    String textVal = '';
                    if (isBalance) {
                      double lastVal = widget.rows.last[c.key] as double;
                      textVal = lastVal < 1 ? '₹0' : AppSettings.instance.formatNumber(lastVal);
                    } else {
                      double sum = widget.rows.fold(0.0, (s, r) => s + (r[c.key] as double));
                      textVal = sum < 1 ? '₹0' : AppSettings.instance.formatNumber(sum);
                    }
                    
                    Widget text = Text(
                      textVal,
                      textAlign: c.align,
                      style: TextStyle(
                        fontSize: 11, 
                        color: isBalance ? context.textSub : c.color.withValues(alpha: 0.85),
                        fontWeight: isBalance ? FontWeight.w600 : FontWeight.normal
                      ),
                    );
                    if (c.width != null) {
                      return SizedBox(width: c.width, child: text);
                    }
                    return Expanded(flex: c.flex, child: text);
                  }).toList(),
                ),
              )
            else
              const Spacer(),
            RotationTransition(
              turns: _rotation,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: widget.accentColor, size: 20),
            ),
          ]),
        ),
      ),
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
                    ? widget.accentColor.withValues(alpha: 0.03)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: widget.columns.map((c) {
                    final isFirst = c == widget.columns.first;
                    final isBalance = c == widget.columns.last;
                    String textVal = '';
                    if (isFirst) {
                      textVal = row[c.key] as String;
                    } else {
                      double val = row[c.key] as double;
                      textVal = val < 1 ? '₹0' : AppSettings.instance.formatNumber(val);
                    }
                    
                    Widget text = Text(
                      textVal,
                      textAlign: c.align,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isFirst || isBalance ? FontWeight.w600 : FontWeight.w500,
                        color: isFirst || isBalance ? context.text : c.color,
                      ),
                    );
                    if (c.width != null) {
                      return SizedBox(width: c.width, child: text);
                    }
                    return Expanded(flex: c.flex, child: text);
                  }).toList(),
                ),
              );
            }),
          ]),
        ),
      ),
    ]);
  }
}
