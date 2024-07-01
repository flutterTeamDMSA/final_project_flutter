import 'package:calories_tracker/pages/infoinputpage.dart';
import 'package:calories_tracker/service/hive_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CameraPage shows camera preview', (WidgetTester tester) async {
    // Mock DataProvider
    await tester.pumpWidget( 
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(),
        child: MaterialApp(
          home: CameraPage(),
        ),
      ),
    );

    // Initially, it should show CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Mock Camera Preview
    await tester.pumpAndSettle();
    expect(find.byType(CameraPreview), findsOneWidget);
  });

  testWidgets('Take picture and show image', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(),
        child: MaterialApp(
          home: CameraPage(),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // It should show the image after taking picture
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Upload button works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DataProvider>(
        create: (context) => DataProvider(),
        child: MaterialApp(
          home: CameraPage(),
        ),
      ),
    );

    // Assuming the image is already taken
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    // It should show a CircularProgressIndicator while uploading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
