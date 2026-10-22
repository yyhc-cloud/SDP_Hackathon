import 'package:flutter/material.dart';

import '../data/township_state.dart';
import '../data/mock_data.dart';
import '../models/pokemon_model.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/cube_pet_image.dart';
import 'boss_battle_screen.dart';
import 'gamehub_screen.dart';
import 'guild_wars_screen.dart';
import 'pickup_request_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'show_qr_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final user = state.user;
        final companion = state.activeCompanion;
        final boss = state.boss;
        final eggs = state.eggs.where((e) => !e.isHatched).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(
                user: user,
                onPointsTap: () => onNavigate(4), // Navigate to Circular Shop
                onProfileTap: () => _push(context, const ProfileScreen()),
              ),

              // Active Biodiversity Companion Card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0FDF4), Color(0xFFE8F5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF86EFAC).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C059669),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: companion.ecoType.color.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CubePetImage(
                          imagePath: companion.officialArtworkUrl,
                          width: 68,
                          height: 68,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      companion.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Color(0xFF14532D),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Lv. ${companion.level}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: companion.ecoType.color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    companion.ecoType.label.split(' / ').first,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Township Companion • ${companion.currentExp}/${companion.expToNextLevel} EXP',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (companion.currentExp / companion.expToNextLevel).clamp(0.0, 1.0),
                                minHeight: 5,
                                backgroundColor: Colors.white,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => onNavigate(3),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.view_in_ar_rounded, size: 14, color: Color(0xFF166534)),
                                        SizedBox(width: 4),
                                        Text('AR View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => onNavigate(3),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.restaurant_rounded, size: 14, color: Color(0xFF15803D)),
                                        const SizedBox(width: 4),
                                        Text('Feed Berries (${state.grassBerries + state.steelBerries + state.waterBerries})',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Community Boss Raid Alert Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: InkWell(
                  onTap: () => _push(context, const BossBattleScreen()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C0B4D), Color(0xFF4A148C), Color(0xFF6A1B9A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.35), width: 1.2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber),
                          ),
                          child: CubePetImage(
                            imagePath: boss.bossAsset,
                            width: 34,
                            height: 34,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'RAID BOSS: Sludge-Hog in Park',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: state.isBossOnCooldown ? Colors.green.shade600 : Colors.amber,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      state.isBossOnCooldown ? 'PURIFIED' : '${boss.daysRemaining}d left',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: state.isBossOnCooldown ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              if (state.isBossOnCooldown)
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Colors.amberAccent, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Respawns in ${formatCountdown(state.bossRespawnRemaining)}',
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                const Text(
                                  'Defeat to win Forest Guardian Dog (New Pet!)',
                                  style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (boss.currentKg / boss.targetKg).clamp(0.0, 1.0),
                                          minHeight: 4,
                                          backgroundColor: Colors.white24,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${boss.currentKg.toStringAsFixed(1)} / ${boss.targetKg.toInt()} kg',
                                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              // Mobility Egg Hatching Card
              if (eggs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: InkWell(
                    onTap: () => onNavigate(3),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: eggs.first.eggType.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.egg_rounded, color: eggs.first.eggType.color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Incubating: ${eggs.first.name}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${eggs.first.walkedKm.toStringAsFixed(1)} / ${eggs.first.targetKm.toInt()} km • Walk in township to hatch!',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),

              const SectionHeader('Digital Township Quick Access'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.82,
                  children: [
                    QuickActionTile(
                      icon: Icons.qr_code_2_rounded,
                      label: 'Show QR',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF15921), Color(0xFFD84315)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _push(context, const ShowQrScreen()),
                    ),
                    QuickActionTile(
                      icon: Icons.sports_esports_rounded,
                      label: 'GameHub',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _push(context, const GameHubScreen()),
                    ),
                    QuickActionTile(
                      icon: Icons.shield_rounded,
                      label: 'Boss Raid',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _push(context, const BossBattleScreen()),
                    ),
                    QuickActionTile(
                      icon: Icons.pets_rounded,
                      label: 'AR Sanctuary',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => onNavigate(3),
                    ),
                    QuickActionTile(
                      icon: Icons.storefront_rounded,
                      label: 'Circular Shop',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => onNavigate(4),
                    ),
                    QuickActionTile(
                      icon: Icons.local_shipping_outlined,
                      label: 'Pickup',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _push(context, const PickupRequestScreen()),
                    ),
                    QuickActionTile(
                      icon: Icons.campaign_rounded,
                      label: 'Report Issue',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _push(context, const ReportScreen()),
                    ),
                    QuickActionTile(
                      icon: Icons.military_tech_rounded,
                      label: 'Guild Wars',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _push(context, const GuildWarsScreen()),
                    ),
                  ],
                ),
              ),

              const SectionHeader('Township Announcements'),
              SizedBox(
                height: 136,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: MockData.announcements.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _AnnouncementCard(item: MockData.announcements[i]),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.onPointsTap,
    required this.onProfileTap,
  });

  final UserProfile user;
  final VoidCallback onPointsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Sime Darby Corporate Signature Header
        Container(
          height: 184 + top,
          padding: EdgeInsets.fromLTRB(20, top + 16, 16, 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFBA1A1A), // Sime Darby deep brand red
                Color(0xFFC62828),
                Color(0xFFF15921), // Sime Darby warm vermilion
              ],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33BA1A1A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ambient subtle circle overlay
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Corporate township crest pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco_rounded, size: 12, color: Colors.amberAccent),
                              SizedBox(width: 4),
                              Text(
                                'SIME DARBY PROPERTY • SMART ESG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hello, ${user.name}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              user.residence,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white60, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            const Text('Verified Resident', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onProfileTap,
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amberAccent, width: 2),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: AppColors.white,
                        radius: 17,
                        child: Text(
                          'A',
                          style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Modern Elevated Points Card
        Padding(
          padding: EdgeInsets.fromLTRB(20, top + 98, 20, 0),
          child: _PointsCard(user: user, onTap: onPointsTap),
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.user, required this.onTap});

  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringgit = user.points / MockData.pointsPerRinggit;

    return Material(
      color: AppColors.white,
      elevation: 8,
      shadowColor: const Color(0x24000000),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x331B5E20), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GREEN POINTS • CIRCULAR REWARDS',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPoints(user.points),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '≈ RM ${ringgit.toStringAsFixed(2)} voucher value',
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Redeem',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 13),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(item.tag, filled: true),
          const Spacer(),
          Text(item.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
