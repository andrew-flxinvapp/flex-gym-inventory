import 'package:flex_gym_inventory/src/widgets/dialogs/confirm_dialog.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final variant in [
    ConfirmDialogVariant.destructive,
    ConfirmDialogVariant.standard,
  ]) {
    testWidgets('$variant retains confirmation and cancellation actions', (
      tester,
    ) async {
      var confirmed = 0;
      var cancelled = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showDialog<void>(
                        context: context,
                        builder:
                            (_) => ConfirmDialog(
                              title: 'Confirm',
                              content: 'Are you sure?',
                              confirmText: 'Proceed',
                              variant: variant,
                              onConfirm: () => confirmed++,
                              onCancel: () => cancelled++,
                            ),
                      ),
                  child: const Text('Open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(
        button.style!.backgroundColor!.resolve({}),
        variant == ConfirmDialogVariant.destructive
            ? AppTheme.stopColor
            : AppTheme.lightTextPrimary,
      );
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cancelled, 1);
      expect(confirmed, 0);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();
      expect(confirmed, 1);
    });
  }

  testWidgets('success dialog is accessible and scrolls at large text sizes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    var confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder:
                          (_) => ConfirmDialog(
                            variant: ConfirmDialogVariant.success,
                            title: 'Welcome to FGI PRO!',
                            content:
                                'Your subscription is active. You now have access to all FGI PRO features.',
                            confirmText: 'Continue',
                            onConfirm: () => confirmed = true,
                          ),
                    ),
                child: const Text('Open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppIcons.complete);
    expect(image.color, AppTheme.successColor);
    expect(find.text('Welcome to FGI PRO!'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style!.backgroundColor!.resolve({}), AppTheme.successColor);
    expect(
      tester.getSemantics(find.text('Welcome to FGI PRO!')),
      matchesSemantics(label: 'Welcome to FGI PRO!', isHeader: true),
    );
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
