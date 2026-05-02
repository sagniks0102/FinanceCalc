import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DocumentsRequiredScreen extends StatefulWidget {
  const DocumentsRequiredScreen({super.key});

  @override
  State<DocumentsRequiredScreen> createState() => _DocumentsRequiredScreenState();
}

class _DocumentsRequiredScreenState extends State<DocumentsRequiredScreen> {
  final Map<String, bool> _checked = {};

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: Color(0xFF3B82F6))),
  );

  Widget _subTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(title,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: context.textSub)),
  );

  Widget _item(String label) {
    final checked = _checked[label] ?? false;
    return InkWell(
      onTap: () => setState(() => _checked[label] = !checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: checked ? const Color(0xFF3B82F6) : Colors.transparent,
              border: Border.all(
                color: checked ? const Color(0xFF3B82F6) : context.textSub,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: checked
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: checked
                        ? context.textSub
                        : context.text,
                    decoration: checked ? TextDecoration.lineThrough : null)),
          ),
        ]),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: context.border, indent: 16, endIndent: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text('Documents Required',
            style: TextStyle(color: context.text, fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(children: [
        // Proof of Identity
        _section('Proof of Identity (Any one)'),
        _divider(),
        _item('PAN Card'),
        _divider(),
        _item('Passport'),
        _divider(),
        _item('Aadhaar Card'),
        _divider(),
        _item('Voter ID'),
        _divider(),
        _item('Driving License'),
        _divider(),
        _item('Govt. Employee ID'),
        _divider(),

        // Proof of Residence
        _section('Proof of Residence (Any one)'),
        _divider(),
        _item('Passport'),
        _divider(),
        _item('Aadhaar Card'),
        _divider(),
        _item('Voter ID'),
        _divider(),
        _item('Driving License'),
        _divider(),
        _item('Govt. Employee ID'),
        _divider(),
        _item('Utility Bills (Telephone Bill OR Electricity Bill OR Water Bill OR Gas Bill)'),
        _divider(),

        // Proof of Income
        _section('Proof of Income'),
        _subTitle('For Salaried'),
        _divider(),
        _item('Form 16 of last 2 financial years OR IT Returns of last 2 financial years'),
        _divider(),
        _item('3 months pay slip'),
        _divider(),
        _item('6 months bank statement'),
        _divider(),

        _subTitle('For Self-Employed'),
        _divider(),
        _item('Address Proof of Business'),
        _divider(),
        _item('IT Returns of last 3 financial years'),
        _divider(),
        _item('Balance Sheet & Profit & Loss A/c of last 3 financial years'),
        _divider(),
        _item('Business License Details (or equivalent)'),
        _divider(),
        _item('Certificate of qualification (for C.A. / Doctor and other professionals)'),
        _divider(),
        _item('6 months bank statement'),
        _divider(),

        // Photos
        _section('Other'),
        _divider(),
        _item('Passport Size Photos (3 or more)'),
        _divider(),

        // Note
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 16, color: context.textSub),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The required documents for a loan may vary across financial institutions and loan schemes. '
                'However, these are common criteria for the set of required documents.',
                style: TextStyle(fontSize: 11, color: context.textSub, height: 1.5),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
