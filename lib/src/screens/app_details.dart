import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsScreen extends StatelessWidget {
  const AppDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const TopAppBar(title: 'App Details', showBackArrow: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Info Section
                      Text(
                        'App Info',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Name',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Flex Gym Inventory',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'App Version',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Version 1.0.0',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Developer Info
                      Text(
                        'Developer Info',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HEAVY DEV Co. LLC',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Privacy Policy
                      Text(
                        'Privacy Policy',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'View Privacy Policy ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.lightTextPrimary),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(
                                'https://flexgyminventory.app/privacy-policy',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Text(
                              'Here',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Terms & Conditions
                      Text(
                        'Terms & Conditions',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'View Terms & Conditions ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.lightTextPrimary),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(
                                'https://flexgyminventory.app/terms-and-conditions',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Text(
                              'Here',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Acknowledgements
                      Text(
                        'Acknowledgements',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Built with Flutter, Supabase, Isar Database, [other open source libraries]',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'KDC - IX-XXV-MMXXV',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  '© 2025 HEAVY DEV Co. LLC',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
