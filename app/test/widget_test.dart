// Basic smoke test for the test harness.
//
// The app's real root widget is `SankofaTwiApp`, which initialises Firebase in
// main() before running. Pumping the full app here would require mocking
// Firebase, so this file keeps a minimal, dependency-free test that verifies
// the test harness itself works. Add widget/integration tests with proper
// Firebase mocks (e.g. firebase_auth_mocks / fake_cloud_firestore) as needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test harness renders a widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Sankofa Twi'))),
      ),
    );

    expect(find.text('Sankofa Twi'), findsOneWidget);
  });
}
