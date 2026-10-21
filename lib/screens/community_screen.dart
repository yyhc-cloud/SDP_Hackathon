import 'package:flutter/material.dart';

import '../data/township_state.dart';
import '../data/mock_data.dart';
import '../models/landed_models.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'guild_wars_screen.dart';

/// Gamification hub: Street Rivalries (Jalan vs Jalan), resident leaderboard, and Guild Wars.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Hub'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Jalan Rivalries'),
              Tab(text: 'Residents'),
              Tab(text: 'Guild Wars'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StreetRivalriesTab(),
            _Leaderboard(entries: MockData.residents, highlight: 'Aisyah (You)'),
            _GuildWars(),
          ],
        ),
      ),
    );
  }
}

class _StreetRivalriesTab extends StatelessWidget {
  const _StreetRivalriesTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final streets = state.streetRivalries;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Splatoon-style Territory Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                        child: const Icon(Icons.military_tech_rounded, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Territorial Street Rivalry',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Text(
                              'Bandar Bukit Raja • October Season',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        child: const Text('WEEK 3', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Your Street: Jalan Makmur (Rank #1)',
                              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '🎉 Active Street Perk: 10% point boost on all circular perks! Leading street wins a physical Community BBQ Night this month!',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Street Standings (Landed Estate)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),

            for (final st in streets)
              _StreetTerritoryCard(street: st),
          ],
        );
      },
    );
  }
}

class _StreetTerritoryCard extends StatelessWidget {
  const _StreetTerritoryCard({required this.street});
  final StreetTerritory street;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: street.isUserStreet ? const BorderSide(color: Color(0xFF1E88E5), width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: street.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#${street.rank}',
                      style: TextStyle(color: street.color, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(street.streetName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          if (street.isUserStreet) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(6)),
                              child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      Text('${street.householdCount} households • Top: ${street.topMaterial}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
                Text(
                  '${street.weeklyKg} kg',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.dark),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: street.isLeader ? const Color(0xFFE3F2FD) : AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    street.isLeader ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                    size: 14,
                    color: street.isLeader ? const Color(0xFF1565C0) : AppColors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      street.territoryReward,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: street.isLeader ? FontWeight.w700 : FontWeight.w500,
                        color: street.isLeader ? const Color(0xFF1565C0) : AppColors.dark,
                      ),
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

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.entries, this.highlight});

  final List<LeaderboardEntry> entries;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RankTile(
        rank: i + 1,
        entry: entries[i],
        isMe: entries[i].name == highlight,
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.rank, required this.entry, this.isMe = false});

  final int rank;
  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isMe ? AppColors.tint : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isMe ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3 ? AppColors.primary : AppColors.tint,
          foregroundColor: rank <= 3 ? AppColors.white : AppColors.primary,
          child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        title: Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(entry.subtitle),
        trailing: Text(
          formatPoints(entry.points),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}

class _GuildWars extends StatelessWidget {
  const _GuildWars();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final guilds = state.neighbourhoodGuilds;
        final userGuild = guilds.firstWhere((g) => g.isUserGuild, orElse: () => guilds.first);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GuildWarsScreen()),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Neighbourhood Guild Wars',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                          child: const Text('OPEN WAR ROOM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Guild: ${userGuild.name} (Rank #${userGuild.rank})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${userGuild.neighbourhood} • ${userGuild.weeklyWarPoints} War Power',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Controlling ${state.battlefronts.where((b) => b.ourControlPercent >= 0.5).length} of ${state.battlefronts.length} Township Battlefronts',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Neighbourhood Standings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            for (var i = 0; i < guilds.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: guilds[i].isUserGuild ? const Color(0xFFE3F2FD) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: guilds[i].isUserGuild ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                      width: guilds[i].isUserGuild ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: i == 0 ? Colors.amber : Colors.grey.shade200,
                        foregroundColor: i == 0 ? Colors.black : Colors.black87,
                        child: Text('${guilds[i].rank}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(guilds[i].name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            Text('${guilds[i].neighbourhood} • ${guilds[i].township}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                          ],
                        ),
                      ),
                      Text('${guilds[i].weeklyWarPoints} pts', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
