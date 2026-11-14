import 'package:flex_gym_inventory/src/widgets/inputs/quantity_input.dart';
import 'package:flex_gym_inventory/src/widgets/layouts/app_screen.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget quantityInput({
    required TextEditingController controller,
    FocusNode? focusNode,
    ThemeData? theme,
    Widget? child,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Theme(
        data: theme ?? AppTheme.lightTheme,
        child: Scaffold(
          body:
              child ??
              Form(
                child: QuantityInput(
                  hintText: 'Quantity',
                  showAsterisk: true,
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
        ),
      ),
    );
  }

  Finder fieldFinder() => find.byType(TextFormField);
  Finder textFieldFinder() => find.byType(TextField);

  IconButton button(WidgetTester tester, String tooltip) {
    final finder = find.ancestor(
      of: find.byTooltip(tooltip),
      matching: find.byType(IconButton),
    );
    return tester.widget<IconButton>(finder.first);
  }

  testWidgets('renders the controller value and numeric field configuration', (
    tester,
  ) async {
    final controller = TextEditingController(text: '12');
    await tester.pumpWidget(quantityInput(controller: controller));

    final field = tester.widget<TextField>(textFieldFinder());
    expect(controller.text, '12');
    expect(field.keyboardType, TextInputType.number);
    expect(field.textAlign, TextAlign.left);
    expect(field.inputFormatters, hasLength(1));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'Quantity *',
      ),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(QuantityInput)).height, 50);
  });

  testWidgets('increments and decrements by exactly one', (tester) async {
    final controller = TextEditingController(text: '4');
    await tester.pumpWidget(quantityInput(controller: controller));

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(controller.text, '5');

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pump();
    expect(controller.text, '4');
  });

  testWidgets('disables decrement at one', (tester) async {
    final controller = TextEditingController(text: '1');
    await tester.pumpWidget(quantityInput(controller: controller));

    expect(button(tester, 'Decrease quantity').onPressed, isNull);
    expect(button(tester, 'Increase quantity').onPressed, isNotNull);
  });

  testWidgets('supports direct numeric entry', (tester) async {
    final controller = TextEditingController(text: '1');
    await tester.pumpWidget(quantityInput(controller: controller));

    await tester.enterText(fieldFinder(), '27');
    await tester.pump();

    expect(controller.text, '27');
    expect(button(tester, 'Decrease quantity').onPressed, isNotNull);
  });

  testWidgets('rejects non-digit manual edits without altering the value', (
    tester,
  ) async {
    final controller = TextEditingController(text: '2');
    await tester.pumpWidget(quantityInput(controller: controller));

    await tester.enterText(fieldFinder(), '1.5');
    await tester.pump();

    expect(controller.text, '2');
  });

  testWidgets('allows empty text and increments it to one', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(quantityInput(controller: controller));

    expect(controller.text, isEmpty);
    expect(button(tester, 'Decrease quantity').onPressed, isNull);
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(controller.text, '1');
  });

  testWidgets('validates empty, zero, negative, decimal, and invalid values', (
    tester,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      quantityInput(
        controller: controller,
        child: Form(
          key: formKey,
          child: QuantityInput(hintText: 'Quantity', controller: controller),
        ),
      ),
    );

    for (final value in ['', '0', '-1', '1.5', 'abc']) {
      controller.text = value;
      expect(formKey.currentState!.validate(), isFalse, reason: value);
    }
    controller.text = '1';
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Enter a whole number of 1 or more'), findsNothing);
  });

  testWidgets('synchronizes controller changes made outside the field', (
    tester,
  ) async {
    final controller = TextEditingController(text: '2');
    await tester.pumpWidget(quantityInput(controller: controller));

    controller.text = '8';
    await tester.pump();
    expect(tester.widget<TextField>(textFieldFinder()).controller, controller);
    expect(button(tester, 'Decrease quantity').onPressed, isNotNull);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pump();
    expect(controller.text, '7');
  });

  testWidgets('stepper preserves focus inside an unfocus-on-tap screen', (
    tester,
  ) async {
    final controller = TextEditingController(text: '2');
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      quantityInput(
        controller: controller,
        focusNode: focusNode,
        child: AppScreen(
          unfocusOnTap: true,
          child: Form(
            child: QuantityInput(
              hintText: 'Quantity',
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      ),
    );

    await tester.tap(fieldFinder());
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(controller.text, '3');
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('does not increment an unparseable oversized value', (
    tester,
  ) async {
    final controller = TextEditingController(text: '9' * 1000);
    await tester.pumpWidget(quantityInput(controller: controller));

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(controller.text, '9' * 1000);
    expect(button(tester, 'Decrease quantity').onPressed, isNull);
  });

  testWidgets(
    'does not overflow when incrementing the largest parsed integer',
    (tester) async {
      const largestParsedInteger = '9223372036854775807';
      final controller = TextEditingController(text: largestParsedInteger);
      await tester.pumpWidget(quantityInput(controller: controller));

      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();

      expect(controller.text, largestParsedInteger);
    },
  );

  testWidgets('uses light and dark theme surfaces and text colors', (
    tester,
  ) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final controller = TextEditingController(text: '1');
      await tester.pumpWidget(
        quantityInput(controller: controller, theme: theme),
      );

      final field = tester.widget<TextField>(textFieldFinder());
      final isDark = theme.brightness == Brightness.dark;
      expect(
        Theme.of(tester.element(find.byType(QuantityInput))).brightness,
        isDark ? Brightness.dark : Brightness.light,
      );
      expect(
        field.decoration!.fillColor,
        isDark ? AppTheme.darkCard : AppTheme.lightCard,
      );
      final hint = field.decoration!.hint as RichText;
      final hintSpan = hint.text as TextSpan;
      expect(
        hintSpan.style!.color,
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
      );
    }
  });

  testWidgets('form validation shows an error and blocks submission', (
    tester,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var submissions = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                QuantityInput(
                  hintText: 'Quantity',
                  controller: controller,
                  validator: QuantityInput.validateQuantity,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) submissions++;
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(submissions, 0);
    expect(find.text('Enter a whole number of 1 or more'), findsOneWidget);

    controller.text = '3';
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(submissions, 1);
  });

  testWidgets('stepper SVG icons actually paint visible pixels', (
    tester,
  ) async {
    final key = GlobalKey();
    final controller = TextEditingController(text: '5');
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 300,
                  child: QuantityInput(
                    hintText: 'Quantity',
                    controller: controller,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump();

      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = (await image.toByteData())!;
      final iconRect = tester.getRect(find.byTooltip('Increase quantity'));
      final origin = tester.getTopLeft(find.byKey(key));
      final scale = image.width / boundary.size.width;
      var painted = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final dx = x / scale + origin.dx;
          if (dx < iconRect.left || dx > iconRect.right) continue;
          final offset = (y * image.width + x) * 4;
          final lum =
              (data.getUint8(offset) +
                  data.getUint8(offset + 1) +
                  data.getUint8(offset + 2)) /
              3;
          if (lum < 128) painted++;
        }
      }
      expect(painted, greaterThan(0));
    });
  });
}
