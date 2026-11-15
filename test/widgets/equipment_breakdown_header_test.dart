import 'package:flex_gym_inventory/src/widgets/equipment_breakdown_header.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final gyms = [_gym('gym-1', 'North Gym'), _gym('gym-2', 'South Gym')];

  Widget buildHeader({
    List<DashboardGym> gyms = const [],
    String? selectedGymId,
    ValueChanged<String?>? onSelectionChanged,
    double width = 320,
    Alignment alignment = Alignment.center,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Align(
          alignment: alignment,
          child: SizedBox(
            key: const ValueKey('header'),
            width: width,
            child: EquipmentBreakdownHeader(
              gyms: gyms,
              selectedGymId: selectedGymId,
              onSelectionChanged: onSelectionChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('defaults to All Gyms and displays the themed header', (
    tester,
  ) async {
    await tester.pumpWidget(buildHeader());

    expect(find.text('By Category'), findsOneWidget);
    expect(find.text('All Gyms'), findsOneWidget);
    final title = tester.widget<Text>(find.text('By Category'));
    expect(
      title.style?.fontSize,
      AppTheme.lightTheme.textTheme.titleMedium?.fontSize,
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('All Gyms'),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
  });

  testWidgets('keeps the selector right-aligned on narrow headers', (
    tester,
  ) async {
    for (final width in [320.0, 180.0, 90.0]) {
      await tester.pumpWidget(buildHeader(width: width));
      final header = tester.getRect(find.byKey(const ValueKey('header')));
      final selector = tester.getRect(
        find.byKey(const ValueKey('equipment-breakdown-gym-selector-box')),
      );
      expect(selector.right, header.right);
      expect(selector.width, lessThanOrEqualTo(header.width));
      if (width >= 180) {
        expect(
          tester
              .renderObject<RenderParagraph>(find.text('All Gyms'))
              .didExceedMaxLines,
          isFalse,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('popup matches and overlays the selector at different sizes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final (width, alignment) in [
      (320.0, Alignment.topCenter),
      (390.0, Alignment.center),
      (800.0, Alignment.bottomCenter),
    ]) {
      tester.view.physicalSize = Size(width, 720);
      String? selection;
      await tester.pumpWidget(
        buildHeader(
          gyms: gyms,
          width: width - 32,
          alignment: alignment,
          onSelectionChanged: (id) => selection = id,
        ),
      );
      final selector = tester.getRect(
        find.byKey(const ValueKey('equipment-breakdown-gym-selector-box')),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('All Gyms'))
            .didExceedMaxLines,
        isFalse,
      );

      await tester.tap(
        find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
      );
      await tester.pumpAndSettle();
      final menu = tester.getRect(_popupMenu());
      expect(menu.width, closeTo(selector.width, 0.01));
      expect(menu.left, closeTo(selector.left, 0.01));
      expect(menu.right, closeTo(selector.right, 0.01));
      expect(menu.overlaps(selector), isTrue);
      if (alignment == Alignment.center) {
        expect(menu.top, closeTo(selector.top, 0.01));
      }

      await tester.tap(find.text('North Gym'));
      await tester.pumpAndSettle();
      expect(selection, 'gym-1');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('selecting a gym and All Gyms reports nullable IDs', (
    tester,
  ) async {
    String? selection = 'unchanged';
    await tester.pumpWidget(
      buildHeader(gyms: gyms, onSelectionChanged: (id) => selection = id),
    );

    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    await tester.pumpAndSettle();
    expect(find.text('All Gyms'), findsNWidgets(2));
    expect(find.text('North Gym'), findsOneWidget);
    expect(find.text('South Gym'), findsOneWidget);

    final menu = tester.widget<Material>(_popupMenu());
    expect(menu.shape, isA<RoundedRectangleBorder>());
    expect(
      (menu.shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(16),
    );
    expect(menu.surfaceTintColor, Colors.transparent);

    await tester.tap(find.text('North Gym'));
    await tester.pumpAndSettle();
    expect(selection, 'gym-1');

    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Gyms').last);
    await tester.pumpAndSettle();
    expect(selection, isNull);
  });

  testWidgets('allows choosing the only available gym', (tester) async {
    String? selection;
    await tester.pumpWidget(
      buildHeader(
        gyms: [gyms.first],
        onSelectionChanged: (id) => selection = id,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    await tester.pumpAndSettle();
    expect(find.text('All Gyms'), findsNWidgets(2));
    expect(find.text('North Gym'), findsOneWidget);
    expect(find.text('South Gym'), findsNothing);
    await tester.tap(find.text('North Gym'));
    await tester.pumpAndSettle();
    expect(selection, 'gym-1');
  });

  testWidgets('disables the selector when no gyms are available', (
    tester,
  ) async {
    await tester.pumpWidget(buildHeader());

    final selector = tester.widget<PopupMenuButton<dynamic>>(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    expect(selector.enabled, isFalse);
    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('All Gyms'), findsOneWidget);
  });

  testWidgets('falls back to All Gyms for a deleted selection', (tester) async {
    await tester.pumpWidget(
      buildHeader(gyms: gyms, selectedGymId: 'deleted-gym'),
    );

    expect(find.text('All Gyms'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ellipsizes long names without overflowing a narrow header', (
    tester,
  ) async {
    final gym = _gym(
      'gym-long-name',
      'An Extremely Long Gym Name That Should Not Overflow',
    );
    await tester.pumpWidget(
      buildHeader(gyms: [gym], selectedGymId: gym.gymId, width: 180),
    );

    final selectedName = tester.widget<Text>(
      find.text('An Extremely Long Gym Name That Should Not Overflow'),
    );
    expect(selectedName.maxLines, 1);
    expect(selectedName.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}

Finder _popupMenu() => find.ancestor(
  of: find.text('North Gym'),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Material &&
        widget.type == MaterialType.card &&
        widget.color == AppTheme.lightCard,
  ),
);

DashboardGym _gym(String id, String name) => DashboardGym(
  gymId: id,
  gymName: name,
  equipmentCount: 0,
  lastUpdated: DateTime(2026),
);
