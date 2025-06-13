import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
//import 'src/screens/splash.dart';
import 'config/size_config.dart';
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'Flex Gym Inventory',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: appRoutes,
      // Optionally: onGenerateRoute: yourRouteGenerator,
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