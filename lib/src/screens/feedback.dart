import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';

class FeedbackScreen extends StatelessWidget {
	const FeedbackScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppTheme.lightBackground,
			appBar: const TopAppBar(
				title: 'Feedback',
				showBackArrow: true,
				showRightIcon: false,
			),
			body: Padding(
			  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
			  child: Column(
			    crossAxisAlignment: CrossAxisAlignment.start,
			    children: [
						Text(
							'We value your feedback.',
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
								fontWeight: FontWeight.bold,
								color: AppTheme.lightTextPrimary,
							),
						),
						const SizedBox(height: 8),
						Text(
							'Share your feedback with us to help improve your experience. We typically reply within 48 hours.',
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
								fontWeight: FontWeight.normal,
								color: AppTheme.lightTextPrimary,
							),
						),
						const SizedBox(height: 32),
									CustomTextInputField(
										hintText: 'Name',
										showAsterisk: true,
									),
									const SizedBox(height: 16),
									CustomTextInputField(
										hintText: 'Email',
										showAsterisk: true,
									),
									const SizedBox(height: 16),
												CustomTextInputField(
													hintText: 'Subject',
													showAsterisk: true,
												),
												const SizedBox(height: 16),
															CustomMultilineTextInput(
																hintText: 'Message',
															),
															const SizedBox(height: 40),
																		PrimaryButton(
																			label: 'Submit',
																			onPressed: () {},
																		),
																		const SizedBox(height: 12),
																		SecondaryButton(
																			label: 'Cancel',
																			onPressed: () {
																				Navigator.of(context).pushNamed('/settings');
																			},
																		),
			    ],
			  ),
			),
		);
	}
}
