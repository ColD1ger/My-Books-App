// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mybooks/main.dart';

void main() {
  testWidgets('book list shows books and supports filtering',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Books List'), findsOneWidget);
    expect(find.text('Don Quixote'), findsOneWidget);
    expect(find.text('Pride and Prejudice'), findsOneWidget);
    expect(find.text('Read'), findsNothing);
    expect(
      tester.widget<Text>(find.text('Don Quixote')).style?.decoration,
      isNot(TextDecoration.lineThrough),
    );

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(find.text('Read'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Don Quixote')).style?.decoration,
      TextDecoration.lineThrough,
    );

    await tester.tap(find.text('Pride and Prejudice'));
    await tester.pumpAndSettle();

    expect(find.text('Book details'), findsOneWidget);
    await tester.tap(find.byTooltip('Rate 4 stars'));
    await tester.pump();
    await tester.tap(find.text('Save rating'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Pride and Prejudice')).style?.decoration,
      TextDecoration.lineThrough,
    );
    expect(find.byIcon(Icons.star), findsNWidgets(4));

    await tester.enterText(find.byType(TextField), 'Jane');
    await tester.pump();

    expect(find.text('Jane Eyre'), findsOneWidget);
    expect(find.text('Don Quixote'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.pump();

    expect(find.text('Don Quixote'), findsOneWidget);
    expect(find.text('Jane Eyre'), findsNothing);

    await tester.drag(find.text('Don Quixote'), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Don Quixote'), findsNothing);
    expect(find.text('"Don Quixote" deleted'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Don Quixote'), findsOneWidget);
  });
}
