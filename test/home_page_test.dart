import 'package:calories_tracker/service/hive_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:calories_tracker/pages/infoinputpage.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomePage shows correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(),
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(find.text('История'), findsOneWidget);
  });

  testWidgets('FloatingActionButton opens CameraPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(),
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(CameraPage), findsOneWidget);
  });

  testWidgets('Show info update dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(),
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.tap(find.text('Название: Example'));
    await tester.pumpAndSettle();

    expect(find.text('Название'), findsOneWidget);
  });
}
