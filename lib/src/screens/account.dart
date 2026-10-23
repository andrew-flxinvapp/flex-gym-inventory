import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/providers/account_data_provider.dart';
import '../widgets/displays/display_field.dart';
import '../widgets/displays/display_field_upgrade.dart';
import '../widgets/displays/display_field_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/snackbar.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/cards/settings_item.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountDataProvider);
    final name =
        account.isLoading
            ? 'Loading...'
            : account.error != null
            ? 'Unavailable'
            : account.fullName.isEmpty
            ? 'Not available'
            : account.fullName;
    final email =
        account.email.isNotEmpty
            ? account.email
            : account.isLoading
            ? 'Loading...'
            : 'Not available';

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: TopAppBar(
        title: 'Account',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
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
                DisplayField(
                  iconPath: AppIcons.user,
                  label: 'Name',
                  value: name,
                ),
                const SizedBox(height: 16),
                DisplayField(
                  iconPath: AppIcons.email,
                  label: 'Email',
                  value: email,
                ),
                if (account.error != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Unable to load account details.'),
                      ),
                      TextButton(
                        onPressed:
                            () =>
                                ref
                                    .read(accountDataProvider.notifier)
                                    .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                DisplayFieldNav(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.wishlist);
                  },
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
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.startupRouter,
                        (route) => false,
                      );
                    } catch (e) {
                      showFlexSnackbar(
                        context,
                        title: 'Sign out failed',
                        type: SnackbarType.stop,
                      );
                    }
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.stopColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
