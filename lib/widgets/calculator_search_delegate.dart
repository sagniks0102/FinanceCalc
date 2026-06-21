import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/app_translations.dart';
import '../widgets/calculator_card.dart';

import '../screens/emi_calculator.dart';
import '../screens/sip_calculator.dart';
import '../screens/fd_calculator.dart';
import '../screens/rd_calculator.dart';
import '../screens/ppf_calculator.dart';
import '../screens/epf_calculator.dart';
import '../screens/swp_calculator.dart';
import '../screens/lumpsum_calculator.dart';
import '../screens/gst_calculator.dart';
import '../screens/weight_price_calculator.dart';
import '../screens/aps_calculator.dart';
import '../screens/ci_calculator.dart';
import '../screens/elss_calculator.dart';
import '../screens/gratuity_calculator.dart';
import '../screens/income_tax_calculator.dart';
import '../screens/inflation_calculator.dart';
import '../screens/interest_rates_screen.dart';
import '../screens/kvp_calculator.dart';
import '../screens/mis_calculator.dart';
import '../screens/nps_calculator.dart';
import '../screens/nsc_calculator.dart';
import '../screens/scss_calculator.dart';
import '../screens/si_calculator.dart';
import '../screens/ssa_calculator.dart';
import '../screens/sym_calculator.dart';
import '../screens/td_calculator.dart';
import '../screens/ups_calculator.dart';
import '../screens/cgt_calculator.dart';
import '../screens/pli_calculator.dart';
import '../screens/rpli_calculator.dart';
import '../screens/jjb_calculator.dart';
import '../screens/sb_calculator.dart';
import '../screens/frsb_calculator.dart';
import '../screens/sgb_calculator.dart';
import '../screens/b54ec_calculator.dart';
import '../screens/bonds_overview_screen.dart';

class CalculatorSearchDelegate extends SearchDelegate<String> {
  final void Function(Widget screen, {bool showAd}) onNavigate;

  CalculatorSearchDelegate({required this.onNavigate});

  @override
  String get searchFieldLabel => 'Search Calculators...'.tr;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: context.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: context.text),
        titleTextStyle: TextStyle(color: context.text, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: context.textSub),
      ),
      scaffoldBackgroundColor: context.bg,
      textTheme: TextTheme(
        titleLarge: TextStyle(color: context.text, fontSize: 18),
      ),
    );
  }

  // The list of all calculators
  final List<Map<String, dynamic>> calculators = [
    {
      'name': 'SIP Calculator',
      'label': 'SIP\nCalculator',
      'icon': Icons.show_chart_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const SIPCalculatorScreen(),
      'keywords': ['Systematic Investment Plan', 'SIP']
    },
    {
      'name': 'Lumpsum Calculator',
      'label': 'Lumpsum\nCalculator',
      'icon': Icons.bolt_rounded,
      'colors': [const Color(0xFF0284C7), const Color(0xFF0EA5E9)],
      'screen': const LumpsumCalculatorScreen(),
      'keywords': ['Lumpsum', 'Lump Sum', 'One-time Investment']
    },
    {
      'name': 'SWP Calculator',
      'label': 'SWP\nCalculator',
      'icon': Icons.trending_down_rounded,
      'colors': [const Color(0xFFDC2626), const Color(0xFFEF4444)],
      'screen': const SWPCalculatorScreen(),
      'keywords': ['Systematic Withdrawal Plan', 'SWP']
    },
    {
      'name': 'EPF Calculator',
      'label': 'EPF\nCalculator',
      'icon': Icons.account_balance_rounded,
      'colors': [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      'screen': const EPFCalculatorScreen(),
      'keywords': ['Employees Provident Fund', 'EPF', 'Provident Fund']
    },
    {
      'name': 'PPF Calculator',
      'label': 'PPF\nCalculator',
      'icon': Icons.savings_rounded,
      'colors': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      'screen': const PPFCalculatorScreen(),
      'keywords': ['Public Provident Fund', 'PPF']
    },
    {
      'name': 'ELSS Calculator',
      'label': 'ELSS\nCalculator',
      'icon': Icons.workspace_premium_rounded,
      'colors': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      'screen': const ELSSCalculatorScreen(),
      'keywords': ['Equity Linked Savings Scheme', 'ELSS', 'Tax Saving Mutual Fund']
    },
    {
      'name': 'Weight & Price Calculator',
      'label': 'Weight & Price\nCalculator',
      'icon': Icons.scale_rounded,
      'colors': [const Color(0xFFEAB308), const Color(0xFFFACC15)],
      'screen': const WeightPriceCalculatorScreen(),
      'showAd': false,
      'keywords': ['Weight and Price', 'Weight & Price', 'Scale']
    },
    {
      'name': 'FD Calculator',
      'label': 'FD\nCalculator',
      'icon': Icons.account_balance_wallet_rounded,
      'colors': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      'screen': const FDCalculatorScreen(),
      'keywords': ['Fixed Deposit', 'FD']
    },
    {
      'name': 'RD Calculator',
      'label': 'RD\nCalculator',
      'icon': Icons.repeat_rounded,
      'colors': [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)],
      'screen': const RDCalculatorScreen(),
      'keywords': ['Recurring Deposit', 'RD']
    },
    {
      'name': 'Interest Rates',
      'label': 'Interest\nRates',
      'icon': Icons.percent_rounded,
      'colors': [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      'screen': const InterestRatesScreen(),
      'keywords': ['Interest Rates', 'Rate of Interest', 'Interest Rate']
    },
    {
      'name': 'SSA Calculator',
      'label': 'SSA\nCalculator',
      'icon': Icons.girl_rounded,
      'colors': [const Color(0xFF6366F1), const Color(0xFF818CF8)],
      'screen': const SSACalculatorScreen(),
      'keywords': ['Sukanya Samriddhi Account', 'SSA', 'Sukanya Samriddhi Yojana', 'SSY']
    },
    {
      'name': 'SCSS Calculator',
      'label': 'SCSS\nCalculator',
      'icon': Icons.elderly_rounded,
      'colors': [const Color(0xFF9333EA), const Color(0xFFA855F7)],
      'screen': const SCSSCalculatorScreen(),
      'keywords': ['Senior Citizens Savings Scheme', 'SCSS']
    },
    {
      'name': 'KVP Calculator',
      'label': 'KVP\nCalculator',
      'icon': Icons.agriculture_rounded,
      'colors': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      'screen': const KVPCalculatorScreen(),
      'keywords': ['Kisan Vikas Patra', 'KVP']
    },
    {
      'name': 'MIS Calculator',
      'label': 'MIS\nCalculator',
      'icon': Icons.mail_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const MISCalculatorScreen(),
      'keywords': ['Monthly Income Scheme', 'MIS', 'Post Office Monthly Income Scheme', 'POMIS']
    },
    {
      'name': 'TD Calculator',
      'label': 'TD\nCalculator',
      'icon': Icons.access_time_filled_rounded,
      'colors': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      'screen': const TDCalculatorScreen(),
      'keywords': ['Time Deposit', 'TD', 'Post Office Time Deposit', 'POTD']
    },
    {
      'name': 'NSC Calculator',
      'label': 'NSC\nCalculator',
      'icon': Icons.security_rounded,
      'colors': [const Color(0xFFDB2777), const Color(0xFFEC4899)],
      'screen': const NSCCalculatorScreen(),
      'keywords': ['National Savings Certificate', 'NSC']
    },
    {
      'name': 'EMI Calculator',
      'label': 'EMI\nCalculator',
      'icon': Icons.calculate_rounded,
      'colors': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      'screen': const EMICalculatorScreen(),
      'keywords': ['Equated Monthly Installment', 'EMI', 'Loan EMI', 'Monthly Installment']
    },
    {
      'name': 'NPS Calculator',
      'label': 'NPS\nCalculator',
      'icon': Icons.account_balance_rounded,
      'colors': [const Color(0xFF6366F1), const Color(0xFF818CF8)],
      'screen': const NPSCalculatorScreen(),
      'keywords': ['National Pension System', 'NPS', 'National Pension Scheme']
    },
    {
      'name': 'UPS Calculator',
      'label': 'UPS\nCalculator',
      'icon': Icons.shield_rounded,
      'colors': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      'screen': const UPSCalculatorScreen(),
      'keywords': ['Unified Pension Scheme', 'UPS']
    },
    {
      'name': 'APS Calculator',
      'label': 'APS\nCalculator',
      'icon': Icons.volunteer_activism_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const APSCalculatorScreen(),
      'keywords': ['Atal Pension Yojana', 'APS', 'Atal Pension Scheme', 'APY']
    },
    {
      'name': 'SYM Calculator',
      'label': 'SYM\nCalculator',
      'icon': Icons.engineering_rounded,
      'colors': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      'screen': const SYMCalculatorScreen(),
      'keywords': ['Shram Yogi Maandhan', 'SYM', 'Pradhan Mantri Shram Yogi Maan-dhan', 'PMSYM']
    },
    {
      'name': 'Gratuity Calculator',
      'label': 'Gratuity\nCalculator',
      'icon': Icons.card_giftcard_rounded,
      'colors': [const Color(0xFF9333EA), const Color(0xFFA855F7)],
      'screen': const GratuityCalculatorScreen(),
      'keywords': ['Gratuity']
    },
    {
      'name': 'GST Calculator',
      'label': 'GST\nCalculator',
      'icon': Icons.receipt_long_rounded,
      'colors': [const Color(0xFF15803D), const Color(0xFF22C55E)],
      'screen': const GSTCalculatorScreen(),
      'keywords': ['Goods and Services Tax', 'GST']
    },
    {
      'name': 'Income Tax Calculator',
      'label': 'Income Tax\nCalculator',
      'icon': Icons.account_balance_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const IncomeTaxCalculatorScreen(),
      'keywords': ['Income Tax', 'IT Calculator', 'Tax']
    },
    {
      'name': 'Capital Gains Tax',
      'label': 'Capital Gains\nTax',
      'icon': Icons.trending_up_rounded,
      'colors': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      'screen': const CGTCalculatorScreen(),
      'keywords': ['Capital Gains Tax', 'CGT', 'Capital Gains']
    },
    {
      'name': 'PLI Calculator',
      'label': 'PLI\nCalculator',
      'icon': Icons.health_and_safety_rounded,
      'colors': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      'screen': const PLICalculatorScreen(),
      'keywords': ['Postal Life Insurance', 'PLI']
    },
    {
      'name': 'RPLI Calculator',
      'label': 'RPLI\nCalculator',
      'icon': Icons.local_hospital_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const RPLICalculatorScreen(),
      'keywords': ['Rural Postal Life Insurance', 'RPLI']
    },
    {
      'name': 'JJB Calculator',
      'label': 'JJB\nCalculator',
      'icon': Icons.favorite_rounded,
      'colors': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      'screen': const JJBCalculatorScreen(),
      'keywords': ['PM Jeevan Jyoti Bima', 'Pradhan Mantri Jeevan Jyoti Bima Yojana', 'JJB', 'PMJJBY']
    },
    {
      'name': 'SB Calculator',
      'label': 'SB\nCalculator',
      'icon': Icons.shield_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const SBCalculatorScreen(),
      'keywords': ['PM Suraksha Bima', 'Pradhan Mantri Suraksha Bima Yojana', 'SB', 'PMSBY']
    },
    {
      'name': 'Bonds Overview',
      'label': 'Bonds\nOverview',
      'icon': Icons.article_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const BondsOverviewScreen(),
      'keywords': ['Bonds Overview', 'Bonds']
    },
    {
      'name': 'FRSB Calculator',
      'label': 'FRSB\nCalculator',
      'icon': Icons.swap_vert_rounded,
      'colors': [const Color(0xFFDC2626), const Color(0xFFEF4444)],
      'screen': const FRSBCalculatorScreen(),
      'keywords': ['Floating Rate Savings Bonds', 'FRSB']
    },
    {
      'name': 'SGB Calculator',
      'label': 'SGB\nCalculator',
      'icon': Icons.monetization_on_rounded,
      'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      'screen': const SGBCalculatorScreen(),
      'keywords': ['Sovereign Gold Bond', 'SGB']
    },
    {
      'name': '54EC Bonds',
      'label': '54EC\nBonds',
      'icon': Icons.gavel_rounded,
      'colors': [const Color(0xFFDC2626), const Color(0xFFEF4444)],
      'screen': const B54ECCalculatorScreen(),
      'keywords': ['54EC Bonds', '54EC']
    },
    {
      'name': 'Compound Interest',
      'label': 'Compound\nInterest',
      'icon': Icons.functions_rounded,
      'colors': [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      'screen': const CompoundInterestScreen(),
      'keywords': ['Compound Interest', 'CI']
    },
    {
      'name': 'Simple Interest',
      'label': 'Simple\nInterest',
      'icon': Icons.calculate_outlined,
      'colors': [const Color(0xFFDB2777), const Color(0xFFEC4899)],
      'screen': const SimpleInterestScreen(),
      'keywords': ['Simple Interest', 'SI']
    },
    {
      'name': 'Inflation Calculator',
      'label': 'Inflation\nCalculator',
      'icon': Icons.trending_up_rounded,
      'colors': [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      'screen': const InflationCalculatorScreen(),
      'keywords': ['Inflation Calculator', 'Inflation']
    },
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final filtered = calculators.where((c) {
      final name = (c['name'] as String).toLowerCase();
      final trName = (c['name'] as String).tr.toLowerCase();
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return true;

      // Check main name and translated name
      if (name.contains(q) || trName.contains(q)) return true;

      // Check keywords/aliases
      final keywords = c['keywords'] as List<String>?;
      if (keywords != null) {
        for (final keyword in keywords) {
          final kwLower = keyword.toLowerCase();
          if (kwLower.contains(q) || q.contains(kwLower)) {
            return true;
          }
        }
      }
      return false;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: context.textSub.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No calculators found'.tr,
                style: TextStyle(color: context.textSub, fontSize: 16)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: filtered.map((item) {
          return SizedBox(
            width: 80,
            child: CalculatorCard(
              label: (item['label'] as String).tr,
              icon: item['icon'] as IconData,
              gradientColors: item['colors'] as List<Color>,
              onTap: () {
                close(context, '');
                onNavigate(item['screen'] as Widget, showAd: item['showAd'] as bool? ?? true);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
