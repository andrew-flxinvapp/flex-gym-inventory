import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/providers/account_data_provider.dart';
import 'package:flex_gym_inventory/providers/subscription_provider.dart';
import 'package:flex_gym_inventory/constant/subscription_constants.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';
import '../widgets/displays/display_field.dart';
import '../widgets/displays/display_field_upgrade.dart';
import '../widgets/displays/display_field_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/snackbar.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/cards/settings_item.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  static const _managementChannel = MethodChannel(
    'flex_gym_inventory/subscription_management',
  );
  bool _managingSubscription = false;
  VoidCallback? _dismissManagementMessage;

  @override
  void dispose() {
    _dismissManagementMessage?.call();
    super.dispose();
  }

  Future<void> _manageSubscription() async {
    final service = ref.read(revenueCatServiceProvider);
    if (_managingSubscription ||
        ref.read(subscriptionProvider).status != SubscriptionStatus.pro ||
        !service.isCurrentSupabaseUserSynchronized) {
      return;
    }
    final revision = service.identityRevision;
    _dismissManagementMessage?.call();
    _dismissManagementMessage = null;
    setState(() => _managingSubscription = true);
    try {
      await _managementChannel.invokeMethod<void>('showManageSubscriptions');
      if (!mounted ||
          revision != service.identityRevision ||
          !service.isCurrentSupabaseUserSynchronized) {
        return;
      }
      await ref.read(subscriptionProvider.notifier).refresh();
    } catch (_) {
      LogHandler.warning('Account', 'Could not open subscription management.');
      if (!mounted ||
          revision != service.identityRevision ||
          !service.isCurrentSupabaseUserSynchronized) {
        return;
      }
      _dismissManagementMessage = showFlexSnackbar(
        context,
        title: 'Could not open subscription management.',
        type: SnackbarType.stop,
        multiline: true,
      );
    } finally {
      if (mounted) setState(() => _managingSubscription = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountDataProvider);
    final subscription = ref.watch(subscriptionProvider);
    final service = ref.watch(revenueCatServiceProvider);
    final status =
        (subscription.status == SubscriptionStatus.free ||
                    subscription.status == SubscriptionStatus.pro) &&
                !service.isCurrentSupabaseUserSynchronized
            ? SubscriptionStatus.loading
            : subscription.status;
    final plan = switch (status) {
      SubscriptionStatus.free => SubscriptionConstants.freePlanName,
      SubscriptionStatus.pro => 'FGI PRO',
      SubscriptionStatus.loading => 'Checking plan…',
      SubscriptionStatus.unavailable || SubscriptionStatus.signedOut =>
        'Unable to verify',
    };
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
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                DisplayField(
                  iconPath: AppIcons.upgrade,
                  label: 'Plan',
                  value: plan,
                ),
                const SizedBox(height: 16),
                if (status == SubscriptionStatus.free)
                  DisplayFieldUpgrade(
                    onPressed: () {
                      if (service.isCurrentSupabaseUserSynchronized &&
                          ref.read(subscriptionProvider).status ==
                              SubscriptionStatus.free) {
                        Navigator.of(context).pushNamed(AppRoutes.upgradeInfo);
                      }
                    },
                  )
                else
                  Opacity(
                    opacity:
                        status == SubscriptionStatus.pro &&
                                !_managingSubscription
                            ? 1
                            : 0.6,
                    child: DisplayFieldNav(
                      title: switch (status) {
                        SubscriptionStatus.pro =>
                          _managingSubscription
                              ? 'Opening subscription…'
                              : 'Manage Subscription',
                        SubscriptionStatus.loading => 'Checking plan…',
                        _ => 'Plan unavailable',
                      },
                      iconPath: AppIcons.settings,
                      onPressed:
                          status == SubscriptionStatus.pro &&
                                  !_managingSubscription
                              ? _manageSubscription
                              : null,
                    ),
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
                      if (!context.mounted) return;
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.startupRouter,
                        (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
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
