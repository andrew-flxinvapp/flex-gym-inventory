import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
//import 'src/screens/splash.dart';
import 'config/size_config.dart';
import 'routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/deeplink_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';
import 'package:flex_gym_inventory/src/utils/pending_metadata_store.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LogHandler.setupLogging();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [GymSchema,EquipmentSchema,WishlistSchema],
    directory: dir.path,
  );

  // Initialize deeplink handling and register a simple handler that
  // navigates to the verify-email screen and forwards parsed params.
  DeeplinkService.instance.registerHandler((uri, params) async {
    // ignore: avoid_print
    print('Deeplink received: $uri params: $params');
    try {
      // If the link contains Supabase auth tokens (fragment) or an auth code
      // (query param `code`), ask the Supabase client to parse & restore the
      // session. `getSessionFromUrl` will extract tokens and set the session.
      final hasToken = params.containsKey('access_token') || params.containsKey('refresh_token');
      final hasCode = uri.queryParameters.containsKey('code');

      if (hasToken || hasCode) {
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (e, st) {
          // Log and fall through to show verify screen
          // ignore: avoid_print
          print('Deeplink: getSessionFromUrl failed: $e\n$st');
        }

        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // If we have pending metadata saved during signup, attempt to
          // reconcile it to the authenticated user now that a session exists.
          try {
            final pending = await PendingMetadataStore.read();
            if (pending != null && pending.isNotEmpty) {
              await AuthRepository().updateUserMetadata(pending);
              await PendingMetadataStore.clear();
            }
          } catch (e) {
            // Don't block navigation on reconciliation failures – log and continue.
            // ignore: avoid_print
            print('Metadata reconciliation failed: $e');
          }

          // Successful sign-in — navigate into the app (startup router will
          // decide whether to show onboarding or main flow).
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.startupRouter,
            (_) => false,
          );
          return;
        }
      }

      // No tokens/code or session restore failed — navigate to verify email
      navigatorKey.currentState?.pushNamed(
        AppRoutes.verifiyEmail,
        arguments: params,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error handling deeplink: $e');
      try {
        navigatorKey.currentState?.pushNamed(AppRoutes.verifiyEmail, arguments: params);
      } catch (_) {}
    }
  });
  await DeeplinkService.instance.init();

  runApp(ProviderScope(child: MyApp(isar: isar)));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'Flex Gym Inventory',
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      // Use appRoutes for named routes lookup, but override transitions with onGenerateRoute
      routes: appRoutes,
      onGenerateRoute: (settings) {
        final builder = appRoutes[settings.name];
        if (builder != null) {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => builder(context),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
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
      appBar: AppBar(
        title: const Text('Flex Gym Inventory'),
      ),
      body: const Center(
        child: Text('Welcome to Flex Gym Inventory!'),
      ),
    );
  }
}