import 'package:flutter/material.dart';

import 'screens/biodiversity_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/show_qr_screen.dart';
import 'theme/app_colors.dart';

/// Bottom-tab shell: Home · Township Map · [Scan FAB] · Sanctuary & AR · Circular Shop.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  void _openScanner() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShowQrScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: _goTo),
      const TownshipMapScreen(),
      const SizedBox.shrink(), // slot under the centre scan button
      const BiodiversityScreen(),
      const RewardsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanner,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        tooltip: 'Show Resident QR at smart bin',
        child: const Icon(Icons.qr_code_2_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => i == 2 ? _openScanner() : _goTo(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Township Map',
          ),
          NavigationDestination(icon: SizedBox.shrink(), label: 'Show QR'),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Sanctuary',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Circular Shop',
          ),
        ],
      ),
    );
  }
}
