import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();

  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults(const {
        'show_banner_ad': true,
        'show_interstitial_ad': true,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfigService: Failed to initialize — $e');
    }
  }

  bool get showBannerAd => _remoteConfig.getBool('show_banner_ad');

  bool get showInterstitialAd => _remoteConfig.getBool('show_interstitial_ad');
}
