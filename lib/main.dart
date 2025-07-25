import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
//import 'src/screens/splash.dart';
import 'config/size_config.dart';
import 'routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ihfwdlyewavkqxuqhthu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImloZndkbHlld2F2a3F4dXFodGh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTQzMzAsImV4cCI6MjA2OTAzMDMzMH0.PSU08Fhf4mu29wluO7x5lQSgC1YZgTMWkc4lMhjgaJ4',
  );
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