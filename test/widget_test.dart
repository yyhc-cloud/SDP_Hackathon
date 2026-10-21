import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sdp_hackathon/main.dart';
import 'package:sdp_hackathon/data/township_state.dart';

void main() {
  testWidgets('Home renders township dashboard, companion and raid boss', (WidgetTester tester) async {
    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    expect(find.text('Hello, Aisyah'), findsOneWidget);
    expect(find.textContaining('RAID BOSS'), findsWidgets);
    expect(find.textContaining('Digital Township Quick Access'), findsOneWidget);

    // Switch to Township Map tab
    await tester.tap(find.text('Township Map').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Live GIS Map'), findsOneWidget);

    // Switch to Sanctuary tab
    await tester.tap(find.text('Sanctuary').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Biodiversity Sanctuary'), findsOneWidget);
    expect(find.text('Companion & Evolution'), findsOneWidget);
    expect(find.text('Town Pet-Dex'), findsOneWidget);

    // Switch to Circular Shop tab
    await tester.tap(find.text('Circular Shop').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Circular Economy Shop'), findsOneWidget);

    // Switch back to Home tab & Open Profile
    await tester.tap(find.text('Home').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Profile button in Header
    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Resident Profile'), findsOneWidget);
    expect(find.text('Township Honors & Badges'), findsOneWidget);
    expect(find.text('Plastics Master'), findsOneWidget);
  });

  testWidgets('Show QR opens resident Eco-QR and deposits waste at Smart Bin to attack boss', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    final initialPoints = TownshipState.instance.greenPoints;
    final initialBossKg = TownshipState.instance.boss.currentKg;

    // Tap center floating QR button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Resident Eco-QR'), findsOneWidget);
    expect(find.textContaining('Scan & Deposit at Smart Bin'), findsOneWidget);

    // Deposit waste
    await tester.tap(find.textContaining('Scan & Deposit at Smart Bin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify celebration dialog & points & boss damage
    expect(find.textContaining('Deposit Verified!'), findsOneWidget);
    expect(TownshipState.instance.greenPoints, greaterThan(initialPoints));
    expect(TownshipState.instance.boss.currentKg, greaterThan(initialBossKg));

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Report in General allows selecting categories, issues, and submitting civic report', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    // Verify Report in General Quick Action
    expect(find.text('Report in General'), findsOneWidget);

    // Tap Report in General
    await tester.tap(find.text('Report in General'));
    await tester.pumpAndSettle();

    expect(find.text('Report in General'), findsWidgets);
    expect(find.text('Waste & Smart Bins'), findsOneWidget);
    expect(find.text('Township Infrastructure'), findsOneWidget);
    expect(find.text('Parks & Biodiversity'), findsOneWidget);

    // Select Township Infrastructure category
    await tester.tap(find.text('Township Infrastructure'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pothole or Cracked Asphalt'), findsOneWidget);

    // Submit report
    await tester.tap(find.text('Submit General Report'));
    await tester.pumpAndSettle();

    expect(find.text('Report Submitted'), findsOneWidget);
    expect(find.textContaining('+20 Green Points awarded'), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  });

  testWidgets('Sanctuary shows Evolution Tree, allows switching companion and evolution choice', (WidgetTester tester) async {
    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    // Switch to Sanctuary tab
    await tester.tap(find.text('Sanctuary').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Owned Cube Pet Switcher
    expect(find.text('My Owned Cube Pets'), findsOneWidget);
    expect(find.textContaining('Tap to Switch'), findsOneWidget);

    // Switch companion to Aqua Fish
    await tester.tap(find.text('Aqua Fish').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(TownshipState.instance.activeCompanion.name, 'fish');

    // Switch back to Cube Bunny and clear snackbars
    await tester.tap(find.text('Cube Bunny').first);
    await tester.pump();
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pumpAndSettle();
    expect(TownshipState.instance.activeCompanion.name, 'bunny');

    // Scroll down so Train button is safely above bottom dock
    await tester.drag(find.byType(ListView).first, const Offset(0, -320));
    await tester.pumpAndSettle();

    // Tap Train button to trigger Level-Up & Evolution Choice prompt
    await tester.tap(find.text('Train Companion (+35 EXP)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Level 16 Evolution Choice Dialog
    expect(find.textContaining('Evolution Ready'), findsWidgets);
    expect(find.textContaining('No Need (Keep Current Form)'), findsOneWidget);
    expect(find.textContaining('Evolve to Flora Deer!'), findsOneWidget);

    // Choose "No Need (Keep Current Form)"
    await tester.tap(find.text('No Need (Keep Current Form)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify companion remains Cube Bunny and state recorded preference
    expect(TownshipState.instance.activeCompanion.name, 'bunny');
    expect(TownshipState.instance.activeCompanion.hasDeclinedEvolution, isTrue);

    // Drag down to verify Evolution Tree is rendered
    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.textContaining('Evolution Tree'), findsWidgets);

    // Switch to Town Pet-Dex tab
    await tester.tap(find.text('Town Pet-Dex').last);
    await tester.pumpAndSettle();

    // Tap on #001 card in Pet-Dex Grid (Cube Bunny)
    await tester.tap(find.text('#001'));
    await tester.pumpAndSettle();

    // Verify Basic Info (Level, EXP)
    expect(find.textContaining('Experience (EXP)'), findsOneWidget);

    // Scroll inside bottom sheet to reveal Inner Evolution Tree section
    await tester.drag(find.textContaining('Experience (EXP)'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.textContaining('Inner Tree View'), findsOneWidget);
    expect(find.textContaining('Cube Bunny Evolution Tree'), findsWidgets);
  });

  testWidgets('Homepage features GameHub icon, launches GameHub, WaterPlant, CandyCrush, and Tetris', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    // Verify GameHub is displayed on Quick Access (replacing Township Map on homepage)
    expect(find.text('GameHub'), findsOneWidget);

    // Tap GameHub
    await tester.tap(find.text('GameHub'));
    await tester.pumpAndSettle();

    expect(find.text('Sime Darby Eco-GameHub'), findsOneWidget);
    expect(find.text('WaterPlant • Wetland Nursery'), findsOneWidget);
    expect(find.text('Candy Crush • Recyclables Match-3'), findsOneWidget);

    // Launch WaterPlant Game
    await tester.tap(find.text('Play Mini-Game').first);
    await tester.pumpAndSettle();

    expect(find.text('WaterPlant • Wetland Nursery'), findsWidgets);
    expect(find.text('BLOOMS'), findsOneWidget);

    // Tap a plot to water
    await tester.tap(find.byType(GestureDetector).at(5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Pop back to GameHub
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();

    // Launch CandyCrush
    await tester.tap(find.text('Play Mini-Game').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Candy Crush • Recyclables Match-3'), findsWidgets);
    expect(find.text('MOVES'), findsOneWidget);

    // Pop back to GameHub
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();

    // Scroll GameHub down to reveal Tetris
    await tester.drag(find.byType(ListView).last, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Tetris • Eco-Bale Compactor'), findsOneWidget);

    // Launch Tetris
    await tester.tap(find.text('Play Mini-Game').last);
    await tester.pumpAndSettle();

    expect(find.text('Eco-Bale Tetris • Compactor'), findsWidgets);
    expect(find.text('BALES COMPACTED'), findsOneWidget);

    // Pop back to GameHub
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();

    // Pop back to Home
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('Guild Wars displays neighbourhood rivalries, battlefronts and allows reinforcement', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    // Tap Guild Wars on Homepage
    await tester.tap(find.text('Guild Wars').first);
    await tester.pumpAndSettle();

    expect(find.text('Neighbourhood Guild Wars'), findsWidgets);
    expect(find.text('Makmur Eco-Guardians'), findsWidgets);
    expect(find.text('Central Wetlands Sanctuary'), findsOneWidget);

    // Reinforce battlefront
    await tester.tap(find.text('Reinforce Front (+50)').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Reinforced Central Wetlands Sanctuary'), findsOneWidget);

    // Switch to Leaderboard tab
    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Elmina Valley Protectors'), findsOneWidget);
    expect(find.text('Ara Greens Bio-Squad'), findsOneWidget);
    expect(find.text('Jelutong Bio-Knights'), findsOneWidget);
    expect(find.text('Putra Hillside Vanguard'), findsOneWidget);

    // Switch to War Activity tab
    await tester.tap(find.text('War Activity'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Reinforced front with 50 War Power'), findsOneWidget);
  });

  testWidgets('Boss Raid opens Interactive Raid Arena with boss, companion and moves', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SdpApp());
    await tester.pump();

    // Tap Boss Raid on Homepage
    await tester.tap(find.text('Boss Raid'));
    await tester.pumpAndSettle();

    expect(find.text('Interactive Raid Arena'), findsOneWidget);
    expect(find.textContaining('Toxic Sludge-Hog'), findsOneWidget);
    expect(find.textContaining('Raid HP:'), findsOneWidget);
    expect(find.textContaining('Companion Elemental Tactics'), findsOneWidget);

    final initialHp = TownshipState.instance.boss.bossCurrentHp;

    // Tap ATTACK on first move
    await tester.tap(find.text('ATTACK').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify damage dealt and HP decreased
    expect(TownshipState.instance.boss.bossCurrentHp, lessThan(initialHp));
    expect(find.textContaining('SUPER EFFECTIVE'), findsWidgets);
    expect(find.textContaining('dealt 68 purifying damage to Sludge-Hog'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
