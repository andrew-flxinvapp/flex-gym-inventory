//import 'package:flex_gym_inventory/src/screens/dashboard.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../service/app_info_service.dart';
import '../../routes/routes.dart';
import '../../utilities/logging_handler.dart';
import 'startup_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.resolveRoute = resolveStartupRoute,
    this.minDuration = const Duration(milliseconds: 1500),
    this.checkTimeout = const Duration(seconds: 8),
    this.routes,
  });

  /// Startup destination check; injectable for tests.
  final Future<String> Function() resolveRoute;

  /// Minimum time the splash stays visible.
  final Duration minDuration;

  /// Maximum time to wait for [resolveRoute] before falling back.
  final Duration checkTimeout;

  /// Route table used to build the destination; defaults to [appRoutes].
  final Map<String, WidgetBuilder>? routes;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    // Kick off async retrieval of package info; don't await — allow splash to
    // continue showing while startup checks run.
    appInfoService.init();
    _start();
  }

  Future<void> _start() async {
    final check = _check();

    final results = await Future.wait<String?>([
      check,
      Future<String?>.delayed(widget.minDuration),
    ]);

    _goTo(results.first ?? AppRoutes.startupRouter);
  }

  Future<String> _check() async {
    try {
      return await widget.resolveRoute().timeout(widget.checkTimeout);
    } catch (e, st) {
      LogHandler.warning('Splash', 'Startup check failed: $e', e, st);
      // Fall back to the StartupRouter, which re-runs the same checks.
      return AppRoutes.startupRouter;
    }
  }

  void _goTo(String routeName) {
    if (!mounted || _navigated) return;
    _navigated = true;

    final builder = (widget.routes ?? appRoutes)[routeName];
    if (builder == null) {
      Navigator.of(context).pushReplacementNamed(routeName);
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: routeName),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, _) => builder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.9, -0.62),
            radius: 1.6,
            focal: Alignment(0.9, -0.7),
            focalRadius: 0.001,
            colors: [
              Color(0xFF1F4F66), // 0%
              Color(0xFF023246), // 28%
              Color(0xFF010D1B), // 64%
              Color(0xFF000000), // 100%
            ],
            stops: [0.0, 0.3, 0.8, 1.0],
            transform: GradientRotation(
              0.25,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 1),
              Center(
                // The spinner is overlaid below the logo so the logo keeps
                // its original position.
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/images/fgi_logo_white.svg',
                      height: 81.4,
                      width: 320,
                      fit: BoxFit.contain,
                    ),
                    const Positioned(
                      top: 81.4 + 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.darkSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: ValueListenableBuilder(
                  valueListenable: appInfoService.info,
                  builder: (context, pi, _) {
                    final display = pi != null
                        ? 'Version ${pi.version}${pi.buildNumber.isNotEmpty ? '+${pi.buildNumber}' : ''}'
                        : 'Version ${appInfoService.displayVersion}';

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          display,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        /*Text(
                          'ALPHA TEST',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.darkTextPrimary),
                        ),*/
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
