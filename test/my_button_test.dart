import 'package:calories_tracker/widget/button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('MyButton shows correct text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Сохранить',
            textColor: Colors.white,
            text_size: 22,
            text_weight: FontWeight.w600,
            color: Colors.blue,
            borderColor: Colors.blue,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('MyButton triggers onTap callback', (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Сохранить',
            textColor: Colors.white,
            text_size: 22,
            text_weight: FontWeight.w600,
            color: Colors.blue,
            borderColor: Colors.blue,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MyButton));
    await tester.pump();

    expect(wasTapped, isTrue);
  });
}
