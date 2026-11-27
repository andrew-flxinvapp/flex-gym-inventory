import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_gym_inventory/src/widgets/snackbar.dart';

void main() {
  testWidgets('wrapped messages do not overlap other snackbars', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final dismissFirst = showFlexSnackbar(
      context,
      title: 'This account already has an active PRO subscription.',
      type: SnackbarType.update,
      duration: const Duration(seconds: 30),
      multiline: true,
    );
    final dismissSecond = showFlexSnackbar(
      context,
      title: 'Other notification',
      type: SnackbarType.success,
      duration: const Duration(seconds: 30),
    );
    await tester.pumpAndSettle();

    final first = find.byType(FlexSnackbar).first;
    final second = find.byType(FlexSnackbar).last;
    expect(tester.getSize(first).height, greaterThan(58));
    expect(tester.getTopLeft(first).dy, 36);
    expect(tester.getTopLeft(second).dy, tester.getBottomLeft(first).dy + 8);
    expect(tester.getSize(second).height, 58);
    expect(tester.widget<Text>(find.text('Other notification')).maxLines, 1);

    dismissFirst();
    dismissFirst();
    await tester.pumpAndSettle();
    expect(find.byType(FlexSnackbar), findsOneWidget);
    expect(tester.getTopLeft(find.byType(FlexSnackbar)).dy, 36);
    dismissSecond();
    await tester.pumpAndSettle();
    expect(find.byType(FlexSnackbar), findsNothing);
  });

  testWidgets('dismissal before the first frame is idempotent', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );
    final dismiss = showFlexSnackbar(
      context,
      title: 'First',
      type: SnackbarType.update,
    );
    dismiss();
    dismiss();
    final dismissSecond = showFlexSnackbar(
      context,
      title: 'Second',
      type: SnackbarType.update,
    );
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(FlexSnackbar)).dy, 36);
    dismissSecond();
    await tester.pumpAndSettle();
  });
}
