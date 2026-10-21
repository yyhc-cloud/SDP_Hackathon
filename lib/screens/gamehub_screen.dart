import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../theme/app_colors.dart';
import 'games/candy_crush_game.dart';
import 'games/tetris_game.dart';
import 'games/water_plant_game.dart';
import 'guild_wars_screen.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F9),
          appBar: AppBar(
            title: const Text('Sime Darby Eco-GameHub'),
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.shield_rounded),
                tooltip: 'Guild Wars',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GuildWarsScreen()),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Play & Power Township Guilds',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Text(
                                'Game scores earn Green Points & War Power',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SummaryPill(
                            label: 'POINTS TODAY',
                            value: '+${state.totalGamePointsToday} pts',
                            color: Colors.amberAccent,
                          ),
                          _SummaryPill(
                            label: 'GUILD ALLIANCE',
                            value: 'Makmur (#1)',
                            color: Colors.lightGreenAccent,
                          ),
                          _SummaryPill(
                            label: 'ACTIVE PERK',
                            value: '2x Mobility',
                            color: Colors.cyanAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.gamepad_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Playable Eco Mini-Games',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.dark),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Game 1: WaterPlant
              _GameCard(
                title: 'WaterPlant • Wetland Nursery',
                subtitle: 'Tap arid nursery beds to spray recycled rainwater. Adjacent plots absorb spray mist to bloom blooming flowers!',
                iconEmoji: '🌸',
                headerGradient: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                highScore: state.waterPlantHighScore,
                badgeText: 'Wetland Irrigation Puzzle',
                rewardPerk: '+Grass Berries • Central Wetlands War Power',
                onPlay: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WaterPlantGame()),
                ),
              ),
              const SizedBox(height: 14),

              // Game 2: Candy Crush
              _GameCard(
                title: 'Candy Crush • Recyclables Match-3',
                subtitle: 'Swap adjacent sorted plastics, aluminium, e-waste, organics and glass to clear 3+ lines and trigger cascading combos!',
                iconEmoji: '♻️',
                headerGradient: const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                highScore: state.candyCrushHighScore,
                badgeText: 'Match-3 Cascades',
                rewardPerk: '+Water Berries • Solar Microgrid War Power',
                onPlay: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CandyCrushGame()),
                ),
              ),
              const SizedBox(height: 14),

              // Game 3: Tetris
              _GameCard(
                title: 'Tetris • Eco-Bale Compactor',
                subtitle: 'Stack and rotate compacted bales of recyclable materials. Clear horizontal rows to prevent landfill overflow!',
                iconEmoji: '📦',
                headerGradient: const [Color(0xFF006064), Color(0xFF00838F)],
                highScore: state.tetrisHighScore,
                badgeText: 'Falling Block Compactor',
                rewardPerk: '+Steel Berries • Bio-Compost Hub War Power',
                onPlay: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TetrisGame()),
                ),
              ),

              const SizedBox(height: 22),
              // Guild Wars Banner
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GuildWarsScreen()),
                ),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Neighbourhood Guild Wars',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bandar Bukit Raja vs City of Elmina vs Ara Damansara! See who controls the wetlands!',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Daily Quests
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Gaming Quests', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Resets in 7h', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _QuestTile(
                      title: 'Bloom 6 wetland plots in WaterPlant',
                      progress: 0.6,
                      progressText: '4 / 6 bloomed',
                      reward: '+30 pts',
                      isCompleted: false,
                    ),
                    const Divider(height: 16),
                    _QuestTile(
                      title: 'Score 800+ in Eco-Crush Match-3',
                      progress: 1.0,
                      progressText: 'Completed (950 pts)',
                      reward: '+50 pts',
                      isCompleted: true,
                    ),
                    const Divider(height: 16),
                    _QuestTile(
                      title: 'Compact 2 lines in Eco-Bale Tetris',
                      progress: 0.5,
                      progressText: '1 / 2 lines',
                      reward: '+40 pts',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.headerGradient,
    required this.highScore,
    required this.badgeText,
    required this.rewardPerk,
    required this.onPlay,
  });

  final String title;
  final String subtitle;
  final String iconEmoji;
  final List<Color> headerGradient;
  final int highScore;
  final String badgeText;
  final String rewardPerk;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: headerGradient),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(iconEmoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      Text(badgeText, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('Best: $highScore', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(rewardPerk, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerGradient.first,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: onPlay,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Play Mini-Game', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.title,
    required this.progress,
    required this.progressText,
    required this.reward,
    required this.isCompleted,
  });

  final String title;
  final double progress;
  final String progressText;
  final String reward;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : AppColors.dark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isCompleted ? Colors.green : Colors.amber),
              ),
              child: Text(
                isCompleted ? 'CLAIMED' : reward,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isCompleted ? Colors.green : Colors.amber.shade900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: isCompleted ? Colors.green : AppColors.primary,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(progressText, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }
}
