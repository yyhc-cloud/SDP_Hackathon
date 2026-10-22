import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/landed_models.dart';
import '../models/pokemon_model.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'boss_battle_screen.dart';
import 'pickup_request_screen.dart';
import 'scan_screen.dart';

enum MapLayerStyle { street, satellite, terrain }

/// Real-World Interactive Township Map
/// Features real Sime Darby Property residential sites (Bandar Bukit Raja, City of Elmina, Ara Damansara, etc.),
/// Live Smart Bins (with Golden Mystery Bin), Grab-style Live Collector Buggies, and AR Wayfinder.
class TownshipMapScreen extends StatefulWidget {
  const TownshipMapScreen({super.key});

  @override
  State<TownshipMapScreen> createState() => _TownshipMapScreenState();
}

class _TownshipMapScreenState extends State<TownshipMapScreen> {
  SmartBinLocation? _selectedBin;
  bool _showBuggyDetail = false;
  bool _showTerritoryOverlay = false;
  bool _isArWayfinderActive = false;
  MapLayerStyle _layerStyle = MapLayerStyle.street;
  String _filter = 'All';

  void _showTownshipSelector(BuildContext context) {
    final state = TownshipState.instance;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Sime Darby Property Township',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Real-world residential sites from the official SDP portfolio',
              style: TextStyle(fontSize: 11, color: AppColors.grey),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.townships.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = state.townships[i];
                  final isSel = t.id == state.selectedTownship.id;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isSel ? AppColors.primary : AppColors.tint,
                      child: Icon(Icons.location_city_rounded, color: isSel ? Colors.white : AppColors.primary, size: 20),
                    ),
                    title: Text(t.name, style: TextStyle(fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, fontSize: 14)),
                    subtitle: Text('${t.state} • ${t.prominentFeature}', style: const TextStyle(fontSize: 11)),
                    trailing: isSel ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                    onTap: () {
                      state.selectTownship(t);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final township = state.selectedTownship;
        final buggy = state.buggy;
        final bins = state.bins.where((b) {
          if (_filter == 'Available') return b.fillPercentage < 65;
          if (_filter == 'Alert (>90%)') return b.fillPercentage >= 90;
          if (_filter == 'Mystery Bin') return b.isGoldenMysteryBin;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFE8F0E6),
          appBar: AppBar(
            title: InkWell(
              onTap: () => _showTownshipSelector(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(township.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                        ],
                      ),
                      Text('${township.state} • Live GIS Map', style: const TextStyle(fontSize: 10, color: AppColors.tint)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showTerritoryOverlay ? Icons.flag_rounded : Icons.flag_outlined,
                  color: _showTerritoryOverlay ? Colors.amber : Colors.white,
                ),
                tooltip: 'Jalan vs Jalan Street Rivalry',
                onPressed: () => setState(() => _showTerritoryOverlay = !_showTerritoryOverlay),
              ),
              IconButton(
                icon: const Icon(Icons.shield_rounded, color: Color(0xFFFFD54F)),
                tooltip: 'Community Boss Battle',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BossBattleScreen()),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main Map Canvas
              Positioned.fill(
                child: InteractiveViewer(
                  maxScale: 3.0,
                  minScale: 0.7,
                  // Markers are positioned against the same box the map is painted in, so they sit on their landmarks.
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mapSize = constraints.biggest;
                      return Stack(
                        children: [
                          // Detailed Real-World Township Painter
                          CustomPaint(
                            size: Size.infinite,
                            painter: _DetailedTownshipMapPainter(
                              showTerritoryColoring: _showTerritoryOverlay,
                              streets: state.streetRivalries,
                              layerStyle: _layerStyle,
                              townshipName: township.name,
                            ),
                          ),

                          // Live Collector Buggy Marker (Grab-Style GPS Tracking)
                          Positioned(
                            left: mapSize.width * buggy.xRatio - 22,
                            top: mapSize.height * buggy.yRatio - 22,
                            child: GestureDetector(
                              onTap: () => setState(() => _showBuggyDetail = true),
                              child: _BuggyMarker(
                                buggy: buggy,
                                isSummoned: state.isBuggySummoned,
                              ),
                            ),
                          ),

                          // Community Boss Raid Marker on Central Park
                          Positioned(
                            left: mapSize.width * 0.33 - 36,
                            top: mapSize.height * 0.45 - 34,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const BossBattleScreen()),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7B1FA2),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          state.isBossOnCooldown ? Icons.timer_outlined : Icons.warning_amber_rounded,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          state.isBossOnCooldown ? 'RESPAWN ${formatCountdown(state.bossRespawnRemaining)}' : 'RAID BOSS',
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A148C),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.amber, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF7B1FA2).withValues(alpha: 0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.pest_control_rounded, color: Colors.white, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Smart Bins Pins (with Golden Mystery Bin highlighted!)
                          for (final bin in bins)
                            Positioned(
                              left: mapSize.width * bin.xRatio - 18,
                              top: mapSize.height * bin.yRatio - 18,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedBin = bin;
                                  _showBuggyDetail = false;
                                }),
                                child: _SmartBinPin(bin: bin, isSelected: _selectedBin?.id == bin.id),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // AR Wayfinder Fullscreen Overlay Mode
              if (_isArWayfinderActive)
                Positioned.fill(
                  child: _ArWayfinderOverlay(
                    nearestBin: bins.first,
                    onClose: () => setState(() => _isArWayfinderActive = false),
                  ),
                ),

              // Top Filters, Township Badge and Layer Style
              if (!_isArWayfinderActive)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'All Bins (${state.bins.length})',
                                    isSelected: _filter == 'All',
                                    onTap: () => setState(() => _filter = 'All'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: '✨ Golden Mystery',
                                    isSelected: _filter == 'Mystery Bin',
                                    onTap: () => setState(() => _filter = 'Mystery Bin'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: '🟢 Available (<65%)',
                                    isSelected: _filter == 'Available',
                                    onTap: () => setState(() => _filter = 'Available'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: '🔴 Alert (>90%)',
                                    isSelected: _filter == 'Alert (>90%)',
                                    onTap: () => setState(() => _filter = 'Alert (>90%)'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Map Layers Button (Street vs Satellite vs Terrain)
                          PopupMenuButton<MapLayerStyle>(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                              child: const Icon(Icons.layers_rounded, color: AppColors.primary, size: 20),
                            ),
                            onSelected: (style) => setState(() => _layerStyle = style),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: MapLayerStyle.street, child: Text('🗺️ Google Street Map')),
                              PopupMenuItem(value: MapLayerStyle.satellite, child: Text('🛰️ Satellite Aerial View')),
                              PopupMenuItem(value: MapLayerStyle.terrain, child: Text('⛰️ Eco-Terrain & Trails')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Territorial Rivalry Banner
                      if (_showTerritoryOverlay)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Jalan Makmur leads! 10% point boost active • BBQ prize',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _showTerritoryOverlay = false),
                                child: const Icon(Icons.close, color: Colors.white70, size: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              // Floating AR Wayfinder Button
              if (!_isArWayfinderActive)
                Positioned(
                  right: 16,
                  bottom: _selectedBin != null || _showBuggyDetail ? 210 : 24,
                  child: FloatingActionButton.extended(
                    heroTag: 'ar_wayfinder_btn',
                    onPressed: () => setState(() => _isArWayfinderActive = true),
                    backgroundColor: AppColors.dark,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.view_in_ar_rounded, color: Colors.greenAccent),
                    label: const Text('AR Wayfinder', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),

              // Bottom Drawer 1: Live Collector Buggy Details
              if (_showBuggyDetail && !_isArWayfinderActive)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _BuggyDetailCard(
                    buggy: buggy,
                    isSummoned: state.isBuggySummoned,
                    onSummon: () => state.summonBuggyToGate(),
                    onCancel: () => state.cancelBuggySummon(),
                    onClose: () => setState(() => _showBuggyDetail = false),
                    onOpenPickupScreen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PickupRequestScreen()),
                      );
                    },
                  ),
                ),

              // Bottom Drawer 2: Selected Smart Bin Card
              if (_selectedBin != null && !_showBuggyDetail && !_isArWayfinderActive)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _BinDetailCard(
                    bin: _selectedBin!,
                    onClose: () => setState(() => _selectedBin = null),
                    onScan: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dark : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.white : AppColors.dark,
          ),
        ),
      ),
    );
  }
}

class _BuggyMarker extends StatelessWidget {
  const _BuggyMarker({required this.buggy, required this.isSummoned});

  final CollectorBuggy buggy;
  final bool isSummoned;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSummoned ? Colors.amber.shade900 : const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSummoned ? Icons.bolt_rounded : Icons.electric_rickshaw_rounded, color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text(
                isSummoned ? 'ETA ${buggy.etaMinutes}m' : buggy.name,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSummoned ? Colors.amber : const Color(0xFF43A047),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: (isSummoned ? Colors.amber : Colors.green).withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.electric_car_rounded, color: isSummoned ? Colors.black : Colors.white, size: 24),
        ),
      ],
    );
  }
}

class _SmartBinPin extends StatelessWidget {
  const _SmartBinPin({required this.bin, required this.isSelected});

  final SmartBinLocation bin;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = bin.statusColor;
    final isGold = bin.isGoldenMysteryBin;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isGold ? Colors.black : AppColors.dark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: isGold ? 2.0 : 1.5),
          ),
          child: Text(
            isGold ? '✨ GOLD' : '${bin.fillPercentage}%',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: isGold ? 42 : 36,
          height: isGold ? 42 : 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isGold ? 0.8 : 0.4),
                blurRadius: isGold ? 12 : (isSelected ? 8 : 4),
                spreadRadius: isGold ? 3 : 1,
              ),
            ],
          ),
          child: Icon(
            isGold ? Icons.auto_awesome : Icons.recycling_rounded,
            color: isGold ? Colors.black : AppColors.white,
            size: isGold ? 22 : 20,
          ),
        ),
      ],
    );
  }
}

class _BuggyDetailCard extends StatelessWidget {
  const _BuggyDetailCard({
    required this.buggy,
    required this.isSummoned,
    required this.onSummon,
    required this.onCancel,
    required this.onClose,
    required this.onOpenPickupScreen,
  });

  final CollectorBuggy buggy;
  final bool isSummoned;
  final VoidCallback onSummon;
  final VoidCallback onCancel;
  final VoidCallback onClose;
  final VoidCallback onOpenPickupScreen;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.electric_car_rounded, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buggy.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('${buggy.driverName} • Plate: ${buggy.plateNumber}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSummoned ? Colors.amber.shade50 : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSummoned ? Colors.amber : AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(isSummoned ? Icons.navigation_rounded : Icons.location_on_outlined, size: 18, color: isSummoned ? Colors.orange.shade800 : AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSummoned ? 'En route to your gate (ETA: ${buggy.etaMinutes} mins)' : 'Current: ${buggy.currentStreet}',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: isSummoned ? Colors.orange.shade900 : AppColors.dark),
                    ),
                  ),
                  Text('${buggy.batteryPercent}% ⚡', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (!isSummoned)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSummon,
                      icon: const Icon(Icons.hail_rounded),
                      label: const Text('Summon to My Gate'),
                    ),
                  )
                else ...[
                  Expanded(
                    child: OutlinedButton(onPressed: onCancel, child: const Text('Cancel Request')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(onPressed: onOpenPickupScreen, child: const Text('Dispatch Details')),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BinDetailCard extends StatelessWidget {
  const _BinDetailCard({required this.bin, required this.onClose, required this.onScan});

  final SmartBinLocation bin;
  final VoidCallback onClose;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final isCritical = bin.fillPercentage >= 90;
    final isGold = bin.isGoldenMysteryBin;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bin.statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isGold ? Icons.auto_awesome : Icons.sensors_rounded, color: isGold ? Colors.orange.shade800 : bin.statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bin.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('${bin.precinct} • ${bin.distanceMeters}m away', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose),
              ],
            ),
            const SizedBox(height: 12),
            if (isGold) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber)),
                child: const Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'MYSTERY GOLDEN BIN ACTIVE! Grants 2x Points + Higher ✨ Shiny Pokémon Egg Hatch Rate!',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fill Capacity: ${bin.fillPercentage}%', style: TextStyle(fontWeight: FontWeight.w700, color: bin.statusColor, fontSize: 12)),
                            Text(bin.statusText, style: TextStyle(fontSize: 11, color: bin.statusColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: bin.fillPercentage / 100.0,
                            backgroundColor: AppColors.divider,
                            color: bin.statusColor,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isGold ? Colors.amber.shade800 : (isCritical ? AppColors.grey : AppColors.primary),
                ),
                onPressed: onScan,
                icon: const Icon(Icons.directions_walk_rounded),
                label: Text(isGold ? 'Walk Here & Claim Golden Drop!' : 'Walk Here & Earn 2x Active Mobility Points!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArWayfinderOverlay extends StatelessWidget {
  const _ArWayfinderOverlay({required this.nearestBin, required this.onClose});

  final SmartBinLocation nearestBin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, size: 68, color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: Column(
                      children: [
                        const Text('AR WAYFINDER ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        const Text('Walk 140m straight down Jalan Makmur 3', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Destination: ${nearestBin.name}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28), onPressed: onClose),
            ),
          ],
        ),
      ),
    );
  }
}

/// Colours for one map layer style.
class _MapPalette {
  const _MapPalette({
    required this.land,
    required this.block,
    required this.house,
    required this.park,
    required this.tree,
    required this.water,
    required this.waterEdge,
    required this.road,
    required this.roadCasing,
    required this.highway,
    required this.highwayCasing,
    required this.building,
    required this.paved,
    required this.label,
    required this.halo,
    required this.waterLabel,
    required this.parkLabel,
  });

  final Color land, block, house, park, tree, water, waterEdge, road, roadCasing, highway, highwayCasing, building, paved;
  final Color label, halo, waterLabel, parkLabel;

  static const street = _MapPalette(
    land: Color(0xFFF3F1EC),
    block: Color(0xFFE9E5DE),
    house: Color(0xFFDAD3C8),
    park: Color(0xFFCDE8C4),
    tree: Color(0xFF9CCB92),
    water: Color(0xFFAAD3F0),
    waterEdge: Color(0xFF86BEE3),
    road: Colors.white,
    roadCasing: Color(0xFFD3CFC7),
    highway: Color(0xFFFFD27F),
    highwayCasing: Color(0xFFE5A94A),
    building: Color(0xFFD8C2AC),
    paved: Color(0xFFF1E6DA),
    label: Color(0xFF4A5560),
    halo: Colors.white,
    waterLabel: Color(0xFF2F6E96),
    parkLabel: Color(0xFF3B7536),
  );

  static const satellite = _MapPalette(
    land: Color(0xFF34402F),
    block: Color(0xFF414C3B),
    house: Color(0xFF7A776E),
    park: Color(0xFF29482D),
    tree: Color(0xFF1E3A22),
    water: Color(0xFF1E3F55),
    waterEdge: Color(0xFF2E5974),
    road: Color(0xFF8C8A84),
    roadCasing: Color(0xFF5B5A55),
    highway: Color(0xFFA9A395),
    highwayCasing: Color(0xFF6E6A61),
    building: Color(0xFF8F8A80),
    paved: Color(0xFF5E5F57),
    label: Colors.white,
    halo: Color(0xCC1B2418),
    waterLabel: Color(0xFFB3E5FC),
    parkLabel: Color(0xFFC5E1A5),
  );

  static const terrain = _MapPalette(
    land: Color(0xFFEDE5D3),
    block: Color(0xFFE3D9C4),
    house: Color(0xFFD2C4A9),
    park: Color(0xFFC4DCAC),
    tree: Color(0xFF93BC77),
    water: Color(0xFF9FCBE3),
    waterEdge: Color(0xFF7DB4D3),
    road: Color(0xFFFFFBF2),
    roadCasing: Color(0xFFC9BBA0),
    highway: Color(0xFFF5C77A),
    highwayCasing: Color(0xFFD29A45),
    building: Color(0xFFCDB494),
    paved: Color(0xFFE8DCC6),
    label: Color(0xFF5D4B37),
    halo: Color(0xFFF7F1E3),
    waterLabel: Color(0xFF2F6E96),
    parkLabel: Color(0xFF3F6B2C),
  );

  static _MapPalette of(MapLayerStyle style) => switch (style) {
        MapLayerStyle.street => street,
        MapLayerStyle.satellite => satellite,
        MapLayerStyle.terrain => terrain,
      };
}

/// Illustrated township plan: road hierarchy, housing precincts with house lots, Central Park, lake promenade,
/// plaza, sports clubhouse and orchard. Landmark positions line up with the marker ratios in [TownshipState].
class _DetailedTownshipMapPainter extends CustomPainter {
  _DetailedTownshipMapPainter({
    required this.showTerritoryColoring,
    required this.streets,
    required this.layerStyle,
    required this.townshipName,
  });

  final bool showTerritoryColoring;
  final List<StreetTerritory> streets;
  final MapLayerStyle layerStyle;
  final String townshipName;

  late Size _size;
  late _MapPalette _c;

  Offset _p(double x, double y) => Offset(_size.width * x, _size.height * y);
  Rect _r(double l, double t, double r, double b) => Rect.fromPoints(_p(l, t), _p(r, b));

  // Housing precincts, keyed by the street rivalry they belong to.
  static const _precinctBlocks = <String, List<List<double>>>{
    'Harmoni': [
      [0.03, 0.37, 0.195, 0.505],
    ],
    'Sejahtera': [
      [0.665, 0.335, 0.97, 0.505],
    ],
    'Makmur': [
      [0.445, 0.58, 0.60, 0.80],
    ],
    'Aman': [
      [0.02, 0.86, 0.29, 0.99],
      [0.33, 0.86, 0.60, 0.99],
      [0.665, 0.86, 0.97, 0.99],
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    _c = _MapPalette.of(layerStyle);

    canvas.drawRect(Offset.zero & size, Paint()..color = _c.land);
    if (layerStyle == MapLayerStyle.terrain) _drawContours(canvas);

    for (final blocks in _precinctBlocks.values) {
      for (final b in blocks) {
        _drawHousingBlock(canvas, _r(b[0], b[1], b[2], b[3]));
      }
    }
    _drawOrchard(canvas, _r(0.03, 0.19, 0.195, 0.335));
    _drawCentralPark(canvas);
    _drawLake(canvas);
    _drawLakesideDeck(canvas, _r(0.015, 0.60, 0.10, 0.79));
    _drawPlaza(canvas, _r(0.665, 0.19, 0.97, 0.29));
    _drawSportsClub(canvas, _r(0.70, 0.59, 0.97, 0.80));
    if (showTerritoryColoring) _drawTerritories(canvas);
    _drawRoads(canvas);
    _drawLabels(canvas);
    _drawCompassAndScale(canvas);
  }

  void _drawContours(Canvas canvas) {
    final contour = Paint()
      ..color = const Color(0xFFB89F7A).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final hill in [_p(0.88, 0.42), _p(0.08, 0.93)]) {
      for (var i = 1; i <= 5; i++) {
        canvas.drawOval(Rect.fromCenter(center: hill, width: 46.0 * i, height: 30.0 * i), contour);
      }
    }
  }

  void _drawHousingBlock(Canvas canvas, Rect rect) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = _c.block);

    // Rows of terrace-house lots, two rows back-to-back with a service lane between pairs.
    final housePaint = Paint()..color = _c.house;
    const lotW = 9.0, lotH = 7.0, gap = 2.0, lane = 6.0;
    final inner = rect.deflate(5);
    canvas.save();
    canvas.clipRect(inner);
    var row = 0;
    for (var y = inner.top; y + lotH <= inner.bottom; y += lotH + (row.isOdd ? lane : gap)) {
      for (var x = inner.left; x + lotW <= inner.right; x += lotW + gap) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, lotW, lotH), const Radius.circular(1.5)), housePaint);
      }
      row++;
    }
    canvas.restore();
  }

  void _drawTrees(Canvas canvas, Rect area, int count, int seed) {
    final rnd = math.Random(seed);
    final treePaint = Paint()..color = _c.tree;
    for (var i = 0; i < count; i++) {
      final o = Offset(area.left + rnd.nextDouble() * area.width, area.top + rnd.nextDouble() * area.height);
      canvas.drawCircle(o, 2.5 + rnd.nextDouble() * 2.5, treePaint);
    }
  }

  void _drawOrchard(Canvas canvas, Rect rect) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), Paint()..color = _c.park);
    final treePaint = Paint()..color = _c.tree;
    for (var y = rect.top + 10; y < rect.bottom - 6; y += 11) {
      for (var x = rect.left + 9; x < rect.right - 6; x += 11) {
        canvas.drawCircle(Offset(x, y), 3.2, treePaint);
      }
    }
  }

  void _drawCentralPark(Canvas canvas) {
    final park = Path()
      ..moveTo(_size.width * 0.26, _size.height * 0.215)
      ..cubicTo(_size.width * 0.40, _size.height * 0.195, _size.width * 0.52, _size.height * 0.20, _size.width * 0.585, _size.height * 0.23)
      ..cubicTo(_size.width * 0.60, _size.height * 0.33, _size.width * 0.60, _size.height * 0.43, _size.width * 0.575, _size.height * 0.50)
      ..cubicTo(_size.width * 0.46, _size.height * 0.515, _size.width * 0.33, _size.height * 0.51, _size.width * 0.245, _size.height * 0.49)
      ..cubicTo(_size.width * 0.235, _size.height * 0.40, _size.width * 0.235, _size.height * 0.30, _size.width * 0.26, _size.height * 0.215)
      ..close();
    canvas.drawPath(park, Paint()..color = _c.park);

    canvas.save();
    canvas.clipPath(park);
    _drawTrees(canvas, _r(0.23, 0.20, 0.60, 0.52), 70, 7);

    // Pond and winding footpaths.
    canvas.drawOval(Rect.fromCenter(center: _p(0.53, 0.45), width: _size.width * 0.07, height: _size.height * 0.035), Paint()..color = _c.water);
    final footpath = Paint()
      ..color = _c.paved
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(_size.width * 0.24, _size.height * 0.36)
        ..cubicTo(_size.width * 0.34, _size.height * 0.26, _size.width * 0.44, _size.height * 0.46, _size.width * 0.60, _size.height * 0.34),
      footpath,
    );
    canvas.drawPath(
      Path()
        ..moveTo(_size.width * 0.42, _size.height * 0.20)
        ..cubicTo(_size.width * 0.38, _size.height * 0.32, _size.width * 0.50, _size.height * 0.40, _size.width * 0.46, _size.height * 0.52),
      footpath,
    );
    canvas.restore();
  }

  void _drawLake(Canvas canvas) {
    final lake = Path()
      ..moveTo(_size.width * 0.13, _size.height * 0.66)
      ..cubicTo(_size.width * 0.14, _size.height * 0.60, _size.width * 0.30, _size.height * 0.585, _size.width * 0.38, _size.height * 0.615)
      ..cubicTo(_size.width * 0.45, _size.height * 0.64, _size.width * 0.42, _size.height * 0.73, _size.width * 0.35, _size.height * 0.76)
      ..cubicTo(_size.width * 0.26, _size.height * 0.80, _size.width * 0.12, _size.height * 0.75, _size.width * 0.13, _size.height * 0.66)
      ..close();

    // Wetland margin and promenade trail around the shore.
    final margin = lake.transform((Matrix4.identity()
          ..translateByDouble(_size.width * 0.275, _size.height * 0.69, 0, 1)
          ..scaleByDouble(1.16, 1.18, 1, 1)
          ..translateByDouble(-_size.width * 0.275, -_size.height * 0.69, 0, 1))
        .storage);
    canvas.drawPath(margin, Paint()..color = _c.park);
    _drawDashedPath(
      canvas,
      margin,
      Paint()
        ..color = _c.paved
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.drawPath(lake, Paint()..color = _c.water);
    canvas.drawPath(
      lake,
      Paint()
        ..color = _c.waterEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  /// Paved promenade deck on the lake's west shore (home of the Lake Promenade smart bin), with a boardwalk jetty.
  void _drawLakesideDeck(Canvas canvas, Rect rect) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), Paint()..color = _c.paved);
    final boardwalk = Paint()
      ..color = _c.building
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(rect.right - 2, rect.center.dy + rect.height * 0.22), _p(0.18, 0.74), boardwalk);
  }

  void _drawPlaza(Canvas canvas, Rect rect) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = _c.paved);
    final buildingPaint = Paint()..color = _c.building;
    final w = rect.width, h = rect.height;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + w * 0.05, rect.top + h * 0.12, w * 0.38, h * 0.50), const Radius.circular(3)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + w * 0.50, rect.top + h * 0.12, w * 0.20, h * 0.34), const Radius.circular(3)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + w * 0.76, rect.top + h * 0.12, w * 0.19, h * 0.34), const Radius.circular(3)), buildingPaint);

    // Car park bays.
    final bay = Paint()
      ..color = _c.roadCasing
      ..strokeWidth = 1;
    final bayTop = rect.top + h * 0.66;
    for (var x = rect.left + w * 0.05; x < rect.right - 4; x += 6) {
      canvas.drawLine(Offset(x, bayTop), Offset(x, bayTop + h * 0.24), bay);
    }
  }

  void _drawSportsClub(Canvas canvas, Rect rect) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), Paint()..color = _c.park);
    final field = Rect.fromCenter(center: rect.center.translate(0, rect.height * 0.08), width: rect.width * 0.72, height: rect.height * 0.62);
    canvas.drawRect(field, Paint()..color = _c.tree.withValues(alpha: 0.75));
    final lines = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(field.deflate(3), lines);
    canvas.drawLine(Offset(field.center.dx, field.top + 3), Offset(field.center.dx, field.bottom - 3), lines);
    canvas.drawCircle(field.center, field.height * 0.16, lines);
    // Clubhouse building.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + rect.width * 0.08, rect.top + 5, rect.width * 0.30, rect.height * 0.11), const Radius.circular(3)),
      Paint()..color = _c.building,
    );
  }

  void _drawTerritories(Canvas canvas) {
    for (final street in streets) {
      final key = _precinctBlocks.keys.firstWhere((k) => street.streetName.contains(k), orElse: () => '');
      final blocks = _precinctBlocks[key];
      if (blocks == null) continue;
      for (final b in blocks) {
        final rrect = RRect.fromRectAndRadius(_r(b[0], b[1], b[2], b[3]).inflate(3), const Radius.circular(8));
        canvas.drawRRect(rrect, Paint()..color = street.color.withValues(alpha: street.isLeader ? 0.38 : 0.26));
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = street.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = street.isLeader ? 2.5 : 1.5,
        );
      }
    }
  }

  void _drawRoad(Canvas canvas, Path path, double width, {bool highway = false}) {
    canvas.drawPath(
      path,
      Paint()
        ..color = highway ? _c.highwayCasing : _c.roadCasing
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = highway ? _c.highway : _c.road
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _line(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final o in points.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  void _drawRoads(Canvas canvas) {
    final w = _size.width, h = _size.height;

    // Local streets and cul-de-sacs first so the main roads sit on top of their junctions.
    final local = <Path>[
      _line([_p(0.31, 0.83), _p(0.31, 1.0)]),
      _line([_p(0.0, 0.925), _p(1.0, 0.925)]),
      _line([_p(0.635, 0.42), _p(0.93, 0.42)]),
      _line([_p(0.52, 0.545), _p(0.52, 0.77)]),
      _line([_p(0.03, 0.355), _p(0.215, 0.355)]),
    ];
    for (final path in local) {
      _drawRoad(canvas, path, 5);
    }
    for (final end in [_p(0.93, 0.42), _p(0.52, 0.77)]) {
      canvas.drawCircle(end, 6.5, Paint()..color = _c.roadCasing);
      canvas.drawCircle(end, 5, Paint()..color = _c.road);
    }

    _drawRoad(canvas, _line([_p(0.215, 0.16), _p(0.215, 0.545)]), 7); // Jalan Harmoni
    _drawRoad(canvas, _line([_p(0.635, 0.315), _p(1.0, 0.315)]), 7); // Jalan Sejahtera
    _drawRoad(canvas, _line([_p(0.0, 0.83), _p(1.0, 0.83)]), 8); // Jalan Aman
    _drawRoad(
      canvas,
      Path()
        ..moveTo(0, h * 0.548)
        ..quadraticBezierTo(w * 0.5, h * 0.535, w, h * 0.545),
      9,
    ); // Jalan Makmur
    _drawRoad(
      canvas,
      Path()
        ..moveTo(w * 0.625, h * 0.16)
        ..cubicTo(w * 0.64, h * 0.45, w * 0.625, h * 0.70, w * 0.64, h),
      10,
    ); // Persiaran Makmur
    _drawRoad(
      canvas,
      Path()
        ..moveTo(0, h * 0.165)
        ..quadraticBezierTo(w * 0.5, h * 0.13, w, h * 0.17),
      15,
      highway: true,
    ); // Persiaran Bukit Raja

    // Roundabout where Persiaran Makmur meets Jalan Makmur.
    final ring = _p(0.632, 0.541);
    canvas.drawCircle(ring, 15, Paint()..color = _c.roadCasing);
    canvas.drawCircle(ring, 13.5, Paint()..color = _c.road);
    canvas.drawCircle(ring, 6, Paint()..color = _c.park);
  }

  void _drawLabels(Canvas canvas) {
    final makmurLabel = showTerritoryColoring ? '👑 Jalan Makmur' : 'Jalan Makmur';

    // Road names, drawn along their roads.
    _drawText(canvas, _p(0.28, 0.152), 'PERSIARAN BUKIT RAJA', size: 9, angle: -0.035, spacing: 1.2);
    _drawText(canvas, _p(0.83, 0.541), makmurLabel, size: 9);
    _drawText(canvas, _p(0.46, 0.83), 'Jalan Aman', size: 9);
    _drawText(canvas, _p(0.82, 0.315), 'Jalan Sejahtera', size: 8.5);
    _drawText(canvas, _p(0.215, 0.43), 'Jalan Harmoni', size: 8.5, angle: -math.pi / 2);
    _drawText(canvas, _p(0.635, 0.70), 'Persiaran Makmur', size: 8.5, angle: -math.pi / 2);

    // Places.
    _drawText(canvas, _p(0.42, 0.235), '$townshipName Central Park', size: 10.5, color: _c.parkLabel, bold: true);
    _drawText(canvas, _p(0.27, 0.70), 'Wetlands & Lake', size: 10, color: _c.waterLabel, bold: true, italic: true);
    _drawText(canvas, _p(0.115, 0.205), 'Community Orchard', size: 8.5, color: _c.parkLabel, bold: true);
    _drawText(canvas, _p(0.815, 0.278), 'Sime Darby Gallery & Plaza', size: 8.5, bold: true);
    _drawText(canvas, _p(0.835, 0.61), 'Sports Clubhouse', size: 8.5, color: _c.parkLabel, bold: true);

    // Precincts.
    _drawText(canvas, _p(0.11, 0.47), 'PRECINCT 1', size: 8, spacing: 1.5, faded: true);
    _drawText(canvas, _p(0.82, 0.47), 'PRECINCT 2', size: 8, spacing: 1.5, faded: true);
    _drawText(canvas, _p(0.48, 0.79), 'PRECINCT 3', size: 8, spacing: 1.5, faded: true);
    _drawText(canvas, _p(0.46, 0.965), 'PRECINCT 4', size: 8, spacing: 1.5, faded: true);
  }

  void _drawText(
    Canvas canvas,
    Offset at,
    String text, {
    double size = 10,
    Color? color,
    bool bold = false,
    bool italic = false,
    bool faded = false,
    double angle = 0,
    double spacing = 0,
  }) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: spacing,
    );
    final fill = TextPainter(
      text: TextSpan(text: text, style: style.copyWith(color: (color ?? _c.label).withValues(alpha: faded ? 0.55 : 1))),
      textDirection: TextDirection.ltr,
    )..layout();
    final halo = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeJoin = StrokeJoin.round
            ..color = _c.halo,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    final topLeft = Offset(-fill.width / 2, -fill.height / 2);
    if (!faded) halo.paint(canvas, topLeft);
    fill.paint(canvas, topLeft);
    canvas.restore();
  }

  void _drawCompassAndScale(Canvas canvas) {
    // North arrow, top-right below the filter chips.
    final center = Offset(_size.width - 30, 96);
    canvas.drawCircle(center, 15, Paint()..color = _c.halo.withValues(alpha: 0.9));
    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = _c.roadCasing
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - 11)
        ..lineTo(center.dx + 5, center.dy + 2)
        ..lineTo(center.dx - 5, center.dy + 2)
        ..close(),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy + 11)
        ..lineTo(center.dx + 5, center.dy + 2)
        ..lineTo(center.dx - 5, center.dy + 2)
        ..close(),
      Paint()..color = _c.label.withValues(alpha: 0.6),
    );
    _drawText(canvas, center.translate(0, -22), 'N', size: 9, bold: true);

    // Scale bar, bottom-left.
    final start = Offset(16, _size.height - 18);
    final bar = Paint()
      ..color = _c.label
      ..strokeWidth = 2;
    canvas.drawLine(start, start.translate(60, 0), bar);
    canvas.drawLine(start.translate(0, -4), start.translate(0, 2), bar);
    canvas.drawLine(start.translate(60, -4), start.translate(60, 2), bar);
    _drawText(canvas, start.translate(30, -9), '200 m', size: 8.5, bold: true);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 5, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedTownshipMapPainter oldDelegate) =>
      oldDelegate.showTerritoryColoring != showTerritoryColoring ||
      oldDelegate.layerStyle != layerStyle ||
      oldDelegate.townshipName != townshipName;
}
