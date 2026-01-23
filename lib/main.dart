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

void main() {
  // Use runZonedGuarded to catch all errors
  runZonedGuarded<void>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize services with proper error handling
    await _initializeServices();

    runApp(const FitHerApp());
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

Future<void> _initializeServices() async {
  // Initialize Hive Storage first (most critical for app to work)
  try {
    await HiveStorageService.init();
    debugPrint('Hive initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Hive: $e');
  }

  // Initialize Local Storage for offline support
  try {
    await LocalStorageService.init();
    debugPrint('LocalStorage initialized successfully');
  } catch (e) {
    debugPrint('Error initializing LocalStorage: $e');
  }

  // Initialize Firebase only if not on simulator/having issues
  // Firebase is optional - app should work without it
  try {
    await FirebaseService.initialize();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase (non-fatal): $e');
  }

  // Initialize Connectivity Service
  try {
    await ConnectivityService.init();
    debugPrint('Connectivity initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Connectivity: $e');
  }
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
      debugPrint('Error disposing ConnectivityService: $e');
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
