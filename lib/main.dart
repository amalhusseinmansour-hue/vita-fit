import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/role_router_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';
import 'services/hive_storage_service.dart';
import 'localization/app_localizations.dart';

void main() async {
  // Wrap the entire app in a zone to catch errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Hive Storage (iPad compatible - replaces SharedPreferences)
    try {
      await HiveStorageService.init();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }

    // Initialize Local Storage for offline support
    try {
      await LocalStorageService.init();
    } catch (e) {
      debugPrint('Error initializing LocalStorage: $e');
    }

    // Initialize Firebase (includes Crashlytics, Analytics, and Notifications)
    try {
      await FirebaseService.initialize();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }

    runApp(const FitHerApp());
  }, (error, stack) {
    // Log uncaught errors to Crashlytics (safely)
    try {
      FirebaseService.logError(error, stack, reason: 'Uncaught error in main zone');
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  });
}

class FitHerApp extends StatelessWidget {
  const FitHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'VitaFit',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const SplashScreen(),

            // Routes
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/home': (context) => const RoleRouterScreen(),
            },

            // Localization support
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,

            // Builder for text direction
            builder: (context, child) {
              return Directionality(
                textDirection: languageProvider.textDirection,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
