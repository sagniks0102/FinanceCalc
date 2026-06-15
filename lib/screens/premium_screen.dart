import 'package:flutter/material.dart';
import '../utils/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/iap_service.dart';

/// Beautiful paywall screen for the "Remove All Ads" one-time IAP.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  bool _isBuying = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────

  Future<void> _buy() async {
    if (_isBuying) return;
    setState(() => _isBuying = true);
    try {
      await IAPService.instance.buy();
    } catch (e) {
      if (mounted) {
        _snack('Purchase failed. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  Future<void> _restore() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);
    try {
      await IAPService.instance.restorePurchases();
      if (mounted) {
        final isPremium = AppSettings.instance.isPremium.value;
        if (isPremium) {
          _snack('Purchase restored! Ads removed ✓');
        } else {
          _snack('No previous purchase found.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) _snack('Restore failed. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── UI ────────────────────────────────────────────────────────────────

  static const _features = [
    (Icons.block_rounded,       'No Banner Ads',       'Banner ads at the bottom are removed forever'),
    (Icons.skip_next_rounded,   'No Interstitial Ads', 'No full-screen ads when opening calculators'),
    (Icons.all_inclusive_rounded,'All Calculators Free','Use every calculator without interruptions'),
    (Icons.favorite_rounded,    'Support the Dev',     'Help keep this app free and updated'),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.instance.isPremium,
      builder: (_, isPremium, __) {
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
            title: Text('Go Premium',
                style: TextStyle(color: context.text, fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
          body: isPremium ? _buildAlreadyPremium() : _buildPaywall(),
        );
      },
    );
  }

  // ── Already Premium state ─────────────────────────────────────────────

  Widget _buildAlreadyPremium() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 100, height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 54),
        ),
        const SizedBox(height: 24),
        Text('You\'re Premium! 🎉',
            style: TextStyle(color: context.text, fontSize: 24,
                fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text('All ads have been removed.\nThank you for supporting this app!',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSub, fontSize: 15, height: 1.6)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.maybePop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Back to Dashboard',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    ),
  );

  // ── Paywall state ─────────────────────────────────────────────────────

  Widget _buildPaywall() {
    final price = IAPService.instance.productPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(children: [
        // ── Hero badge ────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            final shimmer = _shimmerCtrl.value;
            return Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: const [
                    Color(0xFF1D4ED8),
                    Color(0xFF7C3AED),
                    Color(0xFF3B82F6),
                    Color(0xFF1D4ED8),
                  ],
                  startAngle: shimmer * 6.28,
                  endAngle: shimmer * 6.28 + 6.28,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                    blurRadius: 30, spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 60),
            );
          },
        ),
        const SizedBox(height: 20),

        Text('Remove All Ads',
            style: TextStyle(color: context.text, fontSize: 26,
                fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('One-time purchase — no subscriptions, ever.',
            style: TextStyle(color: context.textSub, fontSize: 13)),

        const SizedBox(height: 28),

        // ── Feature list ──────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border),
          ),
          child: Column(
            children: _features.asMap().entries.map((e) {
              final i = e.key;
              final f = e.value;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(f.$1, color: const Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$2,
                            style: TextStyle(color: context.text,
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(f.$3,
                            style: TextStyle(color: context.textSub,
                                fontSize: 12, height: 1.4)),
                      ],
                    )),
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 20),
                  ]),
                ),
                if (i < _features.length - 1)
                  Divider(height: 1, color: context.border, indent: 70),
              ]);
            }).toList(),
          ),
        ),

        const SizedBox(height: 28),

        // ── Price pill ────────────────────────────────────────────────
        if (price != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            ),
            child: Text(
              '$price — One-time',
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── CTA button ────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isBuying ? null : _buy,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF3B82F6).withValues(alpha: 0.5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _isBuying
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.workspace_premium_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      price != null
                          ? 'Go Premium — $price'
                          : 'Go Premium',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ]),
          ),
        ),

        const SizedBox(height: 12),

        // ── Restore button ────────────────────────────────────────────
        TextButton(
          onPressed: _isRestoring ? null : _restore,
          child: _isRestoring
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Restore Purchase',
                  style: TextStyle(
                      color: context.textSub, fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: context.textSub)),
        ),

        const SizedBox(height: 8),
        Text(
          'Purchases are managed by Google Play.\n'
          'After purchase, ads are removed immediately.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.textSub, fontSize: 11, height: 1.5),
        ),
      ]),
    );
  }
}
