import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ai_placement_mentor/main.dart';

void main() {
  testWidgets('Placement Mentor app renders landing flow', (tester) async {
    await tester.pumpWidget(const PlacementMentorApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
