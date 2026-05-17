import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/screens/workout_tab.dart';

void main() {
  testWidgets('WorkoutTab shows categories', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WorkoutTab(userName: 'Test'))),
    );
    await tester.pump();
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
  });
}
