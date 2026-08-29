import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobTestBanner extends StatefulWidget {
  const AdMobTestBanner({super.key});

  @override
  State<AdMobTestBanner> createState() => _AdMobTestBannerState();
}

class _AdMobTestBannerState extends State<AdMobTestBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static const bool _useProductionAds = bool.fromEnvironment(
    'USE_PRODUCTION_ADS',
    defaultValue: false,
  );

  // Official Google test banner Ad Unit ID.
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Prompt Adda Home production banner Ad Unit ID.
  static const String _productionBannerAdUnitId =
      'ca-app-pub-2747927305898631/3632188432';

  String get _bannerAdUnitId =>
      _useProductionAds ? _productionBannerAdUnitId : _testBannerAdUnitId;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    final canRequestAds = await ConsentInformation.instance.canRequestAds();

    if (!mounted) return;

    if (!canRequestAds) {
      debugPrint('Home AdMob banner skipped: consent not ready.');
      return;
    }

    final bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'Home AdMob banner failed: '
            'code=${error.code}, '
            'domain=${error.domain}, '
            'message=${error.message}',
          );

          ad.dispose();
        },
      ),
    );

    await bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
