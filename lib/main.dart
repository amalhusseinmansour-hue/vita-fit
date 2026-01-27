import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/role_router_screen.dart';
import 'screens/trainer_signup_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'services/hive_storage_service.dart';
import 'services/toast_service.dart';
import 'services/firebase_service.dart';
import 'services/screen_security_service.dart';
import 'localization/app_localizations.dart';

void main() async {
  // MUST be first line
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase with error handling
  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue even if Firebase fails
  }

  // Enable screen security (prevent screenshots) with error handling
  try {
    await ScreenSecurityService.enableSecurity();
  } catch (e) {
    debugPrint('Screen security error: $e');
    // Continue even if screen security fails
  }

  // Initialize Hive storage with error handling
  try {
    await HiveStorageService.init();
  } catch (e) {
    debugPrint('Hive initialization error: $e');
    // Continue even if Hive fails
  }

  // Set custom error widget (production-safe)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Color(0xFFFF69B4), size: 48),
            SizedBox(height: 16),
            Text(
              'حدث خطأ غير متوقع',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  };

  // Run the app
  runApp(const VitaFitApp());
}

class VitaFitApp extends StatefulWidget {
  const VitaFitApp({super.key});

  @override
  State<VitaFitApp> createState() => _VitaFitAppState();
}

class _VitaFitAppState extends State<VitaFitApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    ToastService.init(_messengerKey);
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
              '/trainer-signup': (context) => const TrainerSignupScreen(),
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
