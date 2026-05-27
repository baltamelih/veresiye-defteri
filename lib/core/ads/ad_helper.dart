import 'dart:io';

class AdHelper {
  AdHelper._();

  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static String get bannerAdUnitId {
    if (useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-7415512901536849/4437314319';
      if (Platform.isIOS) return 'ca-app-pub-7415512901536849/1396521922';
    }

    if (Platform.isAndroid) return 'REAL_ANDROID_BANNER_AD_UNIT_ID';
    if (Platform.isIOS) return 'REAL_IOS_BANNER_AD_UNIT_ID';

    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-7415512901536849/2709603593';
      if (Platform.isIOS) return 'ca-app-pub-7415512901536849/1811150977';
    }

    if (Platform.isAndroid) return 'REAL_ANDROID_INTERSTITIAL_AD_UNIT_ID';
    if (Platform.isIOS) return 'REAL_IOS_INTERSTITIAL_AD_UNIT_ID';

    throw UnsupportedError('Unsupported platform');
  }
}