import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen_modern.dart';
import 'screens/smart_plan_screen.dart';
import 'screens/training_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/more_screen.dart';
import 'screens/role_router_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';
import 'localization/app_localizations.dart';

void main() async {
  // Wrap the entire app in a zone to catch errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // تعيين اتجاه واجهة المستخدم من اليمين إلى اليسار (RTL)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Local Storage for offline support
    await LocalStorageService.init();

    // Initialize Firebase (includes Crashlytics, Analytics, and Notifications)
    try {
      await FirebaseService.initialize();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }

    runApp(const FitHerApp());
  }, (error, stack) {
    // Log uncaught errors to Crashlytics
    FirebaseService.logError(error, stack, reason: 'Uncaught error in main zone');
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

            // دعم الترجمة واللغات
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SmartPlanScreen(),
    TrainingScreen(),
    NutritionScreen(),
    ShopScreen(),
    MoreScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.lightbulb_outline,
      label: 'خطتي الذكية',
    ),
    NavigationItem(
      icon: Icons.fitness_center,
      label: 'تدريبي',
    ),
    NavigationItem(
      icon: Icons.restaurant,
      label: 'تغذيتي',
    ),
    NavigationItem(
      icon: Icons.shopping_bag,
      label: 'متجري',
    ),
    NavigationItem(
      icon: Icons.menu,
      label: 'المزيد',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(
                color: AppTheme.border,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _navigationItems.length,
                  (index) => _buildNavItem(
                    _navigationItems[index],
                    index,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, int index) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 24,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? AppTheme.fontMedium
                      : AppTheme.fontRegular,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.label,
  });
}
