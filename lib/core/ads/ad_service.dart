import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';

class AdService {
  AdService._();

  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;
  static int _actionCounter = 0;

  static const int _showEveryActionCount = 3;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await loadInterstitial();
  }

  static Future<void> loadInterstitial() async {
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  static Future<void> registerActionAndMaybeShowAd() async {
    _actionCounter++;

    if (_actionCounter < _showEveryActionCount) {
      await loadInterstitial();
      return;
    }

    _actionCounter = 0;
    await showInterstitial();
  }

  static Future<void> showInterstitial() async {
    final ad = _interstitialAd;

    if (ad == null) {
      await loadInterstitial();
      return;
    }

    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadInterstitial();
      },
    );

    await ad.show();
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoading = false;
    _actionCounter = 0;
  }
}