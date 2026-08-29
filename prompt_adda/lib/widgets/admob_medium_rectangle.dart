import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobMediumRectangle extends StatefulWidget {
  const AdMobMediumRectangle({super.key});

  @override
  State<AdMobMediumRectangle> createState() => _AdMobMediumRectangleState();
}

class _AdMobMediumRectangleState extends State<AdMobMediumRectangle> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static const bool _useProductionAds = bool.fromEnvironment(
    'USE_PRODUCTION_ADS',
    defaultValue: false,
  );

  // Official Google test banner Ad Unit ID.
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // Prompt Details production 300x250 Ad Unit ID.
  static const String _productionAdUnitId =
      'ca-app-pub-2747927305898631/6395621565';

  String get _adUnitId =>
      _useProductionAds ? _productionAdUnitId : _testAdUnitId;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final canRequestAds = await ConsentInformation.instance.canRequestAds();

    if (!mounted) return;

    if (!canRequestAds) {
      debugPrint('Prompt Details AdMob ad skipped: consent not ready.');
      return;
    }

    final ad = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
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
            'Prompt Details 300x250 ad failed: '
            'code=${error.code}, '
            'domain=${error.domain}, '
            'message=${error.message}',
          );

          ad.dispose();
        },
      ),
    );

    await ad.load();
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

    return Center(
      child: SizedBox(width: 300, height: 250, child: AdWidget(ad: _bannerAd!)),
    );
  }
}
