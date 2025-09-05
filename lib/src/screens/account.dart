import 'package:flex_gym_inventory/theme/app_icons.dart';
import '../widgets/displays/account_greeting.dart';
import '../widgets/displays/display_field.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';



class AccountScreen extends StatelessWidget {
	const AccountScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppTheme.lightBackground,
			appBar: TopAppBar(
				title: 'Account',
				showBackArrow: true,
				showRightIcon: true,
				rightIcon: AppIcons.edit,
				onRightIconPressed: () {
					// TODO: Implement edit account action
				},
			),
						body: Padding(
								padding: const EdgeInsets.all(24.0),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const AccountGreeting(),
										const SizedBox(height: 32),
															Text(
																	'Account Info',
																	style: Theme.of(context).textTheme.titleMedium?.copyWith(
																			color: AppTheme.lightTextPrimary,
																			fontWeight: FontWeight.normal
																	),
															),
															const SizedBox(height: 16),
															const DisplayField(
																iconPath: AppIcons.user,
																label: 'Name',
																value: 'Flex Rackley',
															),
                              const SizedBox(height: 16),
															const DisplayField(
																iconPath: AppIcons.email,
																label: 'Email',
																value: 'flex@flexgym.com',
															),
									],
								),
						),
		);
	}
}
