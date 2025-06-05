import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';

/// DashboardScreen
/// 
/// This screen provides an overview of gym equipment breakdowns at a glance.
/// Follows MVVM architecture. Connect to a ViewModel for state management.
/// 
/// TODO: Connect to DashboardViewModel and implement Riverpod for state management.
/// TODO: Add responsive layout using size_config.dart.
/// TODO: Add modular widgets for dashboard cards and summaries.

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const TopAppBar(
  title: 'Dashboard'
  ),
      body: const Center(
        child: Text(
          'Dashboard content goes here.',
          style: TextStyle(
            color: AppTheme.lightTextPrimary,
            fontSize: 18,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}