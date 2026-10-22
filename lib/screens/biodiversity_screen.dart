import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/pokemon_model.dart';
import '../services/poke_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/cube_pet_image.dart';

class BiodiversityScreen extends StatefulWidget {
  const BiodiversityScreen({super.key});

  @override
  State<BiodiversityScreen> createState() => _BiodiversityScreenState();
}

class _BiodiversityScreenState extends State<BiodiversityScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Biodiversity Sanctuary'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.pets_rounded), text: 'Companion & Evolution'),
                Tab(icon: Icon(Icons.directions_walk_rounded), text: 'Hatch Eggs'),
                Tab(icon: Icon(Icons.auto_stories_rounded), text: 'Town Pet-Dex'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _ArCompanionTab(state: state),
              _EggIncubatorTab(state: state),
              _FullPokedexTab(state: state),
            ],
          ),
        );
      },
    );
  }
}

/// Tab 1: AR Companion, Feeding, Switcher & Multi-Stage Evolution Tree
class _ArCompanionTab extends StatefulWidget {
  const _ArCompanionTab({required this.state});
  final TownshipState state;

  @override
  State<_ArCompanionTab> createState() => _ArCompanionTabState();
}

class _ArCompanionTabState extends State<_ArCompanionTab> {
  bool _isArActive = false;
  String _statusMessage = 'Feed Eco-Berries or Train to Level Up and trigger Evolution!';

  void _feedBerry(EcoMaterialType type) {
    final success = widget.state.feedCompanion(type);
    final companion = widget.state.activeCompanion;
    setState(() {
      if (success) {
        _statusMessage = '❤️ ${companion.displayName} loved the ${type.label} berry! (+35 EXP & +1 Evolution progress)';
      } else {
        _statusMessage = 'Recycle more ${type.label} at Smart Bins to earn berries!';
      }
    });

    if (success && companion.canEvolve && !companion.hasDeclinedEvolution && mounted) {
      _showEvolutionChoiceDialog(companion);
    }
  }

  void _trainCompanion() {
    final companion = widget.state.activeCompanion;
    final readyForEvolution = widget.state.gainCompanionExp(35);
    setState(() {
      _statusMessage = '⚡ ${companion.displayName} trained hard! (+35 EXP, now Lv. ${widget.state.activeCompanion.level})';
    });
    if (readyForEvolution && mounted) {
      _showEvolutionChoiceDialog(widget.state.activeCompanion);
    }
  }

  void _showEvolutionChoiceDialog(PokemonData companion) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Evolution Ready: Lv. ${companion.level}!',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CubePetImage(
                    imagePath: companion.activeArtwork,
                    width: 70,
                    height: 70,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.orange, size: 28),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CubePetImage(
                    imagePath: PokeApiService.getPetAsset(companion.evolvesToId),
                    width: 70,
                    height: 70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${companion.displayName} has reached Level ${companion.level} and is eligible to evolve into ${companion.evolvesToName}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can choose to evolve now (+100 Green Points & upgraded stats), OR choose "No Need" to keep your Cube Pet in its current form.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.state.declineEvolution(companion);
              ScaffoldMessenger.of(context).showLatestSnackBar(
                SnackBar(
                  content: Text('Kept ${companion.displayName} in current form! You can evolve it anytime from the Evolution Tree.'),
                ),
              );
            },
            child: const Text('No Need (Keep Current Form)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () {
              Navigator.of(ctx).pop();
              _triggerEvolution(companion);
            },
            icon: const Icon(Icons.auto_awesome),
            label: Text('Evolve to ${companion.evolvesToName}!', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _triggerEvolution(PokemonData companion) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('✨ WHAT? CUBE PET IS EVOLVING!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 48),
            const SizedBox(height: 12),
            Text(
              '${companion.displayName} is evolving into ${companion.evolvesToName}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop(); // close dialog

    final success = await widget.state.evolvePokemon(companion);
    if (success && mounted) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 EVOLUTION COMPLETE!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CubePetImage(
                imagePath: widget.state.activeCompanion.activeArtwork,
                height: 120,
              ),
              const SizedBox(height: 10),
              Text(
                'Congratulations! Your companion is now ${widget.state.activeCompanion.displayName}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text('+100 Green Points & Upgraded Attack Power!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Awesome!')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companion = widget.state.activeCompanion;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 1. My Owned Pokémon (Switch Companion) Section
        _OwnedPokemonSwitcher(
          state: widget.state,
          onSelected: (p) {
            widget.state.setActiveCompanion(p);
            ScaffoldMessenger.of(context).showLatestSnackBar(
              SnackBar(content: Text('Switched active companion to ${p.displayName}!')),
            );
          },
        ),
        const SizedBox(height: 16),

        // 2. Active Companion AR Viewport
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: _isArActive
                ? const LinearGradient(colors: [Color(0xFF263238), Color(0xFF37474F)])
                : const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)]),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isArActive) ...[
                Positioned.fill(
                  child: Opacity(opacity: 0.15, child: CustomPaint(painter: _ArGridPainter())),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                    child: const Text('AR LIVE: Bandar Bukit Raja Sanctuary', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ],

              // Shiny Indicator Badge
              if (companion.isShiny)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('✨ SHINY VARIANT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                      ],
                    ),
                  ),
                ),

              // Companion Sprite / Artwork from PokeAPI
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CubePetImage(
                    imagePath: companion.activeArtwork,
                    height: 150,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${companion.displayName} (Stage ${companion.evolutionStage} of ${companion.maxEvolutionStage})',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.dark),
                    ),
                  ),
                ],
              ),

              // AR Mode Toggle Pill
              Positioned(
                bottom: 12,
                right: 12,
                child: InkWell(
                  onTap: () => setState(() => _isArActive = !_isArActive),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isArActive ? Icons.videocam_off_outlined : Icons.view_in_ar_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(_isArActive ? 'Exit AR' : 'Launch AR View', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Level, EXP & Training Action Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: companion.ecoType.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Lv. ${companion.level}',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: companion.ecoType.color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EXP: ${companion.currentExp} / ${companion.expToNextLevel}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dark),
                      ),
                    ],
                  ),
                  Text(
                    '❤️ ${companion.friendship}% Bond',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.pink),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (companion.currentExp / companion.expToNextLevel).clamp(0.0, 1.0),
                  color: AppColors.primary,
                  backgroundColor: AppColors.divider,
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  onPressed: _trainCompanion,
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Train Companion (+35 EXP)', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Evolution Tree Section
        _EvolutionTreeSection(
          companion: companion,
          state: widget.state,
          onChooseEvolution: () => _showEvolutionChoiceDialog(companion),
        ),
        const SizedBox(height: 16),

        // 5. Status Message
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Icon(Icons.eco_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_statusMessage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 6. Feeding Stations
        const Text('Feed Material Eco-Berries (Earned via Recycling)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _BerryCard(
                name: 'Grass Berry',
                source: 'Food Waste',
                count: widget.state.grassBerries,
                color: const Color(0xFF4CAF50),
                icon: Icons.grass_rounded,
                onTap: () => _feedBerry(EcoMaterialType.grass),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BerryCard(
                name: 'Water Berry',
                source: 'Clean Plastics',
                count: widget.state.waterBerries,
                color: const Color(0xFF2196F3),
                icon: Icons.water_drop_rounded,
                onTap: () => _feedBerry(EcoMaterialType.water),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BerryCard(
                name: 'Steel Berry',
                source: 'Metals & E-Waste',
                count: widget.state.steelBerries,
                color: const Color(0xFF607D8B),
                icon: Icons.battery_charging_full_rounded,
                onTap: () => _feedBerry(EcoMaterialType.steel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Horizontal Selector to switch between owned Pokémon
class _OwnedPokemonSwitcher extends StatelessWidget {
  const _OwnedPokemonSwitcher({
    required this.state,
    required this.onSelected,
  });

  final TownshipState state;
  final ValueChanged<PokemonData> onSelected;

  @override
  Widget build(BuildContext context) {
    final owned = state.unlockedPokemon;
    final activeId = state.activeCompanion.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Owned Cube Pets',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${owned.length} Owned • Tap to Switch',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: owned.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final pokemon = owned[i];
              final isActive = pokemon.id == activeId;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(pokemon),
                child: Container(
                  width: 125,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE8F5E9) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? AppColors.primary : const Color(0xFFE0E0E0),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: pokemon.ecoType.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lv. ${pokemon.level}',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: pokemon.ecoType.color),
                            ),
                          ),
                          if (isActive)
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 14)
                          else if (pokemon.isShiny)
                            const Icon(Icons.auto_awesome, color: Colors.amber, size: 13),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: CubePetImage(
                          imagePath: pokemon.activeArtwork,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          color: isActive ? AppColors.primary : AppColors.dark,
                        ),
                      ),
                      Text(
                        isActive ? '👑 Active' : 'Tap to switch',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.primary : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Visual Evolution Tree Section showing Stage 1 -> Stage 2 -> Stage 3
class _EvolutionTreeSection extends StatelessWidget {
  const _EvolutionTreeSection({
    required this.companion,
    required this.state,
    required this.onChooseEvolution,
  });

  final PokemonData companion;
  final TownshipState state;
  final VoidCallback onChooseEvolution;

  @override
  Widget build(BuildContext context) {
    final tree = PokeApiService.instance.getEvolutionTreeFor(companion);
    final unlockedIds = state.unlockedPokemon.map((p) => p.id).toSet();
    final canEvolve = companion.canEvolve;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: canEvolve ? Colors.orange.shade300 : const Color(0xFFE0E0E0),
          width: canEvolve ? 1.5 : 1.0,
        ),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${tree.first.displayName} Evolution Tree',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stage ${companion.evolutionStage} of ${companion.maxEvolutionStage}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Evolution Tree Nodes
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < tree.length; i++) ...[
                  Expanded(
                    child: _EvolutionNodeCard(
                      node: tree[i],
                      isCurrentActive: tree[i].id == companion.id,
                      isUnlocked: unlockedIds.contains(tree[i].id),
                      companion: companion,
                    ),
                  ),
                  if (i < tree.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_rounded, color: Colors.orange.shade600, size: 18),
                          Text(
                            tree[i + 1].evolutionStage == 2 ? 'Lv. 16' : 'Lv. 32',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.orange.shade800),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Interactive Evolution Choice Interaction / Status
          if (canEvolve) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          companion.hasDeclinedEvolution
                              ? '🍃 Evolution held as ${companion.displayName}'
                              : '✨ Ready to Evolve into ${companion.evolvesToName}!',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFE65100)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    companion.hasDeclinedEvolution
                        ? 'You chose to keep ${companion.displayName}. You can evolve whenever you wish!'
                        : 'Eligible by reaching Lv. ${companion.level} (${companion.currentEvolutionBerries}/${companion.berriesToEvolve} Berries)!',
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
                          onPressed: onChooseEvolution,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: Text(
                            companion.hasDeclinedEvolution ? 'Evolve Now (+100 Pts)' : 'Choose: Evolve / Keep',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (companion.evolvesToId != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Evolution: ${companion.evolvesToName} at Lv. ${companion.requiredEvolutionLevel ?? 16}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Current: Lv. ${companion.level} • Feed berries or train to level up',
                          style: const TextStyle(fontSize: 10, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.military_tech_rounded, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '👑 Final Evolution Stage: This companion has unlocked its ultimate township power!',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvolutionNodeCard extends StatelessWidget {
  const _EvolutionNodeCard({
    required this.node,
    required this.isCurrentActive,
    required this.isUnlocked,
    required this.companion,
  });

  final PokemonData node;
  final bool isCurrentActive;
  final bool isUnlocked;
  final PokemonData companion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isCurrentActive ? const Color(0xFFE8F5E9) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentActive
              ? AppColors.primary
              : isUnlocked
                  ? const Color(0xFFC8E6C9)
                  : const Color(0xFFE0E0E0),
          width: isCurrentActive ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Stage ${node.evolutionStage}',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isCurrentActive ? AppColors.primary : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: CubePetImage(
              imagePath: node.activeArtwork,
              isSilhouette: !(isUnlocked || isCurrentActive),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            node.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrentActive ? FontWeight.w800 : FontWeight.w600,
              color: isCurrentActive ? AppColors.primary : AppColors.dark,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isCurrentActive
                  ? AppColors.primary
                  : isUnlocked
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isCurrentActive ? 'Active' : isUnlocked ? 'Unlocked' : 'Locked',
              style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Mobility Egg Incubator with Shiny & Golden Mystery Egg Support
class _EggIncubatorTab extends StatelessWidget {
  const _EggIncubatorTab({required this.state});
  final TownshipState state;

  void _simulateWalk(BuildContext context) {
    final newlyHatched = state.logWalkingDistance(0.65);
    if (newlyHatched != null) {
      _showHatchDialog(context, newlyHatched);
    } else {
      ScaffoldMessenger.of(context).showLatestSnackBar(
        const SnackBar(content: Text('🚶 Walked +0.65 km in Bandar Bukit Raja! Incubator updated.')),
      );
    }
  }

  void _showHatchDialog(BuildContext context, PokemonEgg egg) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨ OH?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(egg.isGoldenMystery ? 'The Golden Mystery Egg is hatching!' : 'The Eco-Egg is hatching!', style: const TextStyle(color: AppColors.grey)),
              const SizedBox(height: 16),
              CubePetImage(
                imagePath: PokeApiService.getPetAsset(egg.pokemonId),
                height: 140,
              ),
              const SizedBox(height: 12),
              Text(
                'Hatched into ${egg.pokemonName}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              const Text('+50 Green Points & Added to Pet-Dex', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Awesome!')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Healthy Living Mobility Tracker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(
                      'Walk in township parks to hatch Eco-Eggs! Golden Mystery eggs have higher ✨ Shiny chances.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => _simulateWalk(context),
          icon: const Icon(Icons.add_road_rounded),
          label: const Text('Log Township Walk (+0.65 km)'),
        ),
        const SizedBox(height: 20),
        const Text('Incubating Eco-Eggs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final egg in state.eggs) _EggCard(egg: egg),
      ],
    );
  }
}

class _EggCard extends StatelessWidget {
  const _EggCard({required this.egg});
  final PokemonEgg egg;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: egg.isGoldenMystery ? Colors.amber.shade100 : egg.eggType.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.egg_rounded, color: egg.isGoldenMystery ? Colors.amber.shade800 : egg.eggType.color, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(egg.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        egg.isHatched ? 'Hatched! ✅' : '${egg.walkedKm.toStringAsFixed(1)} / ${egg.targetKm.toInt()} km',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: egg.eggType.color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: egg.progress,
                      color: egg.isGoldenMystery ? Colors.amber : egg.eggType.color,
                      backgroundColor: AppColors.divider,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 3: Complete Town Pokédex (Categorized by Material, with Locked Silhouettes & PokeAPI data)
class _FullPokedexTab extends StatelessWidget {
  const _FullPokedexTab({required this.state});
  final TownshipState state;

  @override
  Widget build(BuildContext context) {
    final allEntries = PokeApiService.getAllPokedexEntries();
    final unlockedIds = state.unlockedPokemon.map((p) => p.id).toSet();

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            tabs: [
              Tab(text: '🌿 Food Waste'),
              Tab(text: '⚙️ Metals'),
              Tab(text: '💧 Plastics'),
              Tab(text: '⚡ E-Waste'),
              Tab(text: '✨ Guardians'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PokedexGrid(entries: allEntries.where((p) => p.ecoType == EcoMaterialType.grass).toList(), unlockedIds: unlockedIds, state: state),
                _PokedexGrid(entries: allEntries.where((p) => p.ecoType == EcoMaterialType.steel).toList(), unlockedIds: unlockedIds, state: state),
                _PokedexGrid(entries: allEntries.where((p) => p.ecoType == EcoMaterialType.water).toList(), unlockedIds: unlockedIds, state: state),
                _PokedexGrid(entries: allEntries.where((p) => p.ecoType == EcoMaterialType.electric).toList(), unlockedIds: unlockedIds, state: state),
                _PokedexGrid(entries: allEntries.where((p) => p.ecoType == EcoMaterialType.mythical).toList(), unlockedIds: unlockedIds, state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PokedexGrid extends StatelessWidget {
  const _PokedexGrid({required this.entries, required this.unlockedIds, required this.state});

  final List<PokemonData> entries;
  final Set<int> unlockedIds;
  final TownshipState state;

  void _showPokemonDetailModal(BuildContext context, PokemonData pokeTemplate) {
    final ownedList = state.unlockedPokemon.where((p) => p.id == pokeTemplate.id).toList();
    final isUnlocked = ownedList.isNotEmpty;
    final pokemon = isUnlocked ? ownedList.first : pokeTemplate;
    final tree = PokeApiService.instance.getEvolutionTreeFor(pokemon);
    final allUnlockedIds = state.unlockedPokemon.map((p) => p.id).toSet();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentCompanion = state.activeCompanion;
          final currentIsActive = currentCompanion.id == pokemon.id;
          final currentCanEvolve = pokemon.canEvolve;

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (ctx, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // Top Header: Name, ID, Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isUnlocked ? pokemon.displayName : '??? (Locked)',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                              ),
                              if (pokemon.isShiny) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')} • Stage ${pokemon.evolutionStage} of ${pokemon.maxEvolutionStage}',
                            style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: pokemon.ecoType.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: pokemon.ecoType.color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        pokemon.ecoType.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: pokemon.ecoType.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Artwork Centerpiece
                Center(
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      color: isUnlocked ? pokemon.ecoType.color.withValues(alpha: 0.08) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CubePetImage(
                        imagePath: pokemon.activeArtwork,
                        height: 140,
                        isSilhouette: !isUnlocked,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Info: Level & Experience Progress
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: pokemon.ecoType.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Lv. ${pokemon.level}',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: pokemon.ecoType.color),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Experience (EXP)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          Text(
                            isUnlocked ? '${pokemon.currentExp} / ${pokemon.expToNextLevel} EXP' : 'Locked',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: isUnlocked ? (pokemon.currentExp / pokemon.expToNextLevel).clamp(0.0, 1.0) : 0.0,
                          color: AppColors.primary,
                          backgroundColor: AppColors.divider,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stats Grid (HP, Attack, Defense, Bond)
                      Row(
                        children: [
                          _StatPill('❤️ HP', '${pokemon.hp}'),
                          _StatPill('⚔️ Attack', '${pokemon.attack}'),
                          _StatPill('🛡️ Defense', '${pokemon.defense}'),
                          _StatPill('💕 Bond', isUnlocked ? '${pokemon.friendship}%' : '--'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Township Ecological Habit Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBE7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE775)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.eco_rounded, color: Color(0xFF558B2F), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Township Ecological Habit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF33691E))),
                            const SizedBox(height: 2),
                            Text(
                              pokemon.bioDescription,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // INNER SECTION: Evolution Tree of that Particular Pokémon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${tree.first.displayName} Evolution Tree',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(6)),
                            child: const Text('Inner Tree View', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Visual Evolution Tree Nodes
                      SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < tree.length; i++) ...[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: tree[i].id == pokemon.id
                                        ? Border.all(color: Colors.orange.shade800, width: 2)
                                        : null,
                                  ),
                                  child: _EvolutionNodeCard(
                                    node: tree[i],
                                    isCurrentActive: tree[i].id == state.activeCompanion.id,
                                    isUnlocked: allUnlockedIds.contains(tree[i].id),
                                    companion: state.activeCompanion,
                                  ),
                                ),
                              ),
                              if (i < tree.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_forward_rounded, color: Colors.orange.shade700, size: 16),
                                      Text(
                                        tree[i + 1].evolutionStage == 2 ? 'Lv. 16' : 'Lv. 32',
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.orange.shade800),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Actions: Evolution Choice / Switch Companion
                if (isUnlocked) ...[
                  if (currentCanEvolve) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.orange, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Ready to Evolve into ${pokemon.evolvesToName}!',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFE65100)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Reached required evolution level. You can choose to evolve now (+100 Pts) or keep this form.',
                            style: TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    state.declineEvolution(pokemon);
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showLatestSnackBar(
                                      SnackBar(content: Text('Kept ${pokemon.displayName} in current form!')),
                                    );
                                  },
                                  child: const Text('No Need (Keep)', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    Navigator.of(ctx).pop();
                                    await state.evolvePokemon(pokemon);
                                    messenger.showLatestSnackBar(
                                      SnackBar(content: Text('🎉 ${pokemon.displayName} evolved into ${pokemon.evolvesToName}!')),
                                    );
                                  },
                                  child: Text('Evolve! (+100 Pts)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: currentIsActive ? Colors.grey.shade700 : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: currentIsActive
                          ? null
                          : () {
                              state.setActiveCompanion(pokemon);
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showLatestSnackBar(
                                SnackBar(content: Text('Switched active companion to ${pokemon.displayName}! 👑')),
                              );
                            },
                      icon: Icon(currentIsActive ? Icons.check_circle : Icons.swap_horiz_rounded),
                      label: Text(
                        currentIsActive ? 'Current Active Companion 👑' : 'Set as Active Companion',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_rounded, color: AppColors.grey, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Recycle ${pokemon.ecoType.label.split(' ').first} at township Smart Bins to discover and hatch this companion.',
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final poke = entries[i];
        final isUnlocked = unlockedIds.contains(poke.id);
        final isCompanion = state.activeCompanion.id == poke.id;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isCompanion ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showPokemonDetailModal(context, poke),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${poke.id.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w700)),
                      if (isUnlocked)
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14)
                      else
                        const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 14),
                    ],
                  ),
                  Expanded(
                    child: CubePetImage(
                      imagePath: poke.activeArtwork,
                      isSilhouette: !isUnlocked,
                    ),
                  ),
                  Text(
                    isUnlocked ? poke.displayName : '??? (Locked)',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  Text(
                    'Stage ${poke.evolutionStage}',
                    style: TextStyle(fontSize: 10, color: poke.ecoType.color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_tree_outlined, size: 10, color: Colors.deepOrange),
                            SizedBox(width: 3),
                            Text('Tree', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.deepOrange)),
                          ],
                        ),
                      ),
                      if (isUnlocked) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCompanion ? AppColors.tint : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCompanion ? 'Active 👑' : 'View',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isCompanion ? AppColors.primary : AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}

class _BerryCard extends StatelessWidget {
  const _BerryCard({
    required this.name,
    required this.source,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final String source;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(name, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
            Text('$count left', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 2),
            Text(source, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ArGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
