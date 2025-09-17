import '../widgets/selectors/notifications_toggle.dart';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
	const NotificationsScreen({Key? key}) : super(key: key);

	@override
	State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
	bool allowNotifications = false;

	@override
	void initState() {
		super.initState();
		_loadNotificationPreference();
	}

	Future<void> _loadNotificationPreference() async {
		final prefs = await SharedPreferences.getInstance();
		setState(() {
			allowNotifications = prefs.getBool('allow_notifications') ?? false;
		});
	}

	Future<void> _updateNotificationPreference(bool value) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool('allow_notifications', value);
		setState(() {
			allowNotifications = value;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: TopAppBar(
				title: 'Notifications',
				showBackArrow: true,
				showRightIcon: false,
			),
			body: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							'Helpful reminders and updates',
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										fontWeight: FontWeight.bold,
										color: AppTheme.lightTextPrimary,
									),
						),
						const SizedBox(height: 12),
						Text(
							'Flex Gym Inventory can send you reminders to help you keep your equipment in top shape.',
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: AppTheme.lightTextPrimary,
									),
						),
						const SizedBox(height: 24),
						NotificationsToggle(
							label: 'Allow Notifications?',
							initialValue: allowNotifications,
							onChanged: (val) {
								_updateNotificationPreference(val);
							},
						),
						if (allowNotifications) ...[
							const SizedBox(height: 32),
							Column(
								children: [
									NotificationsToggle(
										label: 'Maintenance reminders',
									),
									const SizedBox(height: 8),
									NotificationsToggle(
										label: 'New feature announcements',
									),
									const SizedBox(height: 8),
									NotificationsToggle(
										label: 'Weekly usage summaries',
									),
									const SizedBox(height: 8),
									NotificationsToggle(
										label: 'Community updates',
									),
								],
							),
						],
					],
				),
			),
		);
	}
}