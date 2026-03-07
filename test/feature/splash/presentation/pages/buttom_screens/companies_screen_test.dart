import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rojgar/feature/splash/presentation/pages/buttom_screens/companies_screen.dart';

Widget _buildTestWidget() {
  return const MaterialApp(
    home: CompaniesScreen(),
  );
}

void main() {
  group('CompaniesScreen', () {
    testWidgets('renders header title correctly', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Explore leading'), findsOneWidget);
    });

    testWidgets('renders search bar with correct hint text', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Search companies by name...'), findsOneWidget);
    });

    testWidgets('renders all companies by default', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Showing 8 companies'), findsOneWidget);
    });

    testWidgets('renders All category filter chip by default', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders category filter chips', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Software Development'), findsWidgets);
      expect(find.text('Design & Branding'), findsWidgets);
      expect(find.text('Data & Analytics'), findsWidgets);
      expect(find.text('Consulting'), findsWidgets);
    });

    testWidgets('renders known company names', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('TechCore Solutions'), findsOneWidget);
      expect(find.text('Creative Minds'), findsOneWidget);
      expect(find.text('DataNova Analytics'), findsOneWidget);
    });

    testWidgets('renders open jobs text on company cards', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Open Jobs'), findsWidgets);
    });

    testWidgets('renders star rating on company cards', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('search filters companies by name', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'TechCore');
      await tester.pump();

      expect(find.text('TechCore Solutions'), findsOneWidget);
      expect(find.text('Creative Minds'), findsNothing);
      expect(find.textContaining('Showing 1 company'), findsOneWidget);
    });

    testWidgets('search with no match shows no companies found', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyznotexist');
      await tester.pump();

      expect(find.text('No companies found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('search is case insensitive', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'techcore');
      await tester.pump();

      expect(find.text('TechCore Solutions'), findsOneWidget);
    });

    testWidgets('category filter shows only matching companies', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll filter horizontally multiple times to ensure visibility
      for (int i = 0; i < 3; i++) {
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(-300, 0),
        );
        await tester.pump();
      }

      // Verify Consulting button is visible and tap it
      if (find.text('Consulting', skipOffstage: false).evaluate().isNotEmpty) {
        final filterChip = find.ancestor(
          of: find.text('Consulting'),
          matching: find.byWidgetPredicate((w) => w is GestureDetector),
        ).first;
        await tester.tap(filterChip, warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('BizConsult Nepal'), findsOneWidget);
        expect(find.text('TechCore Solutions'), findsNothing);
      }
    });

    testWidgets('Design & Branding filter shows two companies', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Design & Branding').first);
      await tester.pump();

      expect(find.text('Creative Minds'), findsOneWidget);
      expect(find.text('PixelForge Studio'), findsOneWidget);
      expect(find.textContaining('Showing 2 companies'), findsOneWidget);
    });

    testWidgets('Software Development filter shows correct companies',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the filter chip specifically (inside SingleChildScrollView row)
      final filterChip = find.ancestor(
        of: find.text('Software Development'),
        matching: find.byWidgetPredicate(
          (w) => w is GestureDetector,
        ),
      ).first;
      await tester.tap(filterChip);
      await tester.pump();

      expect(find.text('TechCore Solutions'), findsOneWidget);
      expect(find.text('CodeCraft IT'), findsOneWidget);
      expect(find.text('Creative Minds'), findsNothing);
    });

    testWidgets('selecting All after category filter shows all companies',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll filter horizontally to reveal Consulting button
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(-200, 0),
      );
      await tester.pump();

      final filterChip = find.ancestor(
        of: find.text('Consulting'),
        matching: find.byWidgetPredicate((w) => w is GestureDetector),
      ).first;
      await tester.tap(filterChip);
      await tester.pump();

      await tester.tap(find.text('All'));
      await tester.pump();

      expect(find.textContaining('Showing 8 companies'), findsOneWidget);
    });

    testWidgets('search and category filter work together', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the filter chip specifically (inside SingleChildScrollView row)
      final filterChip = find.ancestor(
        of: find.text('Software Development'),
        matching: find.byWidgetPredicate(
          (w) => w is GestureDetector,
        ),
      ).first;
      await tester.tap(filterChip);
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'TechCore');
      await tester.pump();

      expect(find.text('TechCore Solutions'), findsOneWidget);
      expect(find.text('CodeCraft IT'), findsNothing);
    });

    testWidgets('clears search restores filtered companies', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'TechCore');
      await tester.pump();

      expect(find.textContaining('Showing 1 company'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.textContaining('Showing 8 companies'), findsOneWidget);
    });

    testWidgets('company card shows location', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Kathmandu, Nepal'), findsWidgets);
    });

    testWidgets('company card shows rating and review count', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text(' (128)'), findsOneWidget);
    });

    testWidgets('filter icon is visible in category row', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    });

    testWidgets('renders location icons on company cards', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on_outlined), findsWidgets);
    });

    testWidgets('renders work outline icons on company cards', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.work_outline), findsWidgets);
    });
  });
}