import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../routes/routes.dart';


class StartupRouterScreen extends StatefulWidget {
  const StartupRouterScreen({super.key});

  @override
  State<StartupRouterScreen> createState() => _StartupRouterScreenState();
}

class _StartupRouterScreenState extends State<StartupRouterScreen> {

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    if (!mounted) return;

    if (session == null) {
      // No session → User not logged in → Go to Login / Sign Up screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    // Session exists → Remembered device / returning user → Straight to Dashboard
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    // This screen is basically invisible, just a tiny loading state.
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
