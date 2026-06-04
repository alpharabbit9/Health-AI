// Basic sanity test for HealthAI.
//
// The full app (HealthAIApp) requires Supabase + dotenv initialization, so it
// can't be pumped directly in a unit test without mocking. This smoke test
// just verifies the test harness and a trivial widget render correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp renders a child widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('HealthAI'))),
      ),
    );

    expect(find.text('HealthAI'), findsOneWidget);
  });
}
