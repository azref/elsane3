import 'package:flutter/foundation.dart'; // Added for defaultTargetPlatform
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdsService {
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs (replace with your actual IDs)
  static const String _prodBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static bool _isTestMode = true; // Set to false for production

  // Get Ad Unit IDs based on platform and mode
  static String get bannerAdUnitId {
    if (_isTestMode) return _testBannerAdUnitId;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _prodBannerAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS ID
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (_isTestMode) return _testInterstitialAdUnitId;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _prodInterstitialAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS ID
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (_isTestMode) return _testRewardedAdUnitId;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _prodRewardedAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS ID
    }
    return '';
  }

  // Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Create Banner Ad
  static BannerAd createBannerAd({
    required AdSize adSize,
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: listener,
    );
  }

  // Load Interstitial Ad
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
    
    return interstitialAd;
  }

  // Load Rewarded Ad
  static Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;
    
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
    
    return rewardedAd;
  }

  // Show Interstitial Ad with callback
  static void showInterstitialAd(InterstitialAd ad, {VoidCallback? onAdClosed}) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (onAdClosed != null) onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        print('InterstitialAd failed to show: $error');
        if (onAdClosed != null) onAdClosed();
      },
    );
    
    ad.show();
  }

  // Show Rewarded Ad with reward callback
  static void showRewardedAd(
    RewardedAd ad, {
    required Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (onAdClosed != null) onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        print('RewardedAd failed to show: $error');
        if (onAdClosed != null) onAdClosed();
      },
    );
    
    ad.show(onUserEarnedReward: onUserEarnedReward);
  }
}


