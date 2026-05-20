import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biodata_mahasiswa/main.dart';

void main() {
  testWidgets('Check if Student Management loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the screen loads and the refresh icon/button is present.
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
