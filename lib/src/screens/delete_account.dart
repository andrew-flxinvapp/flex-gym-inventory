import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/selectors/delete_account_selector.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/buttons/warning_button.dart';
import '../widgets/buttons/secondary_button.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';

class DeleteAccountScreen extends StatelessWidget {
	const DeleteAccountScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: PreferredSize(
				preferredSize: const Size.fromHeight(56),
				child: TopAppBar(
					title: 'Delete Account',
					showBackArrow: true,
					showRightIcon: false,
				),
			),
									body: SafeArea(
										child: SingleChildScrollView(
											child: Padding(
												padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
											Text(
												'Are you sure?',
												style: Theme.of(context).textTheme.titleMedium?.copyWith(
													color: AppTheme.lightTextPrimary,
												),
											),
											const SizedBox(height: 8),
											// Second text section placeholder
											Text(
												'We\'re sorry to see you go. Deleting your account will permanently remove all of your gyms, equipment data, and preferences. This action cannot be undone.',
												style: Theme.of(context).textTheme.bodyMedium,
											),
											const SizedBox(height: 32),
											Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(
														'Before you go, would you mind telling us why you\'re leaving?',
														style: Theme.of(context).textTheme.bodyMedium?.copyWith(
															color: AppTheme.lightTextPrimary,
														),
													),
													DeleteAccountSelector(selected: false, text: 'I am no longer using the app'),
													DeleteAccountSelector(selected: false, text: 'I\'m switching to a different tool'),
													DeleteAccountSelector(selected: false, text: 'It\'s missing features I need'),
													DeleteAccountSelector(selected: false, text: 'I found it hard to use'),
													DeleteAccountSelector(selected: false, text: 'I am concerned about my privacy or data'),
													DeleteAccountSelector(selected: false, text: 'I only needed it temporarily'),
													DeleteAccountSelector(selected: false, text: 'Other (please specifiy below)'),
													const SizedBox(height: 16),
																	CustomMultilineTextInput(
																		hintText: 'Please specify your reason...',
																	),
																	const SizedBox(height: 24),
																									WarningButton(
																										label: 'Delete Account',
																										onPressed: () {
																											// TODO: Add delete logic
																										},
																									),
																					const SizedBox(height: 16),
																											SecondaryButton(
																												label: 'Cancel',
																												onPressed: () {
																													Navigator.of(context).pop();
																												},
																											),
																											const SizedBox(height: 32),
												],
											),
										],
									),
								),
									),
								));
							}
						}
