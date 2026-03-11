import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/src/screens/opt_notifications.dart';

// Minimal fakes to satisfy the small Supabase auth surface used by the widget.
class _FakeUser {
  Map<String, dynamic>? userMetadata;
  _FakeUser(this.userMetadata);
}

class _FakeAuth {
  _FakeUser currentUser;
  _FakeAuth(this.currentUser);

  Future<void> updateUser(UserAttributes attrs) async {
    final Map<String, dynamic> data = (attrs.data as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> existing = (currentUser.userMetadata as Map<String, dynamic>?) ?? {};
    currentUser.userMetadata = {...existing, ...data};
  }
}

class _FakeClient {
  final _FakeAuth auth;
  _FakeClient(this.auth);
}

void main() {
  testWidgets('toggling switch requests permission and saves when granted', (tester) async {
    final fakeUser = _FakeUser({'notificationsOn': false});
    final fakeAuth = _FakeAuth(fakeUser);
    final fakeClient = _FakeClient(fakeAuth);

    final binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
    binding.window.physicalSizeTestValue = const Size(800, 1400);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: OptNotificationsScreen(
          supabaseClient: fakeClient,
          permissionRequest: () async => PermissionStatus.granted,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switchFinder = find.byType(CupertinoSwitch);
    expect(switchFinder, findsOneWidget);

    final before = tester.widget<CupertinoSwitch>(switchFinder).value;
    expect(before, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    final after = tester.widget<CupertinoSwitch>(switchFinder).value;
    expect(after, isTrue);

    expect(fakeClient.auth.currentUser.userMetadata?['notificationsOn'], isTrue);
  });

  testWidgets('toggling switch when permission denied persists false', (tester) async {
    final fakeUser = _FakeUser({'notificationsOn': true});
    final fakeAuth = _FakeAuth(fakeUser);
    final fakeClient = _FakeClient(fakeAuth);

    final binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
    binding.window.physicalSizeTestValue = const Size(800, 1400);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: OptNotificationsScreen(
          supabaseClient: fakeClient,
          permissionRequest: () async => PermissionStatus.denied,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switchFinder = find.byType(CupertinoSwitch);
    expect(switchFinder, findsOneWidget);

    final before = tester.widget<CupertinoSwitch>(switchFinder).value;
    expect(before, isTrue);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    final after = tester.widget<CupertinoSwitch>(switchFinder).value;
    expect(after, isFalse);

    expect(fakeClient.auth.currentUser.userMetadata?['notificationsOn'], isFalse);
  });
}
