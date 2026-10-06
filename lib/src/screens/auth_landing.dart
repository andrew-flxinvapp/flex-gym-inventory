import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../routes/routes.dart';
import '../widgets/buttons/auth_button.dart';
import '../widgets/layouts/app_screen.dart';

class AuthLanding extends StatelessWidget {
  const AuthLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AppScreen(
        safeArea: false,
        lightSystemUi: true,
        backgroundColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/images/auth_land_bg.png',
              fit: BoxFit.cover,
            ),
            // Splash-screen gradient layered over the image
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.9, -0.62),
                  radius: 1.6,
                  focal: Alignment(0.9, -0.7),
                  focalRadius: 0.001,
                  colors: [
                    Color(0x991F4F66),
                    Color(0xB3023246),
                    Color(0xD9010D1B),
                    Color(0xF2000000),
                  ],
                  stops: [0.0, 0.3, 0.8, 1.0],
                  transform: GradientRotation(0.25),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: SvgPicture.asset(
                      'lib/assets/images/fgi_logo_white.svg',
                      width: 320,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Your gym...Organized.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(color: AppTheme.lightBackground),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Track your equipment, manage your gyms, and keep everything in one place.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.lightBackground),
                        ),
                        const SizedBox(height: 80),
                        Row(
                          children: [
                            Expanded(
                              child: SmallAuthButton(
                                label: 'Log In',
                                variant: SmallAuthButtonVariant.outlined,
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.login),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SmallAuthButton(
                                label: 'Sign Up',
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.signup),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
