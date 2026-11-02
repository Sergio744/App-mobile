import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Barre de progression fine et animée.
class GbeProgressBar extends StatelessWidget {
  const GbeProgressBar({
    super.key,
    required this.value,
    this.color = GbeColors.forest,
    this.height = 8,
    this.background = GbeColors.sand,
  });

  final double value;
  final Color color;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0).toDouble()),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double v, Widget? child) {
          return LinearProgressIndicator(
            value: v,
            minHeight: height,
            backgroundColor: background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          );
        },
      ),
    );
  }
}

/// Étiquette arrondie discrète (« 4 mots », « acquis »…).
class GbePill extends StatelessWidget {
  const GbePill({
    super.key,
    required this.label,
    this.color = GbeColors.inkSoft,
    this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de section avec ombre douce.
class GbeCard extends StatelessWidget {
  const GbeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = GbeColors.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(GbeTheme.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GbeTheme.radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GbeTheme.radius),
            border: Border.all(color: GbeColors.sand),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Grand chiffre + libellé, pour les statistiques.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.color = GbeColors.ink,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

/// Historique des 7 derniers jours sous forme de barres.
class WeekBars extends StatelessWidget {
  const WeekBars({
    super.key,
    required this.values,
    required this.labels,
    this.goal = 10,
  });

  final List<int> values;
  final List<String> labels;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final int maxValue = <int>[...values, goal].reduce((int a, int b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(values.length, (int i) {
        final int v = values[i];
        final double ratio = maxValue == 0 ? 0 : v / maxValue;
        final bool today = i == values.length - 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: ratio),
              duration: Duration(milliseconds: 400 + i * 60),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double r, Widget? child) {
                return Container(
                  width: 26,
                  height: 8 + r * 56,
                  decoration: BoxDecoration(
                    color: today
                        ? GbeColors.terracotta
                        : v >= goal
                            ? GbeColors.forest
                            : GbeColors.sand,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                color: today ? GbeColors.ink : GbeColors.inkSoft,
              ),
            ),
          ],
        );
      }),
    );
  }
}
