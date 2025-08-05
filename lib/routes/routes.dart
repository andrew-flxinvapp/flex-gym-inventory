import 'package:flutter/material.dart';
import '../src/screens/splash.dart';
import '../src/screens/component_gallery.dart';
import '../src/screens/dashboard.dart';
//import '../src/screens/wishlist_screen.dart';
import '../src/screens/add_gym.dart';
import '../src/screens/gym_detail.dart';
import '../src/screens/edit_gym.dart';
import '../src/screens/add_equipment.dart';
//import '../src/screens/settings_screen.dart';
import '../src/screens/signup.dart';
import '../src/screens/login.dart';
import '../src/screens/app_details.dart';
import '../src/screens/verify_email.dart';
import '../src/screens/opt_biometrics.dart';
import '../src/screens/opt_notifications.dart';
import '../src/screens/welcome.dart';
import '../src/screens/onboarding_upgrade.dart';
import '../src/screens/onboarding_complete.dart';

// Add other imports as needed

// Route name constants
class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String componentGallery = '/component-gallery';
  static const String upgrades = '/upgrades';
  static const String addGym = '/add-gym';
  static const String gymDetail = '/gym-detail';
  static const String editGym = '/edit-gym';
  static const String addEquipment = '/add-equipment';
  static const String settings = '/settings';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String appDetails = '/app-details';
  static const String verifiyEmail = '/verify-email';
  static const String optBiometrics = '/opt-biometrics';
  static const String optNotifications = '/opt-notifications';
  static const String welcome = '/welcome';
  static const String complete = '/complete';
  static const String onboardingUpgrade = '/onboarding-upgrade';
  // Add more as needed
}

// Route map for MaterialApp
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  AppRoutes.dashboard: (context) => const DashboardScreen(),
  AppRoutes.componentGallery: (context) => const ComponentGallery(),
  //AppRoutes.wishlist: (context) => const WishlistScreen(),
  AppRoutes.addGym: (context) => const AddGymScreen(),
  AppRoutes.gymDetail: (context) => const GymDetailScreen(),
  AppRoutes.editGym: (context) => const EditGymScreen(),
  AppRoutes.addEquipment: (context) => const AddEquipmentScreen(),
  //AppRoutes.settings: (context) => const SettingsScreen(),
  AppRoutes.signup: (context) => const SignupScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.appDetails: (context) => const AppDetailsScreen(),
  AppRoutes.verifiyEmail: (context) => const VerifyEmailScreen(),
  AppRoutes.optBiometrics: (context) => const OptBiometricsScreen(),
  AppRoutes.optNotifications: (context) => const OptNotificationsScreen(),
  AppRoutes.welcome: (context) => const WelcomeScreen(),
  AppRoutes.complete: (context) => const OnboardingCompleteScreen(),
  AppRoutes.onboardingUpgrade: (context) => const OnboardingUpgradeScreen(),
  // Add more as needed
};