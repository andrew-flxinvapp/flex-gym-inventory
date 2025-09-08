import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/widgets/top_app_bar.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/src/widgets/bottom_navigation.dart';
import 'package:flex_gym_inventory/src/widgets/cards/settings_item.dart';
import '../widgets/buttons/primary_button.dart';

class SettingsScreen extends StatelessWidget {
	const SettingsScreen({super.key});

		@override
		Widget build(BuildContext context) {
							return Scaffold(
												appBar: TopAppBar(
														title: 'Settings',
														titleWidget: const Padding(
															padding: EdgeInsets.only(left: 24.0),
															child: Text('Settings'),
														),
														showBackArrow: false,
														showRightIcon: false,
												),
								body: SingleChildScrollView(
									child: Padding(
										padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													'Account & Access',
													style: Theme.of(context).textTheme.displaySmall?.copyWith(
																color: AppTheme.lightTextPrimary,
															),
												),
												const SizedBox(height: 16),
												SettingsItem(
													title: 'Account',
                          onTap: () {
                            Navigator.of(context).pushNamed('/account');
                          },
												),
												/*const SizedBox(height: 12),
												SettingsItem(
													title: 'Theme',
												),*/
												const SizedBox(height: 12),
												SettingsItem(
													title: 'Upgrade Account',
                          onTap: () {
                            Navigator.of(context).pushNamed('/upgrade-account');
                          },
												),
												const SizedBox(height: 12),
												SettingsItem(
													title: 'Delete Account',
												),
												const SizedBox(height: 32),
												Text(
													'App Tools & Features',
													style: Theme.of(context).textTheme.displaySmall?.copyWith(
																color: AppTheme.lightTextPrimary,
															),
												),
												/*const SizedBox(height: 16),
												SettingsItem(
													title: 'Export Data',
												),*/
												const SizedBox(height: 12),
												SettingsItem(
													title: 'Notification Settings',
												),
												const SizedBox(height: 32),
												Text(
													'App Info & Support',
													style: Theme.of(context).textTheme.displaySmall?.copyWith(
																color: AppTheme.lightTextPrimary,
															),
												),
												const SizedBox(height: 16),
												SettingsItem(
													title: 'Legal',
												),
												const SizedBox(height: 12),
												SettingsItem(
													title: 'App Info',
													onTap: () {
														Navigator.of(context).pushNamed('/app-details');
													},
												),
												const SizedBox(height: 12),
												SettingsItem(
													title: 'Contact Support',
                          onTap: () {
                            Navigator.of(context).pushNamed('/support');
                          },
												),
												const SizedBox(height: 12),
												SettingsItem(
													title: 'App Feedback',
                          onTap: () {
                            Navigator.of(context).pushNamed('/feedback');
                          },
												),
																	const SizedBox(height: 32),
																	PrimaryButton(
																		label: 'Sign Out',
																		onPressed: () {
																			// TODO: Implement sign out logic
																		},
																	),
																	// ...other settings content goes here...
											],
										),
									),
								),
								bottomNavigationBar: BottomNavigationBarModern(
									currentIndex: 2,
									onTap: (_) {},
								),
							);
		}
}
