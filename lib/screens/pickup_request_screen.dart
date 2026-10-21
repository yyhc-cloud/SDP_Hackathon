import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/landed_models.dart';
import '../theme/app_colors.dart';
import 'scan_screen.dart';

/// Active Mobility: Self-Drop vs. Buggy Pickup Choice & Alternative Egg Hatching
class PickupRequestScreen extends StatelessWidget {
  const PickupRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final choice = state.disposalChoice;
        final buggy = state.buggy;
        final isSummoned = state.isBuggySummoned;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Active Mobility & Disposal'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Top explainer
              const Text(
                'Landed Resident Disposal Choice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how you want to recycle today. Walking earns the 2x Active Mobility Multiplier!',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              const SizedBox(height: 16),

              // Choice Option 1: Self-Drop (2x Multiplier)
              InkWell(
                onTap: () => state.setDisposalChoice(DisposalChoice.selfDropWalk),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: choice == DisposalChoice.selfDropWalk ? const Color(0xFFE8F5E9) : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: choice == DisposalChoice.selfDropWalk ? const Color(0xFF2E7D32) : AppColors.divider,
                      width: choice == DisposalChoice.selfDropWalk ? 2.5 : 1,
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Self-Drop (Walk / Cycle)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade800,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('2x MULTIPLIER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text('Walk to nearest neighborhood Smart Bin', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E6C9).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: Color(0xFF1B5E20), size: 18),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'GPS & pedometer verify your walk: +2x Points, +2x Pokémon Berries & instant egg hatch boost!',
                                style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Choice Option 2: Collector Buggy (Doorstep at Gate)
              InkWell(
                onTap: () => state.setDisposalChoice(DisposalChoice.collectorBuggy),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: choice == DisposalChoice.collectorBuggy ? const Color(0xFFFFF8E1) : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: choice == DisposalChoice.collectorBuggy ? Colors.orange.shade700 : AppColors.divider,
                      width: choice == DisposalChoice.collectorBuggy ? 2.5 : 1,
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.electric_car_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Collector Buggy (At Gate)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.divider,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('STANDARD 1x', style: TextStyle(color: AppColors.dark, fontSize: 10, fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text('Electric buggy picks up waste at your gate', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, color: Colors.orange, size: 18),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Collector or resident scans bag with the AI Scanner to verify sorting at the buggy.',
                                style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action button depending on choice
              if (choice == DisposalChoice.selfDropWalk) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                    icon: const Icon(Icons.directions_walk_rounded),
                    label: const Text('Open Scanner at Smart Bin (2x Points!)', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ] else ...[
                // Buggy Summoning Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gps_fixed_rounded, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isSummoned
                                  ? 'Buggy #02 En Route (ETA: ${buggy.etaMinutes} mins)'
                                  : 'Buggy #02 is cruising ${buggy.currentStreet}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (!isSummoned)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  state.summonBuggyToGate();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('🚗 Collector Buggy dispatched to your gate! ETA: 4 mins')),
                                  );
                                },
                                icon: const Icon(Icons.hail_rounded),
                                label: const Text('Summon Buggy to My Gate'),
                              ),
                            )
                          else ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => state.cancelBuggySummon(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                                  );
                                },
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Scan with Buggy'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Alternative Egg Hatching: Park Pedometer Sync
              const Text(
                'Alternative Egg Hatching via Township Parks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Using the buggy pickup? You can still hatch Pokémon eggs by walking within designated township green spaces and trails.',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              const SizedBox(height: 12),

              for (final trail in state.parkTrails)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.park_rounded, color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trail.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                '${trail.distanceKm} km loop • ${trail.stepsVerified} steps recorded today',
                                style: const TextStyle(fontSize: 11, color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                          onPressed: () {
                            final newlyHatched = state.syncTownshipParkSteps(1500);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(newlyHatched != null
                                    ? '🎉 Park steps hatched your ${newlyHatched.pokemonName}!'
                                    : '🌲 Synced +1,500 park steps! Egg incubator updated.'),
                              ),
                            );
                          },
                          child: const Text('Sync Steps'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
