import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/landed_models.dart';
import '../models/pokemon_model.dart';
import '../theme/app_colors.dart';
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
                  child: Stack(
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
                        left: MediaQuery.of(context).size.width * buggy.xRatio - 22,
                        top: MediaQuery.of(context).size.height * buggy.yRatio - 22,
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
                        left: MediaQuery.of(context).size.width * 0.42,
                        top: MediaQuery.of(context).size.height * 0.28,
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
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 12),
                                    SizedBox(width: 3),
                                    Text(
                                      'RAID BOSS',
                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
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
                          left: MediaQuery.of(context).size.width * bin.xRatio - 18,
                          top: MediaQuery.of(context).size.height * bin.yRatio - 18,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedBin = bin;
                              _showBuggyDetail = false;
                            }),
                            child: _SmartBinPin(bin: bin, isSelected: _selectedBin?.id == bin.id),
                          ),
                        ),
                    ],
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

/// Detailed GIS Canvas Painter rendering real-world Sime Darby Property Townships
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

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background based on Layer Style
    if (layerStyle == MapLayerStyle.satellite) {
      final satBg = Paint()..color = const Color(0xFF2C3E2D);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), satBg);
    } else if (layerStyle == MapLayerStyle.terrain) {
      final terBg = Paint()..color = const Color(0xFFD7CCC8);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), terBg);
    } else {
      final stBg = Paint()..color = const Color(0xFFF1F3F4);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), stBg);
    }

    // 2. Real-World Residential Plots & Cul-de-Sacs
    final lotPaint = Paint()
      ..color = layerStyle == MapLayerStyle.satellite ? const Color(0xFF3E4E3F) : const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;

    for (double y = size.height * 0.12; y < size.height * 0.85; y += 70) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18, y, 75, 45), const Radius.circular(8)), lotPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 95, y, 75, 45), const Radius.circular(8)), lotPaint);
    }

    // 3. Central Park & Signature Lake
    final parkPaint = Paint()..color = layerStyle == MapLayerStyle.satellite ? const Color(0xFF1B3B1E) : const Color(0xFFC8E6C9);
    final lakePaint = Paint()..color = layerStyle == MapLayerStyle.satellite ? const Color(0xFF1A3B4A) : const Color(0xFFB3E5FC);

    final parkRect = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.38),
      width: size.width * 0.65,
      height: size.height * 0.30,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(parkRect, const Radius.circular(30)), parkPaint);

    final lakeRect = Rect.fromCenter(
      center: Offset(size.width * 0.28, size.height * 0.65),
      width: size.width * 0.40,
      height: size.height * 0.22,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(lakeRect, const Radius.circular(24)), lakePaint);

    // 4. Territory Mode Coloring (Splatoon Style)
    if (showTerritoryColoring) {
      final makmurZone = Paint()..color = const Color(0xFF1E88E5).withValues(alpha: 0.30);
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.55), 75, makmurZone);

      final harmoniZone = Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.25);
      canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.25), 65, harmoniZone);

      final sejahteraZone = Paint()..color = const Color(0xFFFFA000).withValues(alpha: 0.25);
      canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.65), 60, sejahteraZone);
    }

    // 5. Real-World Arterial Highway & Connecting Streets
    final highwayPaint = Paint()
      ..color = layerStyle == MapLayerStyle.satellite ? const Color(0xFF757575) : const Color(0xFFFFCC80)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final streetPaint = Paint()
      ..color = layerStyle == MapLayerStyle.satellite ? const Color(0xFF9E9E9E) : Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.20, size.width, size.height * 0.35);
    canvas.drawPath(road1, highwayPaint);

    final road2 = Path()
      ..moveTo(size.width * 0.35, 0)
      ..quadraticBezierTo(size.width * 0.40, size.height * 0.5, size.width * 0.75, size.height);
    canvas.drawPath(road2, streetPaint);

    // 6. Real-World Landmark Labels
    _drawLabel(canvas, Offset(size.width * 0.48, size.height * 0.35), '$townshipName Central Park');
    _drawLabel(canvas, Offset(size.width * 0.28, size.height * 0.62), 'Wetlands & Lake Promenade');
    _drawLabel(canvas, Offset(size.width * 0.35, size.height * 0.55), showTerritoryColoring ? '👑 Jalan Makmur (Rank 1)' : 'Jalan Makmur');
    _drawLabel(canvas, Offset(size.width * 0.78, size.height * 0.18), 'Sime Darby Gallery & Plaza');
  }

  void _drawLabel(Canvas canvas, Offset offset, String text) {
    final span = TextSpan(
      text: text,
      style: const TextStyle(color: Color(0xFF263238), fontSize: 11, fontWeight: FontWeight.w800),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DetailedTownshipMapPainter oldDelegate) =>
      oldDelegate.showTerritoryColoring != showTerritoryColoring ||
      oldDelegate.layerStyle != layerStyle ||
      oldDelegate.townshipName != townshipName;
}
