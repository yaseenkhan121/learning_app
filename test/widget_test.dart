import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_app/main.dart';
 // Ensure the import path is correct

void main() {
  testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // The `const` keyword is removed here because MyApp's constructor is not constant.
    await tester.pumpWidget(MyApp());

    // Verify that the app's initial screen is the SplashScreen
    // by checking for a text element that should be on that screen.
    // Assuming SplashScreen has a Text widget with 'Welcome to the Learning App'.
    expect(find.text('Welcome to the Learning App'), findsOneWidget);

    // Verify that the "Get Started" button is present.
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}