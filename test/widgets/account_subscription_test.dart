import 'dart:async';

import 'package:flex_gym_inventory/providers/account_data_provider.dart';
import 'package:flex_gym_inventory/providers/subscription_provider.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flex_gym_inventory/src/screens/account.dart';
import 'package:flex_gym_inventory/src/widgets/displays/display_field.dart';
import 'package:flex_gym_inventory/src/widgets/displays/display_field_nav.dart';
import 'package:flex_gym_inventory/src/widgets/displays/display_field_upgrade.dart';
import 'package:flex_gym_inventory/src/widgets/snackbar.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const channel = MethodChannel('flex_gym_inventory/subscription_management');
const date = '2026-11-21T00:00:00Z';

CustomerInfo customer({
  bool active = false,
  bool renews = true,
  bool verified = true,
}) {
  final entries = <String, EntitlementInfo>{};
  if (active) {
    entries[RevenueCatService.proEntitlementId] = EntitlementInfo(
      RevenueCatService.proEntitlementId,
      true,
      renews,
      date,
      date,
      'fgi.pro.monthly',
      false,
    );
  }
  return CustomerInfo(
    EntitlementInfos(
      entries,
      entries,
      verification:
          verified ? VerificationResult.verified : VerificationResult.failed,
    ),
    const {},
    const [],
    const [],
    const [],
    date,
    'test-customer',
    const {},
    date,
  );
}

class AccountHarness {
  String? user = 'user-a';
  String revenueCatUser = 'user-a';
  final customers = <String, CustomerInfo>{
    'user-a': customer(),
    'user-b': customer(),
  };
  final auth = StreamController<String?>.broadcast(sync: true);
  final client = SupabaseClient('https://example.test', 'test-key');
  Completer<void>? configurationGate;
  Completer<void>? loginGate;
  CustomerInfoUpdateListener? listener;
  int reads = 0;

  late final service = RevenueCatService(
    configureSdk: ({required apiKey, appUserId}) async {
      if (configurationGate != null) await configurationGate!.future;
    },
    currentAppUserIdReader: () async => revenueCatUser,
    identityLogIn: (id) async {
      if (loginGate != null) await loginGate!.future;
      revenueCatUser = id;
      return null;
    },
    identityLogOut: () async => revenueCatUser = r'$RCAnonymousID:test',
    customerInfoReader: () async {
      reads++;
      return customers[revenueCatUser];
    },
    addCustomerInfoListener: (value) => listener = value,
    removeCustomerInfoListener: (_) => listener = null,
  );

  late final container = ProviderContainer(
    overrides: [
      revenueCatServiceProvider.overrideWithValue(service),
      accountDataProvider.overrideWith(
        (ref) => AccountDataNotifier(client: client),
      ),
    ],
  );

  void start() {
    service.startIdentitySynchronization(
      authUserIds: auth.stream,
      currentUserId: () => user,
    );
    service.startConfiguration(apiKey: 'appl_test', appUserId: user);
  }

  void changeUser(String? value) {
    user = value;
    auth.add(value);
  }

  Future<void> dispose() async {
    container.dispose();
    await service.stopIdentitySynchronization();
    await auth.close();
    await client.dispose();
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late AccountHarness h;
  final calls = <MethodCall>[];

  setUp(() {
    h = AccountHarness();
    calls.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    await h.dispose();
  });

  Future<void> pumpAccount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    h.start();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AccountScreen(),
          routes: {
            AppRoutes.upgradeInfo:
                (_) => const Scaffold(body: Text('Upgrade route')),
            AppRoutes.wishlist:
                (_) => const Scaffold(body: Text('Wishlist route')),
            AppRoutes.deleteAccount:
                (_) => const Scaffold(body: Text('Delete account route')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  DisplayField plan(WidgetTester tester) => tester.widget<DisplayField>(
    find.byWidgetPredicate(
      (widget) => widget is DisplayField && widget.label == 'Plan',
    ),
  );

  testWidgets('Free retains upgrade styling and existing navigation', (
    tester,
  ) async {
    await pumpAccount(tester);
    expect(plan(tester).value, 'Free');
    final upgrade = find.byType(DisplayFieldUpgrade);
    expect(find.text('Upgrade to PRO'), findsOneWidget);
    expect(tester.getSize(upgrade).height, 64);
    final upgradeMaterial = tester.widget<Material>(
      find.descendant(of: upgrade, matching: find.byType(Material)).first,
    );
    expect(upgradeMaterial.color, AppTheme.lightTextPrimary);
    final crown = tester.widget<Image>(
      find.descendant(
        of: upgrade,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == AppIcons.pro,
        ),
      ),
    );
    expect(crown.color, AppTheme.proColor);
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.text('Wishlist route'), findsOneWidget);
    Navigator.of(tester.element(find.text('Wishlist route'))).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete account route'), findsOneWidget);
    Navigator.of(tester.element(find.text('Delete account route'))).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Upgrade to PRO'));
    await tester.tap(find.text('Upgrade to PRO'));
    await tester.pumpAndSettle();
    expect(find.text('Upgrade route'), findsOneWidget);
  });

  testWidgets('active nonrenewing PRO uses the existing white action card', (
    tester,
  ) async {
    h.customers['user-a'] = customer(active: true, renews: false);
    await pumpAccount(tester);
    expect(plan(tester).value, 'FGI PRO');
    expect(find.text('Upgrade to PRO'), findsNothing);
    final action = find.ancestor(
      of: find.text('Manage Subscription'),
      matching: find.byType(DisplayFieldNav),
    );
    expect(tester.getSize(action).height, 64);
    final card = tester.widget<Material>(
      find.descendant(of: action, matching: find.byType(Material)).first,
    );
    expect(card.color, AppTheme.lightCard);
    expect(card.borderRadius, BorderRadius.circular(16));
    final images =
        tester
            .widgetList<Image>(
              find.descendant(of: action, matching: find.byType(Image)),
            )
            .toList();
    expect(images.map((image) => (image.image as AssetImage).assetName), [
      AppIcons.settings,
      AppIcons.forward,
    ]);
    expect(images.first.width, 22);
    expect(images.first.height, 22);
    expect(images.first.color, AppTheme.lightTextPrimary);
    expect(
      tester.widget<Text>(find.text('Manage Subscription')).style?.color,
      AppTheme.lightTextPrimary,
    );
  });

  testWidgets('loading and unavailable plans never expose actions', (
    tester,
  ) async {
    h.configurationGate = Completer<void>();
    await pumpAccount(tester);
    expect(plan(tester).value, 'Checking plan…');
    expect(find.text('Upgrade to PRO'), findsNothing);
    expect(find.text('Manage Subscription'), findsNothing);
    final action = tester.widget<DisplayFieldNav>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DisplayFieldNav && widget.title == 'Checking plan…',
      ),
    );
    expect(action.onPressed, isNull);
    h.customers['user-a'] = customer(verified: false);
    h.configurationGate!.complete();
    await tester.pumpAndSettle();
    expect(plan(tester).value, 'Unable to verify');
    expect(find.text('Plan unavailable'), findsOneWidget);
    expect(find.text('Upgrade to PRO'), findsNothing);
    expect(find.text('Manage Subscription'), findsNothing);
  });

  testWidgets('listener updates and expiration change plan and action', (
    tester,
  ) async {
    await pumpAccount(tester);
    h.customers['user-a'] = customer(active: true, renews: false);
    h.listener!(h.customers['user-a']!);
    await tester.pumpAndSettle();
    expect(plan(tester).value, 'FGI PRO');
    expect(find.text('Manage Subscription'), findsOneWidget);
    h.customers['user-a'] = customer();
    h.listener!(h.customers['user-a']!);
    await tester.pumpAndSettle();
    expect(plan(tester).value, 'Free');
    expect(find.text('Upgrade to PRO'), findsOneWidget);
  });

  testWidgets('signed-out account cannot upgrade or manage', (tester) async {
    h.user = null;
    await pumpAccount(tester);
    expect(plan(tester).value, 'Unable to verify');
    expect(find.text('Upgrade to PRO'), findsNothing);
    expect(find.text('Manage Subscription'), findsNothing);
    expect(
      tester
          .widget<DisplayFieldNav>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is DisplayFieldNav &&
                  widget.title == 'Plan unavailable',
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'native management waits for dismissal and refreshes entitlement',
    (tester) async {
      h.customers['user-a'] = customer(active: true);
      final dismissal = Completer<Object?>();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) {
        calls.add(call);
        return dismissal.future;
      });
      await pumpAccount(tester);
      final readsBefore = h.reads;
      await tester.tap(find.text('Manage Subscription'));
      await tester.pump();
      expect(calls.map((call) => call.method), ['showManageSubscriptions']);
      expect(find.text('Opening subscription…'), findsOneWidget);
      await tester.tap(find.text('Opening subscription…'));
      await tester.pump();
      expect(calls, hasLength(1));
      expect(plan(tester).value, 'FGI PRO');
      expect(h.reads, readsBefore);
      h.customers['user-a'] = customer();
      dismissal.complete(null);
      await tester.pumpAndSettle();
      expect(h.reads, greaterThan(readsBefore));
      expect(plan(tester).value, 'Free');
      expect(find.text('Upgrade to PRO'), findsOneWidget);
    },
  );

  testWidgets('closing management keeps active nonrenewing PRO', (tester) async {
    h.customers['user-a'] = customer(active: true);
    final dismissal = Completer<Object?>();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) => dismissal.future,
    );
    await pumpAccount(tester);
    await tester.tap(find.text('Manage Subscription'));
    await tester.pump();
    h.customers['user-a'] = customer(active: true, renews: false);
    dismissal.complete(null);
    await tester.pumpAndSettle();
    expect(plan(tester).value, 'FGI PRO');
    expect(find.text('Manage Subscription'), findsOneWidget);
    expect(find.text('Upgrade to PRO'), findsNothing);
  });

  testWidgets('native management failure shows a top snackbar', (tester) async {
    h.customers['user-a'] = customer(active: true);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    await pumpAccount(tester);
    await tester.tap(find.text('Manage Subscription'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Could not open subscription management.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FlexSnackbar>(find.byType(FlexSnackbar)).type,
      SnackbarType.stop,
    );
    expect(tester.getTopLeft(find.byType(FlexSnackbar)).dy, 36);
    expect(plan(tester).value, 'FGI PRO');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'account switch clears PRO and rejects an old management result',
    (tester) async {
      h.customers['user-a'] = customer(active: true);
      h.loginGate = Completer<void>();
      final dismissal = Completer<Object?>();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) => dismissal.future,
      );
      await pumpAccount(tester);
      await tester.tap(find.text('Manage Subscription'));
      await tester.pump();
      h.changeUser('user-b');
      await tester.pump();
      expect(plan(tester).value, 'Checking plan…');
      expect(find.text('Manage Subscription'), findsNothing);
      final readsBefore = h.reads;
      dismissal.complete(null);
      await tester.pump();
      expect(h.reads, readsBefore);
      h.loginGate!.complete();
      await tester.pumpAndSettle();
      expect(plan(tester).value, 'Free');
      expect(find.text('Upgrade to PRO'), findsOneWidget);
    },
  );

  testWidgets('stale PRO cannot open management after auth changes', (
    tester,
  ) async {
    h.customers['user-a'] = customer(active: true);
    await pumpAccount(tester);
    h.user = 'user-b';
    await tester.tap(find.text('Manage Subscription'));
    await tester.pump();
    expect(calls, isEmpty);
    h.auth.add('user-b');
    await tester.pumpAndSettle();
    expect(plan(tester).value, 'Free');
  });

  testWidgets('disposed screen ignores a late management failure', (
    tester,
  ) async {
    h.customers['user-a'] = customer(active: true);
    final dismissal = Completer<Object?>();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) => dismissal.future,
    );
    await pumpAccount(tester);
    await tester.tap(find.text('Manage Subscription'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    dismissal.completeError(PlatformException(code: 'unavailable'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(FlexSnackbar), findsNothing);
  });
}
