import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_sample/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text("Smart To-Do"), findsOneWidget);
  });
}
