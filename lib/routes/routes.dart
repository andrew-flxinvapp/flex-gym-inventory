import 'package:flutter/material.dart';
import '../src/screens/splash.dart';
import '../src/screens/component_gallery.dart';
import '../src/screens/dashboard.dart';
import '../src/screens/wishlist.dart';
import '../src/screens/add_gym.dart';
import '../src/screens/gym_detail.dart';
import '../src/screens/edit_gym.dart';
import '../src/screens/add_equipment.dart';
import '../src/screens/equipment_detail.dart';
import '../src/screens/wishlist_detail.dart';
import '../src/screens/add_wishlist.dart';
import '../src/screens/edit_wishlist.dart';
import '../src/screens/edit_equipment.dart';
import '../src/screens/settings.dart';
import '../src/screens/signup.dart';
import '../src/screens/login.dart';
import '../src/screens/app_details.dart';
import '../src/screens/verify_email.dart';
import '../src/screens/opt_biometrics.dart';
import '../src/screens/opt_notifications.dart';
import '../src/screens/welcome.dart';
import '../src/screens/onboarding_upgrade.dart';
import '../src/screens/onboarding_complete.dart';
import '../src/screens/support.dart';
import '../src/screens/feedback.dart';

// Add other imports as needed

// Route name constants
class AppRoutes {
  static const String splash = '/';
  // Navigation routes
  static const String dashboard = '/dashboard';
  static const String componentGallery = '/component-gallery';
  static const String wishlist = '/wishlist';
  static const String settings = '/settings';
  // Gym routes
  static const String addGym = '/add-gym';
  static const String gymDetail = '/gym-detail';
  static const String editGym = '/edit-gym';
  // Equipment routes
  static const String addEquipment = '/add-equipment';
  static const String editEquipment = '/edit-equipment';
  static const String equipmentDetail = '/equipment-detail';
  // Wishlist routes
  static const String wishlistDetail = '/wishlist-detail';
  static const String addWishlist = '/add-wishlist';
  static const String editWishlist = '/edit-wishlist';
  // Auth routes
  static const String signup = '/signup';
  static const String login = '/login';
  static const String verifiyEmail = '/verify-email';
  static const String optBiometrics = '/opt-biometrics';
  static const String optNotifications = '/opt-notifications';
  static const String welcome = '/welcome';
  static const String complete = '/complete';
  static const String onboardingUpgrade = '/onboarding-upgrade';
  // Settings routes
  static const String appDetails = '/app-details';
  static const String support = '/support';
  static const String feedback = '/feedback';

  // Add more as needed
}

// Route map for MaterialApp
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  // Navigation routes
  AppRoutes.dashboard: (context) => const DashboardScreen(),
  AppRoutes.componentGallery: (context) => const ComponentGallery(),
  AppRoutes.wishlist: (context) => const WishlistScreen(),
  AppRoutes.settings: (context) => const SettingsScreen(),
  // Gym routes
  AppRoutes.addGym: (context) => const AddGymScreen(),
  AppRoutes.gymDetail: (context) => const GymDetailScreen(),
  AppRoutes.editGym: (context) => const EditGymScreen(),
  // Equipment routes
  AppRoutes.addEquipment: (context) => const AddEquipmentScreen(),
  AppRoutes.editEquipment: (context) => const EditEquipmentScreen(),
  AppRoutes.equipmentDetail: (context) => const EquipmentDetailScreen(),
  // Wishlist routes
  AppRoutes.addWishlist: (context) => const AddWishlistScreen(),
  AppRoutes.editWishlist: (context) => const EditWishlistScreen(),
  AppRoutes.wishlistDetail: (context) => const WishlistDetailScreen(),
  // Auth routes
  AppRoutes.signup: (context) => const SignupScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.verifiyEmail: (context) => const VerifyEmailScreen(),
  AppRoutes.optBiometrics: (context) => const OptBiometricsScreen(),
  AppRoutes.optNotifications: (context) => const OptNotificationsScreen(),
  AppRoutes.welcome: (context) => const WelcomeScreen(),
  AppRoutes.complete: (context) => const OnboardingCompleteScreen(),
  AppRoutes.onboardingUpgrade: (context) => const OnboardingUpgradeScreen(),
  // Settings routes
  AppRoutes.appDetails: (context) => const AppDetailsScreen(),
  AppRoutes.support: (context) => const SupportScreen(),
  AppRoutes.feedback: (context) => const FeedbackScreen(),

  // Add more as needed
};