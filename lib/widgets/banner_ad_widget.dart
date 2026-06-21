import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';
import '../utils/app_settings.dart';
import '../utils/remote_config_service.dart';

/// Adaptive banner ad widget — fills the full screen width.
/// Height is determined automatically by the SDK based on screen size.
/// Shows nothing while loading or on failure.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load once — skip if already loaded
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    // Get the screen width in logical pixels, capped for tablets
    final width = MediaQuery.sizeOf(context).width.truncate();

    // Request adaptive banner size for current orientation
    final adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (adSize == null) {
      debugPrint('BannerAdWidget: Failed to get adaptive ad size');
      return;
    }

    if (!mounted) return;

    final banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _adSize = adSize;
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: Failed to load — ${error.message}');
          ad.dispose();
        },
      ),
    );

    await banner.load();
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.instance.isPremium,
      builder: (_, isPremium, __) {
        // Premium users or if remote config disabled: hide the banner completely
        if (isPremium || !RemoteConfigService.instance.showBannerAd) {
          return const SizedBox.shrink();
        }

        if (!_isLoaded || _bannerAd == null || _adSize == null) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          child: SizedBox(
            width: _adSize!.width.toDouble(),
            height: _adSize!.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      },
    );
  }
}
