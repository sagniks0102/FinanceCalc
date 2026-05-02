import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/calculator_info_section.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/app_settings.dart';

class GSTCalculatorScreen extends StatefulWidget {
  const GSTCalculatorScreen({super.key});

  @override
  State<GSTCalculatorScreen> createState() => _GSTCalculatorScreenState();
}

class _GSTCalculatorScreenState extends State<GSTCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController(text: '10000');
  double _amount    = 10000;
  double _gstRate   = 18;
  bool   _addMode   = true; // true = Add GST, false = Remove GST

  late final TabController _tabCtrl;

  static const Color _accent  = Color(0xFF16A34A);
  static const Color _accent2 = Color(0xFF22C55E);
  static const List<double> _gstSlabs = [0, 5, 12, 18, 28];

  // ── Calculations ──────────────────────────────────────────────────
  double get _gstAmount {
    if (_addMode) {
      return _amount * _gstRate / 100;
    } else {
      return _amount - (_amount * 100 / (100 + _gstRate));
    }
  }

  double get _preGstAmount => _addMode ? _amount : _amount - _gstAmount;
  double get _totalAmount   => _addMode ? _amount + _gstAmount : _amount;
  double get _cgst          => _gstAmount / 2;
  double get _sgst          => _gstAmount / 2;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      setState(() => _addMode = _tabCtrl.index == 0);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

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
            'GST Calculator'.tr,
            style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            _resultCard(),
            _inputCard(),
            _rateSelector(),
            _breakdownCard(),
            const SizedBox(height: 16),
            _infoSection(),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  // ── Result Card ────────────────────────────────────────────────────
  Widget _resultCard() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF15803D), Color(0xFF16A34A)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        _addMode ? 'Total Amount (incl. GST)'.tr : 'Original Amount (excl. GST)'.tr,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            text: AppSettings.instance.formatNumber(_addMode ? _totalAmount : _preGstAmount),
            style: const TextStyle(
              color: Colors.white, fontSize: 36,
              fontWeight: FontWeight.w700, letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      // Three stat boxes
      Row(children: [
        _statBox('GST Amount'.tr, AppSettings.instance.formatRupee(_gstAmount, noDecimals: true), const Color(0xFFBBF7D0)),
        const SizedBox(width: 12),
        _statBox('CGST (${(_gstRate / 2).toStringAsFixed(1)}%)',
            AppSettings.instance.formatRupee(_cgst, noDecimals: true), const Color(0xFFBBF7D0)),
        const SizedBox(width: 12),
        _statBox('SGST (${(_gstRate / 2).toStringAsFixed(1)}%)',
            AppSettings.instance.formatRupee(_sgst, noDecimals: true), const Color(0xFFBBF7D0)),
      ]),
    ]),
  );

  Widget _statBox(String label, String value, Color valueColor) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(color: valueColor, fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  // ── Amount Input Card ──────────────────────────────────────────────
  Widget _inputCard() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Add / Remove toggle tabs
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: context.textSub,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Add GST'.tr),
              Tab(text: 'Remove GST'.tr),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _addMode
              ? 'Enter amount (excluding GST)'.tr
              : 'Enter amount (including GST)'.tr,
          style: TextStyle(fontSize: 12, color: context.textSub),
        ),
        const SizedBox(height: 8),
        // Amount text field
        Container(
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.border),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: context.border)),
              ),
              child: const Text('₹',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A))),
            ),
            Expanded(
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                    color: context.text),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: context.textSub),
                ),
                onChanged: (val) {
                  setState(() {
                    _amount = double.tryParse(val) ?? 0;
                  });
                },
              ),
            ),
          ]),
        ),
      ]),
    ),
  );

  // ── GST Rate Selector ──────────────────────────────────────────────
  Widget _rateSelector() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('GST Rate'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: context.text)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_gstRate.toStringAsFixed(0)}% GST',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _gstSlabs.map((rate) {
            final selected = rate == _gstRate;
            return GestureDetector(
              onTap: () => setState(() => _gstRate = rate),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _accent : context.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _accent : context.border,
                  ),
                ),
                child: Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : context.textSub,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    ),
  );

  // ── Breakdown Card ─────────────────────────────────────────────────
  Widget _breakdownCard() {
    final rows = _addMode
        ? [
            ('Original Amount (excl. GST)'.tr, AppSettings.instance.formatRupee(_amount, noDecimals: true),         context.text),
            ('GST Rate'.tr,                    '${_gstRate.toStringAsFixed(0)}%', context.text),
            ('CGST (${(_gstRate/2).toStringAsFixed(1)}%)',  AppSettings.instance.formatRupee(_cgst, noDecimals: true),        const Color(0xFF0284C7)),
            ('SGST (${(_gstRate/2).toStringAsFixed(1)}%)',  AppSettings.instance.formatRupee(_sgst, noDecimals: true),        const Color(0xFF0284C7)),
            ('Total GST Amount'.tr,            AppSettings.instance.formatRupee(_gstAmount, noDecimals: true),       const Color(0xFF16A34A)),
            ('Total Amount (incl. GST)'.tr,    AppSettings.instance.formatRupee(_totalAmount, noDecimals: true),     const Color(0xFF16A34A)),
          ]
        : [
            ('Amount Entered (incl. GST)'.tr, AppSettings.instance.formatRupee(_amount, noDecimals: true),         context.text),
            ('GST Rate'.tr,                   '${_gstRate.toStringAsFixed(0)}%', context.text),
            ('GST Amount (removed)'.tr,        AppSettings.instance.formatRupee(_gstAmount, noDecimals: true),      const Color(0xFFDC2626)),
            ('CGST (${(_gstRate/2).toStringAsFixed(1)}%)', AppSettings.instance.formatRupee(_cgst, noDecimals: true),        const Color(0xFF0284C7)),
            ('SGST (${(_gstRate/2).toStringAsFixed(1)}%)', AppSettings.instance.formatRupee(_sgst, noDecimals: true),        const Color(0xFF0284C7)),
            ('Pre-GST Amount (excl. GST)'.tr, AppSettings.instance.formatRupee(_preGstAmount, noDecimals: true),   const Color(0xFF16A34A)),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('GST Breakdown'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: context.text)),
          const SizedBox(height: 10),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r.$1, style: TextStyle(fontSize: 12, color: context.textSub)),
              Text(r.$2, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: r.$3)),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Info Section ───────────────────────────────────────────────────
  Widget _infoSection() => CalculatorInfoSection(
    title: 'About GST Calculator',
    accentColor: _accent,
    items: const [
      InfoItem(
        icon: Icons.help_outline_rounded,
        title: 'What is GST?',
        blocks: [
          InfoBlock.paragraph(
            'GST (Goods and Services Tax) is a unified indirect tax levied on the supply of goods and services in India. '
            'It replaced multiple cascading taxes like VAT, Service Tax, and Excise Duty from July 1, 2017.',
          ),
          InfoBlock.paragraph(
            'GST is a destination-based tax, meaning it is collected at the point of consumption. '
            'It is divided into CGST (Central GST) and SGST (State GST) for intra-state transactions, '
            'or IGST for inter-state transactions.',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.percent_rounded,
        title: 'GST Rate Slabs',
        blocks: [
          InfoBlock.bullets([
            '0% — Essential items: fresh fruits, vegetables, milk, eggs, salt, books.',
            '5% — Common use items: packaged food, footwear < ₹500, transport services.',
            '12% — Processed food, computers, medicines, mobile phones.',
            '18% — Most services (telecom, banking, insurance), AC restaurants, electronics.',
            '28% — Luxury goods: cars, tobacco, aerated drinks, 5-star hotels.',
          ]),
          InfoBlock.tip(
            'For intra-state supply: Total GST = CGST (rate/2) + SGST (rate/2). '
            'For inter-state supply: Total GST = IGST (full rate).',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.functions_rounded,
        title: 'How is GST calculated?',
        blocks: [
          InfoBlock.formula(
            'Add GST (Exclusive → Inclusive):\n'
            '  GST Amount = Original Price × GST Rate / 100\n'
            '  Total Price = Original Price + GST Amount\n\n'
            'Remove GST (Inclusive → Exclusive):\n'
            '  GST Amount = Total Price − (Total Price × 100 / (100 + GST%))\n'
            '  Original Price = Total Price − GST Amount',
          ),
        ],
      ),
      InfoItem(
        icon: Icons.lightbulb_rounded,
        title: 'Smart Tips',
        blocks: [
          InfoBlock.bullets([
            'Always check if the quoted price is inclusive or exclusive of GST.',
            'B2B transactions allow input tax credit (ITC) — you can claim back GST paid.',
            'Small businesses with turnover < ₹40L (goods) / ₹20L (services) are GST-exempt.',
            'Composition scheme: businesses with turnover < ₹1.5Cr pay flat 1–6% GST.',
            'File GST returns on time (GSTR-1, GSTR-3B) to avoid late fees and interest.',
          ]),
          InfoBlock.caution(
            'Non-filing or late filing of GST returns attracts a late fee of ₹50/day '
            '(₹20/day for nil returns) plus 18% p.a. interest on outstanding tax.',
          ),
        ],
      ),
    ],
  );
}
