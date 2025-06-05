import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'src/screens/splash.dart';
import 'config/size_config.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../enum/app_enums.dart';
import '../src/models/gym_model.dart';
import '../src/models/equipment_model.dart';
import '../src/models/upgrades_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GymAdapter());
  Hive.registerAdapter(EquipmentAdapter());
  Hive.registerAdapter(UpgradesAdapter());
  Hive.registerAdapter(UpgradePriorityAdapter());
  Hive.registerAdapter(EquipmentCategoryAdapter());
  Hive.registerAdapter(TrainingStyleAdapter());
  Hive.registerAdapter(EquipmentConditionAdapter());
  Hive.registerAdapter(FileTypeAdapter());
  Hive.registerAdapter(UpgradeTypeAdapter());
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
      home: const SplashScreen(),
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