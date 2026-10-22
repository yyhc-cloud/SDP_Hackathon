import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/landed_models.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class GuildWarsScreen extends StatefulWidget {
  const GuildWarsScreen({super.key});

  @override
  State<GuildWarsScreen> createState() => _GuildWarsScreenState();
}

class _GuildWarsScreenState extends State<GuildWarsScreen> with SingleTickerProviderStateMixin {
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

  void _reinforceFront(GuildBattlefront bf) {
    TownshipState.instance.contributeToBattlefront(bf.id, 50);
    ScaffoldMessenger.of(context).showLatestSnackBar(
      SnackBar(
        content: Text('🛡️ Reinforced ${bf.name} with +50 War Power! (+10 Green Points earned)'),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final guilds = state.neighbourhoodGuilds;
        final userGuild = guilds.firstWhere((g) => g.isUserGuild, orElse: () => guilds.first);
        final battlefronts = state.battlefronts;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FA),
          appBar: AppBar(
            title: const Text('Neighbourhood Guild Wars'),
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.shield_rounded), text: 'Battlefronts'),
                Tab(icon: Icon(Icons.leaderboard_rounded), text: 'Leaderboard'),
                Tab(icon: Icon(Icons.history_rounded), text: 'War Activity'),
              ],
            ),
          ),
          body: Column(
            children: [
              // User Guild Overview Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.military_tech_rounded, color: Color(0xFF0D47A1), size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userGuild.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('RANK #1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${userGuild.neighbourhood} • ${userGuild.township}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${userGuild.weeklyWarPoints}',
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            const Text('War Power', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.format_quote_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              userGuild.motto,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ),
                          Text('${userGuild.memberCount} Residents Active', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Battlefronts
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: battlefronts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final bf = battlefronts[i];
                        final isOurLead = bf.ourControlPercent >= 0.50;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: isOurLead ? Colors.blue.shade200 : Colors.orange.shade200),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isOurLead ? Colors.blue.shade50 : Colors.orange.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(bf.frontlineIcon, color: isOurLead ? const Color(0xFF1976D2) : Colors.orange.shade800, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(bf.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                        Text(bf.location, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isOurLead ? Colors.blue.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isOurLead ? Colors.blue : Colors.red),
                                    ),
                                    child: Text(
                                      isOurLead ? 'UNDER CONTROL' : 'CONTESTED',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isOurLead ? Colors.blue.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${userGuild.name}: ${(bf.ourControlPercent * 100).toInt()}%',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF1976D2)),
                                  ),
                                  Text(
                                    '${bf.challengerGuild}: ${((1 - bf.ourControlPercent) * 100).toInt()}%',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: bf.ourControlPercent,
                                  minHeight: 10,
                                  color: const Color(0xFF1976D2),
                                  backgroundColor: Colors.orange.shade400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.green, size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Perk: ${bf.bonusPerk}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('Total War Power: ${bf.totalWarPower} pts', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D47A1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    icon: const Icon(Icons.bolt_rounded, size: 16),
                                    label: const Text('Reinforce Front (+50)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                                    onPressed: () => _reinforceFront(bf),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Tab 2: Leaderboard
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: guilds.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final guild = guilds[i];
                        final isUser = guild.isUserGuild;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFE3F2FD) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isUser ? const Color(0xFF1E88E5) : Colors.grey.shade200, width: isUser ? 2 : 1),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: i == 0 ? Colors.amber : (i == 1 ? Colors.grey.shade400 : (i == 2 ? Colors.brown.shade300 : Colors.grey.shade200)),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${guild.rank}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: i < 3 ? Colors.white : Colors.black87,
                                    ),
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
                                        Text(
                                          guild.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: isUser ? const Color(0xFF0D47A1) : AppColors.dark,
                                          ),
                                        ),
                                        if (isUser) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${guild.neighbourhood} • ${guild.memberCount} members', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${guild.weeklyWarPoints}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0D47A1)),
                                  ),
                                  const Text('War Points', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Tab 3: War Activity Log
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.guildWarActivities.length,
                      separatorBuilder: (_, _) => const Divider(height: 12),
                      itemBuilder: (context, i) {
                        final act = state.guildWarActivities[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: const Color(0xFF0D47A1),
                            child: const Icon(Icons.bolt_rounded, size: 20),
                          ),
                          title: Text(
                            act.action,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          subtitle: Text('${act.residentName} • ${act.battlefrontName} • ${act.timeAgo}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                          trailing: Text(
                            '+${act.pointsAdded}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1976D2), fontSize: 14),
                          ),
                        );
                      },
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

