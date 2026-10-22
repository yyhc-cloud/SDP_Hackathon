import 'package:flutter/material.dart';
import '../data/township_state.dart';
import '../models/pokemon_model.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

/// Circular Economy Shop: Spend points to "close resource loops" & earn real-world township perks.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  void _showRedeemDialog(BuildContext context, CircularPerk perk) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PerkRedeemSheet(perk: perk),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TownshipState.instance,
      builder: (context, _) {
        final state = TownshipState.instance;
        final user = state.user;
        final perks = state.circularPerks;
        final activity = state.activity;

        return Scaffold(
          appBar: AppBar(title: const Text('Circular Economy Shop')),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Points Balance Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available Green Points', style: TextStyle(color: AppColors.tint)),
                      const SizedBox(height: 4),
                      Text(
                        formatPoints(user.points),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Spend points to close local resource loops across the township',
                        style: TextStyle(color: AppColors.tint, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.park_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.unlockedPokemon.length} Pokémon in Sanctuary',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.todayWalkedKm.toStringAsFixed(1)} km Walked',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SectionHeader('Township Perks (Closing Resource Loops)'),
              for (final perk in perks)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _PerkCard(
                    perk: perk,
                    canAfford: user.points >= perk.pointsCost,
                    onRedeem: () => _showRedeemDialog(context, perk),
                  ),
                ),

              const SectionHeader('Activity History'),
              for (final a in activity)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: CircleAvatar(
                    backgroundColor: a.points > 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    child: Icon(
                      a.points > 0 ? Icons.eco_rounded : Icons.card_giftcard_rounded,
                      color: a.points > 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      size: 20,
                    ),
                  ),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(a.date, style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    '${a.points > 0 ? '+' : '−'}${formatPoints(a.points.abs())} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: a.points > 0 ? AppColors.primary : AppColors.accent,
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

class _PerkCard extends StatelessWidget {
  const _PerkCard({required this.perk, required this.canAfford, required this.onRedeem});

  final CircularPerk perk;
  final bool canAfford;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: perk.isRedeemed ? AppColors.divider : AppColors.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                perk.icon,
                color: perk.isRedeemed ? AppColors.grey : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perk.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      decoration: perk.isRedeemed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(perk.partnerName, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${perk.pointsCost} pts',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text('• ${perk.category}', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: perk.isRedeemed ? null : onRedeem,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: perk.isRedeemed
                      ? AppColors.divider
                      : (canAfford ? AppColors.primary : AppColors.tint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  perk.isRedeemed ? 'Claimed' : (canAfford ? 'Redeem' : 'Need Pts'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: perk.isRedeemed
                        ? AppColors.grey
                        : (canAfford ? AppColors.white : AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerkRedeemSheet extends StatelessWidget {
  const _PerkRedeemSheet({required this.perk});
  final CircularPerk perk;

  @override
  Widget build(BuildContext context) {
    final state = TownshipState.instance;
    final canAfford = state.user.points >= perk.pointsCost;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(perk.icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(perk.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(perk.partnerName, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(perk.description, style: const TextStyle(fontSize: 13, color: AppColors.dark)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Points Required'),
                Text('${perk.pointsCost} Green Points', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (canAfford)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // Capture the navigator before popping: this sheet's context is gone once it closes.
                  final navigator = Navigator.of(context);
                  final ok = state.redeemCircularPerk(perk.id);
                  navigator.pop();
                  if (ok) {
                    showDialog<void>(
                      context: navigator.context,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('🎉 Voucher Redeemed!'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Present this digital voucher code to partner:'),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.tint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                perk.voucherCode,
                                style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Done')),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Confirm Redemption'),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Insufficient points. Recycle at Smart Bins to earn more!', style: TextStyle(color: Color(0xFFC62828), fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
