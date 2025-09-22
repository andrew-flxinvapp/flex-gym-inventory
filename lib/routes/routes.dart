import '../src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../src/screens/splash.dart';
import '../src/screens/component_gallery.dart';
//import '../src/screens/dashboard.dart';
//import '../src/screens/wishlist.dart';
import '../src/screens/add_gym.dart';
import '../src/screens/gym_detail.dart';
import '../src/screens/edit_gym.dart';
import '../src/screens/add_equipment.dart';
import '../src/screens/equipment_detail.dart';
import '../src/screens/wishlist_detail.dart';
import '../src/screens/add_wishlist.dart';
import '../src/screens/edit_wishlist.dart';
import '../src/screens/edit_equipment.dart';
//import '../src/screens/settings.dart';
import '../src/screens/signup.dart';
import '../src/screens/login.dart';
import '../src/screens/app_details.dart';
import '../src/screens/verify_email.dart';
import '../src/screens/opt_notifications.dart';
import '../src/screens/welcome.dart';
import '../src/screens/onboarding_upgrade.dart';
import '../src/screens/onboarding_complete.dart';
import '../src/screens/support.dart';
import '../src/screens/feedback.dart';
import '../src/screens/account.dart';
import '../src/screens/upgrade_account.dart';
import '../src/screens/delete_account.dart';
import '../src/screens/notifications.dart';
import '../src/screens/onboarding_feature_one.dart';
import '../src/screens/onboarding_feature_two.dart';
import '../src/screens/social_proof.dart';

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
  static const String optNotifications = '/opt-notifications';
  static const String onboardingFeatureOne = '/onboarding-feature-one';
  static const String onboardingFeatureTwo = '/onboarding-feature-two';
  static const String welcome = '/welcome';
  static const String socialProof = '/social-proof';
  static const String onboardingUpgrade = '/onboarding-upgrade';
  static const String complete = '/complete';
  // Settings routes
  static const String appDetails = '/app-details';
  static const String support = '/support';
  static const String feedback = '/feedback';
  static const String account = '/account';
  static const String upgradeAccount = '/upgrade-account';
  static const String deleteAccount = '/delete-account';
  static const String notifications = '/notifications';

  // Add more as needed
}

// Route map for MaterialApp
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  // Navigation routes
  AppRoutes.dashboard: (context) => const HomeScreen(initialIndex: 0),
  AppRoutes.componentGallery: (context) => const ComponentGallery(),
  AppRoutes.wishlist: (context) => const HomeScreen(initialIndex: 1),
  AppRoutes.settings: (context) => const HomeScreen(initialIndex: 2),
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
  AppRoutes.optNotifications: (context) => const OptNotificationsScreen(),
  AppRoutes.onboardingFeatureOne: (context) => const OnboardingFeatureOneScreen(),
  AppRoutes.onboardingFeatureTwo: (context) => const OnboardingFeatureTwoScreen(),
  AppRoutes.welcome: (context) => const WelcomeScreen(),
  AppRoutes.socialProof: (context) => const SocialProofScreen(),  
  AppRoutes.onboardingUpgrade: (context) => const OnboardingUpgradeScreen(),
  AppRoutes.complete: (context) => const OnboardingCompleteScreen(),

  // Settings routes
  AppRoutes.appDetails: (context) => const AppDetailsScreen(),
  AppRoutes.support: (context) => const SupportScreen(),
  AppRoutes.feedback: (context) => const FeedbackScreen(),
  AppRoutes.account: (context) => const AccountScreen(),
  AppRoutes.upgradeAccount: (context) => const UpgradeAccountScreen(),
  AppRoutes.deleteAccount: (context) => const DeleteAccountScreen(),
  AppRoutes.notifications: (context) => const NotificationsScreen(),

  // Add more as needed
};