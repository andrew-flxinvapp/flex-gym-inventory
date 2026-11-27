import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
//import 'src/screens/splash.dart';
import 'config/size_config.dart';
import 'routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/deeplink_service.dart';
import 'package:isar/isar.dart';
import 'service/isar_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';
import 'service/revenuecat_service.dart';
import 'service/auth_callback_handler.dart';
import 'service/auth_navigation_coordinator.dart';

// import 'package:flex_gym_inventory/src/data/repositories/auth_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LogHandler.setupLogging();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;
  final authNavigation = AuthNavigationCoordinator(
    navigatorKey: navigatorKey,
    messengerKey: messengerKey,
    currentUserId: () => supabase.auth.currentUser?.id,
    authChanges: supabase.auth.onAuthStateChange,
  );

  // Initialize Isar via the central service so repositories can use IsarService.isar
  await IsarService.openIsar();

  final callbackHandler = AuthCallbackHandler(
    verifyToken: (tokenHash, type) async {
      await supabase.auth.verifyOTP(tokenHash: tokenHash, type: type);
    },
    onAuthenticationError: authNavigation.reportAuthenticationError,
    onOtherLink: (params) async {
      var alreadyOnVerify = false;
      navigatorKey.currentState?.popUntil((route) {
        alreadyOnVerify = route.settings.name == AppRoutes.verifyEmail;
        return true;
      });
      if (alreadyOnVerify) return;
      navigatorKey.currentState?.pushNamed(
        AppRoutes.verifyEmail,
        arguments: params,
      );
    },
  );
  DeeplinkService.instance.registerHandler(callbackHandler.handle);
  await DeeplinkService.instance.init();

  final revenueCat = RevenueCatService.instance;
  revenueCat.startIdentitySynchronization(
    authUserIds: supabase.auth.onAuthStateChange.map(
      (event) => event.session?.user.id,
    ),
    currentUserId: () => supabase.auth.currentUser?.id,
  );

  runApp(
    ProviderScope(
      child: MyApp(isar: IsarService.isar, authNavigation: authNavigation),
    ),
  );

  revenueCat.startConfiguration(
    apiKey: dotenv.env['REVENUECAT_API_KEY'] ?? '',
    appUserId: supabase.auth.currentUser?.id,
  );
}

class MyApp extends StatelessWidget {
  final Isar isar;
  final AuthNavigationCoordinator authNavigation;
  const MyApp({super.key, required this.isar, required this.authNavigation});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flex Gym Inventory',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      navigatorObservers: [authNavigation],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      // Use appRoutes for named routes lookup, but override transitions with onGenerateRoute
      routes: appRoutes,
      onGenerateRoute: (settings) {
        final builder = appRoutes[settings.name];
        if (builder != null) {
          return PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => builder(context),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            settings: settings,
          );
        }
        // Fallback to default if route not found
        return null;
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flex Gym Inventory')),
      body: const Center(child: Text('Welcome to Flex Gym Inventory!')),
    );
  }
}
