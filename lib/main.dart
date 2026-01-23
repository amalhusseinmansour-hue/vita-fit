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
import 'services/connectivity_service.dart';
import 'services/toast_service.dart';
import 'localization/app_localizations.dart';

void main() async {
  // Wrap everything in try-catch to prevent any crash
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e) {
    debugPrint('Flutter binding error: $e');
  }

  // Set orientations (non-critical)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Orientation error: $e');
  }

  // Initialize Hive (critical for app state)
  try {
    await HiveStorageService.init();
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  // Run app
  runApp(const FitHerApp());

  // Initialize other services in background AFTER app starts
  _initServicesInBackground();
}

// Initialize non-critical services in background
void _initServicesInBackground() {
  Future.microtask(() async {
    try {
      await LocalStorageService.init();
    } catch (e) {
      debugPrint('LocalStorage error: $e');
    }

    // Firebase disabled temporarily for debugging iOS crash
    // try {
    //   await FirebaseService.initialize();
    // } catch (e) {
    //   debugPrint('Firebase error: $e');
    // }

    try {
      await ConnectivityService.init();
    } catch (e) {
      debugPrint('Connectivity error: $e');
    }
  });
}

class FitHerApp extends StatefulWidget {
  const FitHerApp({super.key});

  @override
  State<FitHerApp> createState() => _FitHerAppState();
}

class _FitHerAppState extends State<FitHerApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    ToastService.init(_messengerKey);
  }

  @override
  void dispose() {
    try {
      ConnectivityService.dispose();
    } catch (e) {
      debugPrint('Dispose error: $e');
    }
    super.dispose();
  }

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
            scaffoldMessengerKey: _messengerKey,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/home': (context) => const RoleRouterScreen(),
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,
            builder: (context, child) {
              return Directionality(
                textDirection: languageProvider.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
