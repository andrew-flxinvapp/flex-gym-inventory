import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';

class AppDetailsScreen extends StatelessWidget {
  const AppDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: TopAppBar(
  title: 'App Details',
  showBackArrow: true,
  onBack: () => Navigator.of(context).pop(),
  ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Info Section
                Text('App Info',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App Name',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                    fontWeight: FontWeight.bold,
                                  )),
                          const SizedBox(height: 2),
                          Text('Flex Gym Inventory',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                  )),
                          const SizedBox(height: 8),
                          Text('App Version',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                    fontWeight: FontWeight.bold,
                                  )),
                          const SizedBox(height: 2),
                          Text('Version 1.0.0',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                  )),
                          Text('Build 01',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                  )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Developer Info
                Text('Developer Info',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 4),
                Text('Developed by Flex Gym Inventory LLC',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        )),
                const SizedBox(height: 24),
                // Privacy Policy
                Text('Privacy Policy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('View Privacy Policy ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTextPrimary,
                            )),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement privacy policy navigation
                      },
                      child: Text('Here',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightSecondary,
                                decoration: TextDecoration.underline,
                              )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Terms & Conditions
                Text('Terms & Conditions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('View Terms & Conditions ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTextPrimary,
                            )),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement terms navigation
                      },
                      child: Text('Here',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightSecondary,
                                decoration: TextDecoration.underline,
                              )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Acknowledgements
                Text('Acknowledgements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 4),
                Text('Built with Flutter, Supabase, [other open source libraries]',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        )),
                const SizedBox(height: 32),
                // Copyright
                Center(
                  child: Text(
                    '© 2025 Flex Gym Inventory, LLC',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
