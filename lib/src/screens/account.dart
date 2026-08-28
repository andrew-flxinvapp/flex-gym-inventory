import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../widgets/displays/display_field.dart';
import '../widgets/displays/display_field_upgrade.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/cards/settings_item.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: TopAppBar(
        title: 'Account',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Info',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                const DisplayField(
                  iconPath: AppIcons.email,
                  label: 'Email',
                  value: 'flex@flexgym.com',
                ),
                const SizedBox(height: 16),
                const DisplayField(
                  iconPath: AppIcons.upgrade,
                  label: 'Plan',
                  value: 'Free',
                ),
                const SizedBox(height: 16),
                DisplayFieldUpgrade(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.newUpgrade);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Legal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsItem(
                  title: 'Privacy Policy',
                  onTap: () async {
                    final url = Uri.parse('https://flexgyminventory.app/privacy-policy');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                SettingsItem(
                  title: 'Terms of Service',
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
                ),
                const SizedBox(height: 16),
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Sign Out',
                  onPressed: () {
                    // TODO: Add sign out logic
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.deleteAccount);
                    },
                    child: Text(
                      'Delete Account',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.stopColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
