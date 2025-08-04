//import 'package:flex_gym_inventory/src/screens/app_details.dart';
// import 'package:flex_gym_inventory/src/screens/login.dart';
// import 'package:flex_gym_inventory/src/screens/component_gallery.dart';
import 'package:flex_gym_inventory/src/screens/dashboard.dart';
// import 'package:flex_gym_inventory/src/screens/gym_detail.dart';
// import 'package:flex_gym_inventory/src/screens/verify_email.dart';
// import 'package:flex_gym_inventory/src/screens/opt_biometrics.dart';
// import 'package:flex_gym_inventory/src/screens/onboarding_upgrade.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 1),
            Center(
              child: SvgPicture.asset(
                'lib/assets/images/fgi_logo_white.svg',
                height: 81.4,
                width: 320,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(
                'Version 1.0.0',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.darkTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}