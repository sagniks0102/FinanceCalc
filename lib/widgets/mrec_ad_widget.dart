import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';
import '../utils/app_settings.dart';
import '../utils/remote_config_service.dart';

/// MREC (Medium Rectangle) banner ad widget — size 300x250.
class MrecAdWidget extends StatefulWidget {
  const MrecAdWidget({super.key});

  @override
  State<MrecAdWidget> createState() => _MrecAdWidgetState();
}

class _MrecAdWidgetState extends State<MrecAdWidget> {
  BannerAd? _mrecAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load once — skip if already loaded
    if (_mrecAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('MrecAdWidget: Failed to load — ${error.message}');
          ad.dispose();
        },
      ),
    );

    await ad.load();
    _mrecAd = ad;
  }

  @override
  void dispose() {
    _mrecAd?.dispose();
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

        if (!_isLoaded || _mrecAd == null) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 300,
          height: 250,
          margin: const EdgeInsets.symmetric(vertical: 8), // slightly less margin to look integrated
          alignment: Alignment.center,
          child: AdWidget(ad: _mrecAd!),
        );
      },
    );
  }
}
