import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

/// Gamification hub: resident leaderboard and Guild Wars.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: const TabBar(tabs: [Tab(text: 'Leaderboard'), Tab(text: 'Guild Wars')]),
        ),
        body: const TabBarView(
          children: [
            _Leaderboard(entries: MockData.residents, highlight: 'Aisyah (You)'),
            _GuildWars(),
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
    final medal = rank <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.tint : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: medal ? AppColors.primary : AppColors.divider,
            child: Text(
              '$rank',
              style: TextStyle(
                color: medal ? AppColors.white : AppColors.dark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: Theme.of(context).textTheme.titleMedium),
                Text(entry.subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${formatPoints(entry.points)} pts',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _GuildWars extends StatelessWidget {
  const _GuildWars();

  @override
  Widget build(BuildContext context) {
    const guilds = MockData.guilds;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'October Guild War',
                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Spacer(),
                  Pill('11 days left', color: AppColors.accent, filled: true),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your guild: ${MockData.user.guild}',
                style: const TextStyle(color: AppColors.tint),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: guilds[1].points / guilds[0].points,
                  minHeight: 10,
                  color: AppColors.primary,
                  backgroundColor: AppColors.grey.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatPoints(guilds[0].points - guilds[1].points)} pts behind 1st place',
                style: const TextStyle(color: AppColors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < guilds.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RankTile(
              rank: i + 1,
              entry: guilds[i],
              isMe: guilds[i].name == MockData.user.guild,
            ),
          ),
      ],
    );
  }
}
