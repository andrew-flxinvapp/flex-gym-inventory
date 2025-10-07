import 'package:flutter/material.dart';
import '../../constant/character_bio.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';

class AboutFlexRackleyScreen extends StatelessWidget {
	const AboutFlexRackleyScreen({super.key});

	@override
	Widget build(BuildContext context) {
			return Scaffold(
				appBar: TopAppBar(
					title: 'About Flex',
					showBackArrow: true,
					showRightIcon: false,
				),
				body: SafeArea(
					child: Padding(
						padding: const EdgeInsets.all(20.0),
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.center,
								children: [
									const SizedBox(height: 16),
									Image.asset(
										'lib/assets/images/hello.png',
										height: 350,
										fit: BoxFit.contain,
									),
									const SizedBox(height: 24),
									Align(
										alignment: Alignment.centerLeft,
										child: Text(
											'Meet Flex Rackley',
											style: Theme.of(context).textTheme.titleMedium?.copyWith(
												color: AppTheme.lightTextPrimary,
											),
										),
									),
									const SizedBox(height: 24),
									Text(
										characterBio,
										style: Theme.of(context).textTheme.bodyLarge,
									),
								],
							),
						),
					),
				),
			);
	}
}
