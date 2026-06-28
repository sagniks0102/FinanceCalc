import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // ── Production Ad Unit IDs ───────────────────────────────────────────
  static const String _prodBannerAdUnitId =
      'ca-app-pub-5498464777813614/1122714869';

  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-5498464777813614/8187740101';

  // ── Google's Official Test Ad Unit IDs (used in debug/test builds) ──
  // These always serve ads immediately — no waiting required
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // ── Active IDs: auto-switch based on build mode ─────────────────────
  static String get bannerAdUnitId =>
      kReleaseMode ? _prodBannerAdUnitId : _testBannerAdUnitId;

  static String get interstitialAdUnitId =>
      kReleaseMode ? _prodInterstitialAdUnitId : _testInterstitialAdUnitId;

  // ── Load Interstitial ────────────────────────────────────────────────
  /// Loads an interstitial ad and calls [onLoaded] when ready.
  /// Calls [onLoaded] with null on failure (graceful degradation).
  static void loadInterstitial({
    required void Function(InterstitialAd? ad) onLoaded,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => onLoaded(ad),
        onAdFailedToLoad: (error) {
          debugPrint('AdHelper: Interstitial failed to load — ${error.message}');
          onLoaded(null);
        },
      ),
    );
  }
}
