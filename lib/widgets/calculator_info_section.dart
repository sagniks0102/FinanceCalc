import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ─── Data Models ────────────────────────────────────────────────────────────

enum InfoBlockType { paragraph, bullets, formula, tip, caution, prosCons }

class InfoBlock {
  final InfoBlockType type;
  final String? text;
  final List<String>? items;
  final List<String>? pros;
  final List<String>? cons;

  const InfoBlock.paragraph(String this.text)
      : type = InfoBlockType.paragraph,
        items = null,
        pros = null,
        cons = null;

  const InfoBlock.bullets(List<String> this.items)
      : type = InfoBlockType.bullets,
        text = null,
        pros = null,
        cons = null;

  const InfoBlock.formula(String this.text)
      : type = InfoBlockType.formula,
        items = null,
        pros = null,
        cons = null;

  const InfoBlock.tip(String this.text)
      : type = InfoBlockType.tip,
        items = null,
        pros = null,
        cons = null;

  const InfoBlock.caution(String this.text)
      : type = InfoBlockType.caution,
        items = null,
        pros = null,
        cons = null;

  const InfoBlock.prosCons({
    required List<String> this.pros,
    required List<String> this.cons,
  })  : type = InfoBlockType.prosCons,
        text = null,
        items = null;
}

class InfoItem {
  final IconData icon;
  final String title;
  final List<InfoBlock> blocks;

  const InfoItem({
    required this.icon,
    required this.title,
    required this.blocks,
  });
}

// ─── Main Widget ─────────────────────────────────────────────────────────────

class CalculatorInfoSection extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<InfoItem> items;

  const CalculatorInfoSection({
    super.key,
    required this.title,
    required this.accentColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline_rounded, color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.text,
                ),
              ),
            ]),
          ),
          // Accordion items
          Container(
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.border),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final isLast = i == items.length - 1;
                return _InfoAccordionTile(
                  item: items[i],
                  accentColor: accentColor,
                  isLast: isLast,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual Accordion Tile ────────────────────────────────────────────────

class _InfoAccordionTile extends StatefulWidget {
  final InfoItem item;
  final Color accentColor;
  final bool isLast;

  const _InfoAccordionTile({
    required this.item,
    required this.accentColor,
    required this.isLast,
  });

  @override
  State<_InfoAccordionTile> createState() => _InfoAccordionTileState();
}

class _InfoAccordionTileState extends State<_InfoAccordionTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _heightFactor;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _heightFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: widget.isLast && !_expanded
                  ? null
                  : Border(
                      bottom: BorderSide(color: context.border),
                    ),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.item.icon, color: widget.accentColor, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.text,
                  ),
                ),
              ),
              RotationTransition(
                turns: _rotation,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.accentColor,
                  size: 20,
                ),
              ),
            ]),
          ),
        ),
        // Expandable content
        SizeTransition(
          sizeFactor: _heightFactor,
          child: Container(
            decoration: BoxDecoration(
              color: context.bg,
              border: widget.isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: context.border),
                    ),
              borderRadius: widget.isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    )
                  : null,
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.item.blocks.map((b) => _buildBlock(b)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlock(InfoBlock block) {
    switch (block.type) {
      case InfoBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            block.text!,
            style: TextStyle(
              fontSize: 12.5,
              color: context.textSub,
              height: 1.6,
            ),
          ),
        );

      case InfoBlockType.bullets:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items!.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textSub,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        );

      case InfoBlockType.formula:
        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.accentColor.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.functions_rounded, color: widget.accentColor, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text!,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: widget.accentColor,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      case InfoBlockType.tip:
        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_rounded, color: Color(0xFF059669), size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF047857),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );

      case InfoBlockType.caution:
        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF92400E),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );

      case InfoBlockType.prosCons:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.thumb_up_rounded, size: 12, color: Color(0xFF059669)),
                      SizedBox(width: 5),
                      Text('Advantages',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669))),
                    ]),
                    const SizedBox(height: 6),
                    ...block.pros!.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('✓ ',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w700)),
                        Expanded(
                          child: Text(p,
                              style: TextStyle(
                                  fontSize: 11.5, color: context.textSub, height: 1.4)),
                        ),
                      ]),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.thumb_down_rounded, size: 12, color: Color(0xFFDC2626)),
                      SizedBox(width: 5),
                      Text('Risks',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626))),
                    ]),
                    const SizedBox(height: 6),
                    ...block.cons!.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('✗ ',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w700)),
                        Expanded(
                          child: Text(c,
                              style: TextStyle(
                                  fontSize: 11.5, color: context.textSub, height: 1.4)),
                        ),
                      ]),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
