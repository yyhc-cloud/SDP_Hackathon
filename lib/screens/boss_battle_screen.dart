import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/pokemon_model.dart';
import '../theme/app_colors.dart';
import '../widgets/cube_pet_image.dart';

/// Interactive Eco-Battle Arena with Type Advantages against Sludge-Hog Pollution Boss
class BossBattleScreen extends StatefulWidget {
  const BossBattleScreen({super.key});

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> with SingleTickerProviderStateMixin {
  String? _battleMessage;
  int? _lastDamage;
  bool _isAttacking = false;

  void _executeMove(PokemonMove move) async {
    if (_isAttacking) return;
    setState(() {
      _isAttacking = true;
      _lastDamage = null;
    });

    final damage = TownshipState.instance.attackBossWithCompanion(move);

    setState(() {
      _lastDamage = damage;
      if (move.multiplierAgainstPollution > 1.0) {
        _battleMessage = '✨ 1.5x SUPER EFFECTIVE! ${move.name} dealt $damage purifying damage to Sludge-Hog!';
      } else {
        _battleMessage = '💥 ${move.name} dealt $damage damage!';
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isAttacking = false;
    });

    if (TownshipState.instance.boss.isDefeated && mounted) {
      _showVictoryDialog(TownshipState.instance);
    }
  }

  void _showVictoryDialog(TownshipState state) {
    final dogPet = state.unlockGuardianDog();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1B0F2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.amber, width: 2),
        ),
        title: const Column(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 52),
            SizedBox(height: 8),
            Text(
              '🎉 VICTORY!',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 24),
            ),
            SizedBox(height: 4),
            Text(
              'SLUDGE-HOG HAS BEEN PURIFIED!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const CubePetImage(
                      imagePath: 'assets/kenny_cube/Previews/animal-dog.png',
                      height: 96,
                      width: 96,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🎁 WINNER REWARD UNLOCKED!',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dogPet.displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mythical Township Sanctuary Guardian',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Lv. 20 • HP 120 • ATK 95 • DEF 100 • +500 PTS',
                      style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Bandar Bukit Raja Central Park is saved. This mythical companion is now part of your collection!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.star_rounded, size: 18),
            label: const Text('Set as Active Companion 👑', style: TextStyle(fontWeight: FontWeight.w900)),
            onPressed: () {
              state.setActiveCompanion(dogPet);
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 ${dogPet.displayName} is now your active companion!')),
              );
            },
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Keep in Sanctuary & Return', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final boss = state.boss;
        final companion = state.activeCompanion;
        final moves = companion.moves.isNotEmpty
            ? companion.moves
            : [
                const PokemonMove(name: 'Vine Whip', type: 'grass', power: 45, multiplierAgainstPollution: 1.5, description: '1.5x Super Effective against toxic sludge!'),
                const PokemonMove(name: 'Tackle', type: 'normal', power: 35, multiplierAgainstPollution: 1.0, description: 'Direct physical strike.'),
              ];

        return Scaffold(
          backgroundColor: const Color(0xFF1B0F2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B0F2A),
            foregroundColor: AppColors.white,
            title: const Text('Interactive Raid Arena', style: TextStyle(color: AppColors.white)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${boss.daysRemaining} days left',
                      style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              // Boss Battle Stage Arena
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF33134D), Color(0xFF4A148C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    // Boss Status Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              boss.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                            ),
                            Text(
                              'Target: ${boss.locationName}',
                              style: const TextStyle(color: Color(0xFFCE93D8), fontSize: 11),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)),
                          child: const Text('POISON / SLUDGE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Boss HP Gauge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Raid HP: ${boss.bossCurrentHp} / ${boss.bossMaxHp}', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('${(boss.hpRatio * 100).toInt()}% Remaining', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: boss.hpRatio,
                        color: Colors.amber,
                        backgroundColor: Colors.white12,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Battle Visual Arena (Boss vs Companion)
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Boss (Right Side)
                          Positioned(
                            right: 14,
                            top: 10,
                            child: AnimatedScale(
                              scale: _isAttacking ? 0.92 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: CubePetImage(
                                imagePath: boss.bossAsset,
                                height: 130,
                              ),
                            ),
                          ),

                          // Companion (Left Side / Attacker)
                          Positioned(
                            left: 14,
                            bottom: 10,
                            child: AnimatedSlide(
                              offset: _isAttacking ? const Offset(0.25, -0.15) : Offset.zero,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CubePetImage(
                                    imagePath: companion.activeArtwork,
                                    height: 100,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      '${companion.displayName} (You)',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating Damage Pop
                          if (_lastDamage != null)
                            Positioned(
                              top: 20,
                              right: 60,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                                ),
                                child: Text(
                                  '-$_lastDamage HP!',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Combat Announcer / Battle Feedback
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _battleMessage ??
                            'Select an elemental move! Grass-types deal 1.5x Purifying Damage against Sludge-Hog.',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Companion Attack Moves (with Type Advantages)
              const Text(
                'Companion Elemental Tactics (Tap to Attack)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 10),

              for (final move in moves)
                _MoveAttackCard(
                  move: move,
                  isAttacking: _isAttacking,
                  onAttack: () => _executeMove(move),
                ),
              const SizedBox(height: 16),

              // Victory Reward Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.8), width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const CubePetImage(
                        imagePath: 'assets/kenny_cube/Previews/animal-dog.png',
                        width: 52,
                        height: 52,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'WINNER REWARD • GET A NEW PET!',
                                style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text('Forest Guardian Dog (Mythical)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('The winner who finishes off Sludge-Hog wins this new companion + 500 Green Points!', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
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

class _MoveAttackCard extends StatelessWidget {
  const _MoveAttackCard({required this.move, required this.isAttacking, required this.onAttack});

  final PokemonMove move;
  final bool isAttacking;
  final VoidCallback onAttack;

  @override
  Widget build(BuildContext context) {
    final isSuper = move.multiplierAgainstPollution > 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF2B1B3D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSuper ? const BorderSide(color: Colors.greenAccent, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: isAttacking ? null : onAttack,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSuper ? const Color(0xFF4CAF50).withValues(alpha: 0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuper ? Icons.grass_rounded : Icons.flash_on_rounded,
                  color: isSuper ? Colors.greenAccent : Colors.amber,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(move.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                        if (isSuper) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(6)),
                            child: const Text('1.5x SUPER EFFECTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(move.description, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isAttacking ? Colors.white24 : (isSuper ? Colors.greenAccent : Colors.amber),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (isSuper ? Colors.greenAccent : Colors.amber).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  'ATTACK',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
