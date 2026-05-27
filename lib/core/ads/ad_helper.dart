import 'dart:io';

class AdHelper {
  AdHelper._();

  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static String get bannerAdUnitId {
    if (useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    }

    if (Platform.isAndroid) return 'REAL_ANDROID_BANNER_AD_UNIT_ID';
    if (Platform.isIOS) return 'REAL_IOS_BANNER_AD_UNIT_ID';

    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    }

    if (Platform.isAndroid) return 'REAL_ANDROID_INTERSTITIAL_AD_UNIT_ID';
    if (Platform.isIOS) return 'REAL_IOS_INTERSTITIAL_AD_UNIT_ID';

    throw UnsupportedError('Unsupported platform');
  }
}