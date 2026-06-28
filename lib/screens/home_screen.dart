import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'weight_price_calculator.dart';
import 'coming_soon_screen.dart';

import 'aps_calculator.dart';
import 'ci_calculator.dart';
import 'elss_calculator.dart';
import 'gratuity_calculator.dart';
import 'income_tax_calculator.dart';
import 'inflation_calculator.dart';
import 'interest_rates_screen.dart';
import 'kvp_calculator.dart';
import 'mis_calculator.dart';
import 'nps_calculator.dart';
import 'nsc_calculator.dart';
import 'scss_calculator.dart';
import 'si_calculator.dart';
import 'ssa_calculator.dart';
import 'sym_calculator.dart';
import 'td_calculator.dart';
import 'ups_calculator.dart';
import 'cgt_calculator.dart';
import 'pli_calculator.dart';
import 'rpli_calculator.dart';
import 'jjb_calculator.dart';
import 'sb_calculator.dart';
import 'frsb_calculator.dart';
import 'sgb_calculator.dart';
import 'b54ec_calculator.dart';
import 'bonds_overview_screen.dart';

import '../utils/app_settings.dart';
import '../utils/app_translations.dart';
import '../utils/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/mrec_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';
import '../utils/remote_config_service.dart';
import 'premium_screen.dart';
import '../widgets/calculator_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  InterstitialAd? _interstitialAd;
  bool _isGridView = false;
  final Set<String> _expandedSections = {};

  // Ad frequency caps
  int _backPressCount = 0;
  DateTime _lastAdShownTime = DateTime.now().subtract(
    const Duration(minutes: 5),
  );

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Skip loading ads for premium users or if disabled in remote config
    if (AppSettings.instance.isPremium.value ||
        !RemoteConfigService.instance.showInterstitialAd) {
      return;
    }
    AdHelper.loadInterstitial(
      onLoaded: (ad) {
        _interstitialAd = ad;
      },
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _navigate(Widget screen, {bool showAd = true}) async {
    // 1. Push the target calculator screen into the foreground and wait for it to pop
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    // 2. Skip ad entirely for premium users or if disabled in remote config or if showAd is false
    if (!showAd ||
        AppSettings.instance.isPremium.value ||
        !RemoteConfigService.instance.showInterstitialAd) {
      return;
    }

    // 3. Track back presses and time passed
    _backPressCount++;
    final timePassed = DateTime.now().difference(_lastAdShownTime).inMinutes;

    // Rule: Show only every 3rd back press AND if 3+ minutes passed since last ad
    bool shouldShow = _backPressCount >= 3 && timePassed >= 3;

    // 4. If an ad is ready and rules are met, show it
    if (shouldShow && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadAd(); // preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadAd(); // preload next ad
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _lastAdShownTime = DateTime.now();
      _backPressCount = 0;
    } else if (_interstitialAd == null) {
      _loadAd(); // try to load if it failed before
    }
  }

  void _navigateComingSoon(String title, String abbr, Color color) {
    _navigate(
      ComingSoonScreen(title: title, abbreviation: abbr, badgeColor: color),
    );
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Exit App'.tr,
              style: TextStyle(
                color: context.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Are you sure you want to exit?'.tr,
              style: TextStyle(color: context.textSub),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(color: context.textSub),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Exit'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.instance.language,
      builder: (context, lang, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _showExitDialog();
            if (shouldPop && mounted) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
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
                  child: Icon(
                    Icons.menu_rounded,
                    color: context.text,
                    size: 25,
                  ),
                ),
              ),
              title: Text(
                'Home'.tr,
                style: TextStyle(
                  color: context.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: context.text,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search_rounded, color: context.text),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CalculatorSearchDelegate(onNavigate: _navigate),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── INVESTMENT CALCULATORS ─────────────────────────────
                  _section('Investment Calculators'.tr, [
                    _CalcItem(
                      'SIP\nCalculator'.tr,
                      Icons.show_chart_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const SIPCalculatorScreen()),
                    ),
                    _CalcItem(
                      'Lumpsum\nCalculator'.tr,
                      Icons.bolt_rounded,
                      [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                      () => _navigate(const LumpsumCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SWP\nCalculator'.tr,
                      Icons.trending_down_rounded,
                      [Color(0xFFDC2626), Color(0xFFEF4444)],
                      () => _navigate(const SWPCalculatorScreen()),
                    ),
                    _CalcItem(
                      'EPF\nCalculator'.tr,
                      Icons.account_balance_rounded,
                      [Color(0xFFD97706), Color(0xFFF59E0B)],
                      () => _navigate(const EPFCalculatorScreen()),
                    ),
                    _CalcItem(
                      'PPF\nCalculator'.tr,
                      Icons.savings_rounded,
                      [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      () => _navigate(const PPFCalculatorScreen()),
                    ),
                  ]),

                  // ── MUTUAL FUNDS ──────────────────────────────────────
                  _section('Mutual Funds Calculator', [
                    _CalcItem(
                      'Lumpsum\nCalculator',
                      Icons.pie_chart_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const LumpsumCalculatorScreen()),
                    ),
                    _CalcItem(
                      'ELSS\nCalculator',
                      Icons.workspace_premium_rounded,
                      [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      () => _navigate(const ELSSCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SIP\nCalculator',
                      Icons.show_chart_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const SIPCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SWP\nCalculator',
                      Icons.trending_down_rounded,
                      [Color(0xFFDC2626), Color(0xFFEF4444)],
                      () => _navigate(const SWPCalculatorScreen()),
                    ),
                  ]),

                  // ── UTILITY CALCULATORS ───────────────────────────────
                  _section('Utility Calculators'.tr, [
                    _CalcItem(
                      'Weight & Price\nCalculator'.tr,
                      Icons.scale_rounded,
                      [Color(0xFFEAB308), Color(0xFFFACC15)],
                      () => _navigate(
                        const WeightPriceCalculatorScreen(),
                        showAd: false,
                      ),
                    ),
                  ]),

                  // ── BANKING CALCULATORS ───────────────────────────────
                  _section('Banking Calculators'.tr, [
                    _CalcItem(
                      'FD\nCalculator'.tr,
                      Icons.account_balance_wallet_rounded,
                      [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      () => _navigate(const FDCalculatorScreen()),
                    ),
                    _CalcItem(
                      'RD\nCalculator'.tr,
                      Icons.repeat_rounded,
                      [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                      () => _navigate(const RDCalculatorScreen()),
                    ),
                    _CalcItem(
                      'Interest\nRates',
                      Icons.percent_rounded,
                      [Color(0xFFD97706), Color(0xFFF59E0B)],
                      () => _navigate(const InterestRatesScreen()),
                    ),
                  ]),

                  // ── BANK & POST OFFICE ────────────────────────────────
                  _section('Bank & Post Office', [
                    _CalcItem(
                      'PPF\nCalculator',
                      Icons.savings_rounded,
                      [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      () => _navigate(const PPFCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SSA\nCalculator',
                      Icons.girl_rounded,
                      [Color(0xFF6366F1), Color(0xFF818CF8)],
                      () => _navigate(const SSACalculatorScreen()),
                    ),
                    _CalcItem(
                      'SCSS\nCalculator',
                      Icons.elderly_rounded,
                      [Color(0xFF9333EA), Color(0xFFA855F7)],
                      () => _navigate(const SCSSCalculatorScreen()),
                    ),
                    _CalcItem(
                      'KVP\nCalculator',
                      Icons.agriculture_rounded,
                      [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      () => _navigate(const KVPCalculatorScreen()),
                    ),
                  ]),

                  const Center(child: MrecAdWidget()),
                  const SizedBox(height: 8),

                  // ── POST OFFICE ───────────────────────────────────────
                  _section('Post Office', [
                    _CalcItem(
                      'MIS\nCalculator',
                      Icons.mail_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const MISCalculatorScreen()),
                    ),
                    _CalcItem(
                      'RD\nCalculator',
                      Icons.repeat_rounded,
                      [Color(0xFFDC2626), Color(0xFFEF4444)],
                      () => _navigate(const RDCalculatorScreen()),
                    ),
                    _CalcItem(
                      'TD\nCalculator',
                      Icons.access_time_filled_rounded,
                      [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      () => _navigate(const TDCalculatorScreen()),
                    ),
                    _CalcItem(
                      'NSC\nCalculator',
                      Icons.security_rounded,
                      [Color(0xFFDB2777), Color(0xFFEC4899)],
                      () => _navigate(const NSCCalculatorScreen()),
                    ),
                    _CalcItem(
                      'Interest\nRates',
                      Icons.percent_rounded,
                      [Color(0xFFD97706), Color(0xFFF59E0B)],
                      () => _navigate(const InterestRatesScreen()),
                    ),
                  ]),

                  // ── EMI CALCULATORS ───────────────────────────────────
                  _section('EMI Calculators'.tr, [
                    _CalcItem(
                      'EMI\nCalculator'.tr,
                      Icons.calculate_rounded,
                      [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      () => _navigate(const EMICalculatorScreen()),
                    ),
                  ]),

                  // ── RETIREMENT ────────────────────────────────────────
                  _section('Retirement', [
                    _CalcItem(
                      'NPS\nCalculator',
                      Icons.account_balance_rounded,
                      [Color(0xFF6366F1), Color(0xFF818CF8)],
                      () => _navigate(const NPSCalculatorScreen()),
                    ),
                    _CalcItem(
                      'UPS\nCalculator',
                      Icons.shield_rounded,
                      [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      () => _navigate(const UPSCalculatorScreen()),
                    ),
                    _CalcItem(
                      'EPF\nCalculator',
                      Icons.account_balance_rounded,
                      [Color(0xFFD97706), Color(0xFFF59E0B)],
                      () => _navigate(const EPFCalculatorScreen()),
                    ),
                    _CalcItem(
                      'APS\nCalculator',
                      Icons.volunteer_activism_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const APSCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SYM\nCalculator',
                      Icons.engineering_rounded,
                      [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      () => _navigate(const SYMCalculatorScreen()),
                    ),
                    _CalcItem(
                      'Gratuity\nCalculator',
                      Icons.card_giftcard_rounded,
                      [Color(0xFF9333EA), Color(0xFFA855F7)],
                      () => _navigate(const GratuityCalculatorScreen()),
                    ),
                  ]),

                  // ── TAX CALCULATORS ───────────────────────────────────
                  _section('Tax Calculators'.tr, [
                    _CalcItem(
                      'GST\nCalculator'.tr,
                      Icons.receipt_long_rounded,
                      [Color(0xFF15803D), Color(0xFF22C55E)],
                      () => _navigate(const GSTCalculatorScreen()),
                    ),
                    _CalcItem(
                      'Income Tax\nCalculator',
                      Icons.account_balance_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const IncomeTaxCalculatorScreen()),
                    ),
                    _CalcItem(
                      'Capital Gains\nTax',
                      Icons.trending_up_rounded,
                      [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      () => _navigate(const CGTCalculatorScreen()),
                    ),
                  ]),

                  // ── INSURANCE ─────────────────────────────────────────
                  _section('Insurance', [
                    _CalcItem(
                      'PLI\nCalculator',
                      Icons.health_and_safety_rounded,
                      [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      () => _navigate(const PLICalculatorScreen()),
                    ),
                    _CalcItem(
                      'RPLI\nCalculator',
                      Icons.local_hospital_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const RPLICalculatorScreen()),
                    ),
                    _CalcItem(
                      'JJB\nCalculator',
                      Icons.favorite_rounded,
                      [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      () => _navigate(const JJBCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SB\nCalculator',
                      Icons.shield_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const SBCalculatorScreen()),
                    ),
                  ]),

                  // ── BONDS ─────────────────────────────────────────────
                  _section('Bonds', [
                    _CalcItem(
                      'Bonds\nOverview',
                      Icons.article_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const BondsOverviewScreen()),
                    ),
                    _CalcItem(
                      'FRSB\nCalculator',
                      Icons.swap_vert_rounded,
                      [Color(0xFFDC2626), Color(0xFFEF4444)],
                      () => _navigate(const FRSBCalculatorScreen()),
                    ),
                    _CalcItem(
                      'SGB\nCalculator',
                      Icons.monetization_on_rounded,
                      [Color(0xFF059669), Color(0xFF10B981)],
                      () => _navigate(const SGBCalculatorScreen()),
                    ),
                    _CalcItem(
                      '54EC\nBonds',
                      Icons.gavel_rounded,
                      [Color(0xFFDC2626), Color(0xFFEF4444)],
                      () => _navigate(const B54ECCalculatorScreen()),
                    ),
                  ]),

                  // ── GENERAL ───────────────────────────────────────────
                  _section('General', [
                    _CalcItem(
                      'Compound\nInterest',
                      Icons.functions_rounded,
                      [Color(0xFFD97706), Color(0xFFF59E0B)],
                      () => _navigate(const CompoundInterestScreen()),
                    ),
                    _CalcItem(
                      'Simple\nInterest',
                      Icons.calculate_outlined,
                      [Color(0xFFDB2777), Color(0xFFEC4899)],
                      () => _navigate(const SimpleInterestScreen()),
                    ),
                    _CalcItem(
                      'Inflation\nCalculator',
                      Icons.trending_up_rounded,
                      [Color(0xFFD97706), Color(0xFFF59E0B)],
                      () => _navigate(const InflationCalculatorScreen()),
                    ),
                  ]),
                ],
              ),
            ),
            bottomNavigationBar: const BannerAdWidget(),
          ),
        );
      },
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) => Drawer(
    backgroundColor: context.bg,
    child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Go Premium banner ────────────────────────────────────────
          // ── App Name Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              'Finance Calculator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.text,
                letterSpacing: 0.5,
              ),
            ),
          ),

          /* 
          // Temporarily disabled Premium banner (will enable in future)
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.instance.isPremium,
            builder: (_, isPremium, __) => Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPremium
                      ? [Color(0xFF059669), Color(0xFF10B981)]
                      : [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPremium
                              ? Icons.check_circle_rounded
                              : Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPremium ? 'Premium Active ✓' : 'Remove All Ads',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (!isPremium) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigate(const PremiumScreen(), showAd: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1D4ED8),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Go Premium',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.chevron_right_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ads removed. Thank you for supporting us! 🙏',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          */

          const SizedBox(height: 8),

          // ── CALCULATOR section ───────────────────────────────────────
          _dLabel('CALCULATOR'.tr),
          _dTile(
            Icons.home_rounded,
            'Dashboard'.tr,
            () => Navigator.pop(context),
          ),
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
            launchUrl(
              Uri.parse('https://appnexivo-dotcom.github.io/privacy-policy/'),
              mode: LaunchMode.externalApplication,
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    ),
  );

  Widget _dLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.textSub,
        letterSpacing: 1.0,
      ),
    ),
  );

  Widget _dTile(IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Icon(
      icon,
      color: context.textSub.withValues(alpha: 0.8),
      size: 22,
    ),
    title: Text(title, style: TextStyle(color: context.text, fontSize: 14)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.share_rounded, size: 40, color: Color(0xFF6366F1)),
            const SizedBox(height: 12),
            Text(
              'Tell a Friend!',
              style: TextStyle(
                color: context.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hey! Check out this free Financial Calculator app — '
              'it has EMI, SIP, Lumpsum, GST, EPF, PPF calculators and more!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSub,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  const message = 'Hey! Check out this free Financial Calculator app — '
                      'it has EMI, SIP, Lumpsum, GST, EPF, PPF calculators and more!\n\n'
                      'Download: https://play.google.com/store/apps/details?id=com.nexivo.financecalc';
                  Clipboard.setData(const ClipboardData(text: message));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✓ Invite message copied to clipboard!'),
                      backgroundColor: context.card,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Invite Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showRateApp() {
    int stars = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: context.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 48,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 12),
              Text(
                'Enjoying the app?',
                style: TextStyle(
                  color: context.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rate us on the Play Store',
                style: TextStyle(color: context.textSub, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setLocal(() => stars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        stars > i
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 36,
                        color: stars > i
                            ? const Color(0xFFF59E0B)
                            : context.border,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: stars > 0
                      ? () {
                          Navigator.pop(ctx);
                          // Open the Play Store listing for ratings
                          launchUrl(
                            Uri.parse('https://play.google.com/store/apps/details?id=com.nexivo.financecalc'),
                            mode: LaunchMode.externalApplication,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Thanks for the $stars-star rating! ⭐',
                              ),
                              backgroundColor: context.card,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.border,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Rating',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Maybe later',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final apps = [
          (
            'Unit Converter',
            'Convert length, weight, temperature & more',
            Icons.swap_horiz_rounded,
            Color(0xFF0EA5E9),
          ),
          (
            'Currency Converter',
            'Live exchange rates for 150+ currencies',
            Icons.currency_exchange_rounded,
            Color(0xFF22C55E),
          ),
          (
            'Age Calculator',
            'Calculate exact age in years, months & days',
            Icons.cake_rounded,
            Color(0xFFF59E0B),
          ),
          (
            'BMI Calculator',
            'Check your Body Mass Index instantly',
            Icons.monitor_weight_rounded,
            Color(0xFFEF4444),
          ),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.textSub,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'More Apps',
              style: TextStyle(
                color: context.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...apps.map(
              (a) => ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: a.$4.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a.$3, color: a.$4, size: 22),
                ),
                title: Text(
                  a.$1,
                  style: TextStyle(
                    color: context.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  a.$2,
                  style: TextStyle(color: context.textSub, fontSize: 11),
                ),
                trailing: Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: context.textSub,
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Coming soon on Play Store!'),
                      backgroundColor: context.card,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ── Section builder ──────────────────────────────────────────────────
  Widget _section(String title, List<_CalcItem> items) {
    if (_isGridView) {
      final isExpanded = _expandedSections.contains(title);
      return Container(
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
            // ── Section header with expand/collapse toggle ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: context.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Only show toggle if more than 4 items (single row fits ~4)
                  if (items.length > 4)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedSections.remove(title);
                            } else {
                              _expandedSections.add(title);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isExpanded ? 'Less' : 'All',
                                style: TextStyle(
                                  color: context.textSub,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 2),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: context.textSub,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Content: horizontal scroll (collapsed) or wrap (expanded) ──
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) => SizedBox(
                    width: 72,
                    child: CalculatorCard(
                      label: items[i].label,
                      icon: items[i].icon,
                      gradientColors: items[i].colors,
                      onTap: items[i].onTap,
                    ),
                  ),
                ),
              ),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.start,
                  children: items
                      .map(
                        (item) => SizedBox(
                          width: 72,
                          child: CalculatorCard(
                            label: item.label,
                            icon: item.icon,
                            gradientColors: item.colors,
                            onTap: item.onTap,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: items.map((item) {
                final abbr = _getAbbr(item.label);
                final fullForm = _getFullForm(item.label);
                return GestureDetector(
                  onTap: item.onTap,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: context.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // ── Gradient badge with icon + abbreviation ──
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: item.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                abbr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ── Full form name ──
                        Expanded(
                          child: Text(
                            fullForm,
                            style: TextStyle(
                              color: context.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }
  }

  String _getAbbr(String label) {
    final clean = label.replaceAll('\n', ' ');
    if (clean.contains('Interest Rates')) return '%';
    if (clean.contains('Weight')) return 'W&P';
    if (clean.contains('Compound')) return 'CI';
    if (clean.contains('Simple')) return 'SI';
    if (clean.contains('Inflation')) return 'INF';
    if (clean.contains('Gratuity')) return 'GRT';
    if (clean.contains('Income Tax')) return 'TAX';
    if (clean.contains('Capital Gains')) return 'CGT';
    if (clean.contains('Bonds Overview')) return 'BND';
    if (clean.contains('Mutual Funds Overview')) return 'MF';
    final parts = label.split('\n');
    if (parts.length > 1 && parts[0].length <= 5) return parts[0];
    return parts[0]
        .substring(0, parts[0].length > 3 ? 3 : parts[0].length)
        .toUpperCase();
  }

  String _getFullForm(String label) {
    String text = label.replaceAll('\n', ' ');
    if (text.startsWith('SIP ')) return 'SIP (Systematic Investment Plan)';
    if (text.startsWith('Lumpsum ')) return 'Lumpsum Investment';
    if (text.startsWith('SWP ')) return 'SWP (Systematic Withdrawal Plan)';
    if (text.startsWith('EPF ')) return 'EPF (Employees Provident Fund)';
    if (text.startsWith('PPF ')) return 'Public Provident Fund';
    if (text.startsWith('ELSS ')) return 'ELSS (Equity Linked Savings Scheme)';
    if (text.startsWith('FD ')) return 'Fixed Deposit';
    if (text.startsWith('RD ')) return 'Recurring Deposit';
    if (text.startsWith('SSA ')) return 'Sukanya Samriddhi Account';
    if (text.startsWith('SCSS ')) return 'Senior Citizens Savings Scheme';
    if (text.startsWith('KVP ')) return 'Kisan Vikas Patra';
    if (text.startsWith('MIS ')) return 'Post Office Monthly Income Scheme';
    if (text.startsWith('TD ')) return 'Time Deposit';
    if (text.startsWith('NSC ')) return 'National Savings Certificate';
    if (text.startsWith('EMI ')) return 'Loan - Basic (EMI)';
    if (text.startsWith('NPS ')) return 'National Pension System';
    if (text.startsWith('UPS ')) return 'Unified Pension Scheme';
    if (text.startsWith('APS ')) return 'Atal Pension Yojana';
    if (text.startsWith('SYM ')) return 'PM Shram Yogi Maandhan';
    if (text.startsWith('GST ')) return 'Goods and Services Tax';
    if (text.startsWith('CGT ')) return 'Capital Gains Tax';
    if (text.startsWith('PLI ')) return 'Postal Life Insurance';
    if (text.startsWith('RPLI ')) return 'Rural Postal Life Insurance';
    if (text.startsWith('JJB ')) return 'PM Jeevan Jyoti Bima';
    if (text.startsWith('SB ')) return 'PM Suraksha Bima Yojana';
    if (text.startsWith('FRSB ')) return 'Floating Rate Savings Bonds';
    if (text.startsWith('SGB ')) return 'Sovereign Gold Bond';
    if (text.startsWith('54EC ')) return '54EC Capital Gain Bonds';
    return text;
  }
}

class _CalcItem {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _CalcItem(this.label, this.icon, this.colors, this.onTap);
}
