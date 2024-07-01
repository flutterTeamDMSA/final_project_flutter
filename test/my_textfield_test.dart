import 'package:calories_tracker/widget/textFiled.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('MyTextField shows correct initial value',
      (WidgetTester tester) async {
    TextEditingController controller =
        TextEditingController(text: 'Initial value');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextField(
            labelText: 'Название',
            controller: controller,
            onChanged: (_) {},
            color: Colors.blue,
            textColor: Colors.white,
          ),
        ),
      ),
    );

    expect(find.text('Initial value'), findsOneWidget);
  });

  testWidgets('MyTextField triggers onChanged callback',
      (WidgetTester tester) async {
    String changedValue = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextField(
            labelText: 'Название',
            controller: TextEditingController(),
            onChanged: (value) {
              changedValue = value;
            },
            color: Colors.blue,
            textColor: Colors.white,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'New value');
    await tester.pump();

    expect(changedValue, 'New value');
  });
}
