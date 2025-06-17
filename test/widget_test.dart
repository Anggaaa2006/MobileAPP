import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billbuddy/main.dart';

void main() {
  testWidgets('BillBuddy app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BillBuddyApp());

    // Verify that our app starts with splash screen or login
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}