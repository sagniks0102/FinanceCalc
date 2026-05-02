import 'package:flutter/material.dart';
import '../widgets/calculator_card.dart';
import 'emi_calculator.dart';
import 'sip_calculator.dart';
import 'fd_calculator.dart';
import 'rd_calculator.dart';
import 'ppf_calculator.dart';
import 'epf_calculator.dart';
import 'swp_calculator.dart';
import 'lumpsum_calculator.dart';
import 'gst_calculator.dart';
import 'documents_required_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'privacy_screen.dart';

import '../utils/app_settings.dart';
import '../utils/app_translations.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigate(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.instance.language,
      builder: (context, lang, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: context.bg,
          drawer: _buildDrawer(context),
          appBar: AppBar(
            backgroundColor: context.bg,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: context.text.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_rounded, color: Colors.white, size: 25),
              ),
            ),
            title: Text('Dashboard'.tr,
                style: TextStyle(color: context.text, fontSize: 22,
                    fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('Investment Calculators'.tr, [
                _CalcItem('SIP\nCalculator'.tr, Icons.show_chart_rounded,
                    [Color(0xFF059669), Color(0xFF10B981)],
                    () => _navigate(const SIPCalculatorScreen())),
                _CalcItem('Lumpsum\nCalculator'.tr, Icons.bolt_rounded,
                    [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                    () => _navigate(const LumpsumCalculatorScreen())),
                _CalcItem('SWP\nCalculator'.tr, Icons.trending_down_rounded,
                    [Color(0xFFDC2626), Color(0xFFEF4444)],
                    () => _navigate(const SWPCalculatorScreen())),
                _CalcItem('EPF\nCalculator'.tr, Icons.account_balance_rounded,
                    [Color(0xFFD97706), Color(0xFFF59E0B)],
                    () => _navigate(const EPFCalculatorScreen())),
                _CalcItem('PPF\nCalculator'.tr, Icons.savings_rounded,
                    [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    () => _navigate(const PPFCalculatorScreen())),
              ]),
              _section('Banking Calculators'.tr, [
                _CalcItem('FD\nCalculator'.tr, Icons.account_balance_wallet_rounded,
                    [Color(0xFF0D9488), Color(0xFF14B8A6)],
                    () => _navigate(const FDCalculatorScreen())),
                _CalcItem('RD\nCalculator'.tr, Icons.repeat_rounded,
                    [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                    () => _navigate(const RDCalculatorScreen())),
              ]),
              _section('EMI Calculators'.tr, [
                _CalcItem('EMI\nCalculator'.tr, Icons.calculate_rounded,
                    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    () => _navigate(const EMICalculatorScreen())),
              ]),
              _section('Tax Calculators'.tr, [
                _CalcItem('GST\nCalculator'.tr, Icons.receipt_long_rounded,
                    [Color(0xFF15803D), Color(0xFF22C55E)],
                    () => _navigate(const GSTCalculatorScreen())),
              ]),
            ]),
          ),
        );
      },
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) => Drawer(
    backgroundColor: context.bg,
    child: SafeArea(
      child: ListView(padding: EdgeInsets.zero, children: [
        // ── Go Premium banner ────────────────────────────────────────
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Remove All Ads',
                  style: TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D4ED8),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Go Premium',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 8),

        // ── CALCULATOR section ───────────────────────────────────────
        _dLabel('CALCULATOR'.tr),
        _dTile(Icons.home_rounded, 'Dashboard'.tr, () => Navigator.pop(context)),
        // _dTile(Icons.history_rounded, 'History'.tr, () {
        //   Navigator.pop(context);
        //   _navigate(const HistoryScreen());
        // }),
        _dTile(Icons.description_rounded, 'Documents Required'.tr, () {
          Navigator.pop(context);
          _navigate(const DocumentsRequiredScreen());
        }),
        _dTile(Icons.settings_rounded, 'Settings'.tr, () {
          Navigator.pop(context);
          _navigate(const SettingsScreen());
        }),

        Divider(color: context.border, height: 28, indent: 16, endIndent: 16),

        // ── SYSTEM section ───────────────────────────────────────────
        _dLabel('SYSTEM'.tr),
        _dTile(Icons.share_rounded, 'Tell a Friend'.tr, () {
          Navigator.pop(context);
          _showTellAFriend();
        }),
        _dTile(Icons.star_outline_rounded, 'Rate This App'.tr, () {
          Navigator.pop(context);
          _showRateApp();
        }),
        _dTile(Icons.apps_rounded, 'More Apps'.tr, () {
          Navigator.pop(context);
          _showMoreApps();
        }),
        _dTile(Icons.privacy_tip_outlined, 'Privacy'.tr, () {
          Navigator.pop(context);
          _navigate(const PrivacyScreen());
        }),

        const SizedBox(height: 24),
      ]),
    ),
  );

  Widget _dLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
    child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: context.textSub, letterSpacing: 1.0)),
  );

  Widget _dTile(IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: context.textSub.withValues(alpha: 0.8), size: 22),
    title: Text(title,
        style: TextStyle(color: context.text, fontSize: 14)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    horizontalTitleGap: 10,
    dense: true,
    minLeadingWidth: 20,
  );

  // ── System action dialogs ────────────────────────────────────────────
  void _showTellAFriend() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Icon(Icons.share_rounded, size: 40, color: Color(0xFF6366F1)),
          const SizedBox(height: 12),
          Text('Tell a Friend!',
              style: TextStyle(color: context.text, fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Hey! Check out this free Financial Calculator app — '
            'it has EMI, SIP, Lumpsum, GST, EPF, PPF calculators and more!',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSub, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy Invite Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showRateApp() {
    int _stars = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: context.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calculate_rounded, size: 48, color: Color(0xFF6366F1)),
            const SizedBox(height: 12),
            Text('Enjoying the app?',
                style: TextStyle(color: context.text, fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Rate us on the Play Store',
                style: TextStyle(color: context.textSub, fontSize: 13)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setLocal(() => _stars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      _stars > i ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: _stars > i
                          ? const Color(0xFFF59E0B)
                          : context.border,
                    ),
                  ),
                ))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _stars > 0
                    ? () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Thanks for the $_stars-star rating! ⭐'),
                          backgroundColor: context.card,
                        ));
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: context.border,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Rating',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          actionsPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe later',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreApps() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final apps = [
          ('Unit Converter', 'Convert length, weight, temperature & more',
              Icons.swap_horiz_rounded, Color(0xFF0EA5E9)),
          ('Currency Converter', 'Live exchange rates for 150+ currencies',
              Icons.currency_exchange_rounded, Color(0xFF22C55E)),
          ('Age Calculator', 'Calculate exact age in years, months & days',
              Icons.cake_rounded, Color(0xFFF59E0B)),
          ('BMI Calculator', 'Check your Body Mass Index instantly',
              Icons.monitor_weight_rounded, Color(0xFFEF4444)),
        ];
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: context.textSub,
                  borderRadius: BorderRadius.circular(2))),
          Text('More Apps',
              style: TextStyle(color: context.text, fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...apps.map((a) => ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: a.$4.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(a.$3, color: a.$4, size: 22),
            ),
            title: Text(a.$1,
                style: TextStyle(color: context.text,
                    fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(a.$2,
                style: TextStyle(color: context.textSub, fontSize: 11)),
            trailing: Icon(Icons.open_in_new_rounded,
                size: 16, color: context.textSub),
            onTap: () => Navigator.pop(context),
          )),
          const SizedBox(height: 16),
        ]);
      },
    );
  }

  // ── Section builder ──────────────────────────────────────────────────
  Widget _section(String title, List<_CalcItem> items) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.border, width: 1),
    ),
    padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(title,
              style: TextStyle(color: context.text, fontSize: 17,
                  fontWeight: FontWeight.w600)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CalculatorCard(
                label: item.label,
                icon: item.icon,
                gradientColors: item.colors,
                onTap: item.onTap,
              ),
            )).toList(),
          ),
        ),
      ],
    ),
  );
}

class _CalcItem {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _CalcItem(this.label, this.icon, this.colors, this.onTap);
}
