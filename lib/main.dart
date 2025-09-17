import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
//import 'src/screens/splash.dart';
import 'config/size_config.dart';
import 'routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'Flex Gym Inventory',
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