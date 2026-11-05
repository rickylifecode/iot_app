import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iot_app/main.dart';

void main() {
  testWidgets('sign in opens the product collection', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Discover your next favorite'), findsOneWidget);
    expect(find.text('Smart Thermostat'), findsOneWidget);
  });

  testWidgets('registration form validates required information',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter your email address'), findsOneWidget);
  });
}
