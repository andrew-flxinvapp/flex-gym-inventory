import 'dart:async';

import 'package:flex_gym_inventory/src/screens/add_wishlist.dart';
import 'package:flex_gym_inventory/src/screens/edit_wishlist.dart';
import 'package:flex_gym_inventory/src/widgets/cards/wishlist_card.dart';
import 'package:flex_gym_inventory/src/widgets/inputs/text_input_field.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  void setLauncher(Future<Object?> Function(MethodCall) handler) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return handler(call);
    });
  }

  Widget card(String link) => MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: WishlistCard(details: [MapEntry('Link', link)])),
  );

  setUp(() => calls.clear());
  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  final launchCases = {
    'https://example.com/product?q=1': 'https://example.com/product?q=1',
    'http://example.com/product?q=1': 'http://example.com/product?q=1',
    '  example.com/product?q=bar%20bell  ':
        'https://example.com/product?q=bar%20bell',
  };
  for (final entry in launchCases.entries) {
    testWidgets('launches ${entry.key} externally without preflight', (
      tester,
    ) async {
      setLauncher((_) async => true);
      await tester.pumpWidget(card(entry.key));
      await tester.tap(find.text('Open Link'));
      await tester.pump();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'launch');
      final arguments = Map<Object?, Object?>.from(
        calls.single.arguments as Map,
      );
      expect(arguments['url'], entry.value);
      expect(arguments['useSafariVC'], false);
      expect(arguments['useWebView'], false);
      expect(arguments['universalLinksOnly'], false);
      expect(find.text('Could not open link.'), findsNothing);
    });
  }

  for (final failure in ['false', 'exception']) {
    testWidgets('shows the existing warning when launch returns $failure', (
      tester,
    ) async {
      setLauncher((_) async {
        if (failure == 'exception') {
          throw PlatformException(code: 'launch_failed');
        }
        return false;
      });
      await tester.pumpWidget(card('https://example.com/product'));
      await tester.tap(find.text('Open Link'));
      await tester.pump();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'launch');
      expect(find.text('Could not open link.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  }

  testWidgets('invalid stored links warn without calling the launcher', (
    tester,
  ) async {
    setLauncher((_) async => true);
    await tester.pumpWidget(card('javascript:alert(1)'));
    await tester.tap(find.text('Open Link'));
    await tester.pump();

    expect(calls, isEmpty);
    expect(find.text('Could not open link.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('empty and placeholder links are not actionable', (tester) async {
    for (final link in ['', '  ', '-', '  -  ']) {
      await tester.pumpWidget(card(link));
      expect(find.text('Open Link'), findsNothing, reason: link);
    }
  });

  testWidgets(
    'does not show a warning if the screen is removed during launch',
    (tester) async {
      final result = Completer<Object?>();
      setLauncher((_) => result.future);
      await tester.pumpWidget(card('https://example.com'));
      await tester.tap(find.text('Open Link'));
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      result.complete(false);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Could not open link.'), findsNothing);
    },
  );

  for (final screen in [
    const AddWishlistScreen(),
    const EditWishlistScreen(),
  ]) {
    testWidgets('${screen.runtimeType} validates optional links', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: screen),
      );
      await tester.pump();
      final linkInput = find.byWidgetPredicate(
        (widget) =>
            widget is CustomTextInputField && widget.hintText == 'Link (URL)',
      );
      final field = find.descendant(
        of: linkInput,
        matching: find.byType(TextFormField),
      );
      final state = tester.state<FormFieldState<String>>(field);

      expect(state.validate(), isTrue);
      await tester.enterText(field, '  example.com/item?q=1  ');
      expect(state.validate(), isTrue);
      await tester.enterText(field, 'mailto:user@example.com');
      expect(state.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a valid web link'), findsOneWidget);
      await tester.enterText(field, '   ');
      expect(state.validate(), isTrue);
    });
  }
}
