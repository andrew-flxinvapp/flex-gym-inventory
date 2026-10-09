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
// import 'package:flex_gym_inventory/src/data/repositories/auth_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LogHandler.setupLogging();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Isar via the central service so repositories can use IsarService.isar
  await IsarService.openIsar();

  // Initialize deeplink handling and register a simple handler that
  // navigates to the verify-email screen and forwards parsed params.
  DeeplinkService.instance.registerHandler((uri, params) async {
    LogHandler.info('Deeplink', 'Deeplink received: $uri params: $params');
    try {
      // If the link contains Supabase auth tokens (fragment) or an auth code
      // (query param `code`), ask the Supabase client to parse & restore the
      // session. `getSessionFromUrl` will extract tokens and set the session.
      final hasToken =
          params.containsKey('access_token') ||
          params.containsKey('refresh_token');
      final hasCode = uri.queryParameters.containsKey('code');

      // Email templates that use {{ .TokenHash }} (common for the "Confirm
      // signup" email sent to new users) deliver token_hash + type instead of
      // a code, so verify those directly.
      final tokenHash = params['token_hash'];
      if (tokenHash != null && tokenHash.isNotEmpty) {
        try {
          final type = switch (params['type']) {
            'signup' => OtpType.signup,
            'invite' => OtpType.invite,
            'recovery' => OtpType.recovery,
            'email_change' => OtpType.emailChange,
            'email' => OtpType.email,
            _ => OtpType.magiclink,
          };
          await Supabase.instance.client.auth.verifyOTP(
            tokenHash: tokenHash,
            type: type,
          );
        } catch (e, st) {
          LogHandler.warning('Deeplink', 'verifyOTP failed: $e', e, st);
        }
      }

      if (hasToken || hasCode || tokenHash != null) {
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (e, st) {
          // Log and fall through to show verify screen
          LogHandler.warning('Deeplink', 'getSessionFromUrl failed: $e', e, st);
        }

        var user = Supabase.instance.client.auth.currentUser;
        // supabase_flutter also consumes the link on its own, so our call can
        // fail (code already used) while the session is still being set.
        // Wait briefly for it instead of falling through to verify-email.
        if (user == null) {
          try {
            await Supabase.instance.client.auth.onAuthStateChange
                .firstWhere((e) => e.session != null)
                .timeout(const Duration(seconds: 5));
          } catch (_) {}
          user = Supabase.instance.client.auth.currentUser;
        }
        if (user != null) {
          // Successful sign-in — navigate into the app (startup router will
          // decide whether to show onboarding or main flow).
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.startupRouter,
            (_) => false,
          );
          return;
        }
      }

      // No tokens/code or session restore failed — show verify email, but
      // don't stack a second copy if it's already the current screen.
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
    } catch (e) {
      LogHandler.error('Deeplink', 'Error handling deeplink: $e', e, null);
      try {
        navigatorKey.currentState?.pushNamed(
          AppRoutes.verifyEmail,
          arguments: params,
        );
      } catch (_) {}
    }
  });
  await DeeplinkService.instance.init();

  // Configure RevenueCat if an API key is present in .env
  try {
    final rcKey = dotenv.env['REVENUECAT_API_KEY'];
    if (rcKey != null && rcKey.isNotEmpty) {
      final rc = RevenueCatService();
      final enableDebug = dotenv.env['REVENUECAT_DEBUG'] == 'true';
      await rc.configure(
        apiKey: rcKey,
        appUserId: Supabase.instance.client.auth.currentUser?.id,
        enableDebugLogs: enableDebug,
      );
      LogHandler.info('Main', 'RevenueCat configured');
    } else {
      LogHandler.info('Main', 'REVENUECAT_API_KEY not set; skipping RevenueCat configuration');
    }
  } catch (e, st) {
    LogHandler.warning('Main', 'RevenueCat configuration failed', e, st);
  }

  runApp(ProviderScope(child: MyApp(isar: IsarService.isar)));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flex Gym Inventory',
      navigatorKey: navigatorKey,
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
