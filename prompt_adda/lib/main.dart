import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification: ${message.messageId}');
}

Future<void> _setupAdConsent() async {
  final completer = Completer<void>();

  final params = ConsentRequestParameters();
  runApp(const PromptAddaApp());

  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () {
      ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
        if (formError != null) {
          debugPrint(
            'UMP consent form error: '
            '${formError.errorCode} - ${formError.message}',
          );
        }

        final canRequestAds = await ConsentInformation.instance.canRequestAds();

        if (canRequestAds) {
          await MobileAds.instance.initialize();
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      });
    },
    (FormError error) async {
      debugPrint(
        'UMP consent update error: '
        '${error.errorCode} - ${error.message}',
      );

      // Previous valid consent may still allow ads.
      final canRequestAds = await ConsentInformation.instance.canRequestAds();

      if (canRequestAds) {
        await MobileAds.instance.initialize();
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    },
  );

  await completer.future;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AuthService.startUserTracking();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  await ThemeService.initialize();

  runApp(const PromptAddaApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_setupAdConsent());
  });
}

class PromptAddaApp extends StatelessWidget {
  const PromptAddaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Prompt Adda',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
