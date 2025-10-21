import 'package:flex_gym_inventory/src/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/selectors/delete_account_selector.dart';
// unused imports removed - not needed for this screen
// import '../widgets/inputs/multiline_text_input.dart';
// import '../widgets/buttons/warning_button.dart';
// import '../widgets/buttons/secondary_button.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import '../widgets/snackbar.dart';

class DefaultGymScreen extends StatefulWidget {
	const DefaultGymScreen({super.key});

	@override
	State<DefaultGymScreen> createState() => _DefaultGymScreenState();
}

class _DefaultGymScreenState extends State<DefaultGymScreen> {
	// Example list of gyms - replace with real data source as needed
	final List<String> gyms = [
		'Downtown Fitness',
		'Northside Gym',
		'East End Strength',
		'Westside CrossFit',
	];

	// Currently selected gym index. Use -1 for none selected.
	int _selectedIndex = -1;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: PreferredSize(
				preferredSize: const Size.fromHeight(56),
				child: TopAppBar(
					title: 'Default Gym',
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
									'Pick your main gym.',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										color: AppTheme.lightTextPrimary,
									),
								),
								const SizedBox(height: 8),
								// Second text section placeholder
								Text(
									'This will be the one you see first every time you open Flex Gym Inventory.',
									style: Theme.of(context).textTheme.bodyMedium,
								),
								const SizedBox(height: 32),

								// Render gym list as radio selectors
								Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'Select your default gym',
											style: Theme.of(context).textTheme.bodyMedium?.copyWith(
												color: AppTheme.lightTextPrimary,
											),
										),
										const SizedBox(height: 8),
										...List<Widget>.generate(gyms.length, (index) {
											return Padding(
												padding: const EdgeInsets.symmetric(vertical: 0),
												child: DeleteAccountSelector(
													selected: _selectedIndex == index,
													text: gyms[index],
													onTap: () {
														setState(() {
															_selectedIndex = index;
														});
													},
												),
											);
										}),

										const SizedBox(height: 24),
										PrimaryButton(
											label: 'Set Default Gym',
											onPressed: () {
												if (_selectedIndex < 0 || _selectedIndex >= gyms.length) {
													ScaffoldMessenger.of(context).showSnackBar(
														SnackBar(
															backgroundColor: Colors.transparent,
															elevation: 0,
															behavior: SnackBarBehavior.floating,
															padding: EdgeInsets.zero,
															content: FlexSnackbar(
																title: 'Please select a gym first.',
																subtitle: null,
																type: SnackbarType.warning,
															),
														),
													);
													return;
												}

												final selectedGym = gyms[_selectedIndex];
												// TODO: persist the selection to app settings / backend

												ScaffoldMessenger.of(context).showSnackBar(
													SnackBar(
														backgroundColor: Colors.transparent,
														elevation: 0,
														behavior: SnackBarBehavior.floating,
														padding: EdgeInsets.zero,
														content: FlexSnackbar(
															title: 'Set "$selectedGym" as your default gym.',
															subtitle: null,
															type: SnackbarType.success,
														),
													),
												);

												// Optionally pop back after setting
												// Navigator.of(context).pop(selectedGym);
											},
										),
									],
								),
							],
						),
					),
				),
			),
		);
	}
}
