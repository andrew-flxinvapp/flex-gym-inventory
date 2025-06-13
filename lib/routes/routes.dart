import 'package:flutter/material.dart';
import '../src/screens/splash.dart';
import '../src/screens/dashboard.dart';
//import '../src/screens/upgrades_screen.dart';
//import '../src/screens/add_gym_screen.dart';
//import '../src/screens/add_equipment_screen.dart';
//import '../src/screens/settings_screen.dart';
import '../src/screens/signup.dart';
import '../src/screens/login.dart';
// Add other imports as needed

// Route name constants
class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String upgrades = '/upgrades';
  static const String addGym = '/add-gym';
  static const String addEquipment = '/add-equipment';
  static const String settings = '/settings';
  static const String signup = '/signup';
  static const String login = '/login';
  // Add more as needed
}

// Route map for MaterialApp
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  AppRoutes.dashboard: (context) => const DashboardScreen(),
  //AppRoutes.upgrades: (context) => const UpgradesScreen(),
  //AppRoutes.addGym: (context) => const AddGymScreen(),
  //AppRoutes.addEquipment: (context) => const AddEquipmentScreen(),
  //AppRoutes.settings: (context) => const SettingsScreen(),
  AppRoutes.signup: (context) => const SignupScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  // Add more as needed
};