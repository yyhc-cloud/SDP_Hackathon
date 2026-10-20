import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sdp_hackathon/main.dart';

void main() {
  testWidgets('Home renders and tabs switch', (WidgetTester tester) async {
    await tester.pumpWidget(const SdpApp());

    expect(find.text('Hello, Aisyah'), findsOneWidget);
    expect(find.text('Quick Access'), findsOneWidget);

    await tester.tap(find.text('Rewards').last);
    await tester.pumpAndSettle();
    expect(find.text('Pay Mall Parking'), findsOneWidget);

    await tester.tap(find.text('Community').last);
    await tester.pumpAndSettle();
    expect(find.text('Guild Wars'), findsWidgets);
  });

  testWidgets('Scan button opens scanner', (WidgetTester tester) async {
    await tester.pumpWidget(const SdpApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Scan Item'), findsOneWidget);
  });
}
