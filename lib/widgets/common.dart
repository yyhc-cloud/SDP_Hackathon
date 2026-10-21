import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

/// Modern square icon tile used in the quick-access grid.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
    this.gradient,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        (highlight
            ? const LinearGradient(
                colors: [Color(0xFFF15921), Color(0xFFE64A19)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFF2EE), Color(0xFFFFECE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    final isColored = gradient != null || highlight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: effectiveGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (isColored
                              ? (gradient?.colors.first ?? const Color(0xFFF15921))
                              : Colors.black)
                          .withValues(alpha: isColored ? 0.28 : 0.05),
                      blurRadius: isColored ? 8 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isColored ? Colors.white : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded label, e.g. "+40 pts" or "Plastic".
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.primary, this.filled = false});

  final String text;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: filled ? AppColors.white : color,
        ),
      ),
    );
  }
}

String formatPoints(int points) {
  final s = points.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
