import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/progress_store.dart';
import '../data/vocabulary.dart';
import '../widgets/common.dart';

/// Les statistiques : ce que l'utilisateur a accompli, sans gamification
/// agressive (pas de gemmes, pas de classements à acheter).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.store});

  final ProgressStore store;

  static const List<String> _weekdayInitials = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final List<DayLog> week = store.lastSevenDays();
    final DateTime today = store.now;

    return Scaffold(
      appBar: AppBar(title: const Text('Ta progression')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          GbeCard(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: StatTile(
                    value: '${store.streak}',
                    label: store.streak > 1 ? 'jours d’affilée' : 'jour d’affilée',
                    color: GbeColors.warning,
                  ),
                ),
                Container(width: 1, height: 44, color: GbeColors.sand),
                const SizedBox(width: 18),
                Expanded(
                  child: StatTile(
                    value: '${store.totalReviews}',
                    label: 'révisions au total',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          GbeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('7 derniers jours',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 18),
                WeekBars(
                  values: week.map((DayLog d) => d.reviews).toList(),
                  labels: week.map((DayLog d) {
                    final DateTime date = DateTime.parse(d.day);
                    // Lundi = 1 dans DateTime.weekday, l'index 0 = lundi.
                    return _weekdayInitials[date.weekday - 1];
                  }).toList(),
                  goal: store.dailyGoal,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Objectif quotidien',
                        style: Theme.of(context).textTheme.bodyMedium),
                    SegmentedButton<int>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 12),
                        ),
                      ),
                      segments: const <ButtonSegment<int>>[
                        ButtonSegment<int>(value: 5, label: Text('5')),
                        ButtonSegment<int>(value: 10, label: Text('10')),
                        ButtonSegment<int>(value: 20, label: Text('20')),
                      ],
                      selected: <int>{store.dailyGoal},
                      onSelectionChanged: (Set<int> s) =>
                          store.setDailyGoal(s.first),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          GbeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Le lexique', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        value: '${store.acquiredCount}',
                        label: 'acquis',
                        color: GbeColors.forest,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        value: '${store.learningCount}',
                        label: 'en cours',
                        color: GbeColors.ochre,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        value:
                            '${Vocabulary.words.length - store.acquiredCount - store.learningCount}',
                        label: 'à découvrir',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GbeProgressBar(value: store.mastery, color: GbeColors.forest),
                const SizedBox(height: 8),
                Text(
                  '${(store.mastery * 100).round()} % de maîtrise sur ${Vocabulary.words.length} mots',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          GbeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Par thème', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ...Vocabulary.decks.map((Deck deck) {
                  final double m = store.deckMastery(deck.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(deck.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(deck.label,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            Text(
                              '${(m * 100).round()} %',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GbeProgressBar(
                          value: m,
                          height: 5,
                          color: Color(deck.colorValue),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          GbeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Comment ça marche',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  'Gbè utilise la répétition espacée : chaque mot est reprogrammé au moment où tu risques de l’oublier. Un mot oublié revient toutes les 10 minutes, un mot solide peut attendre plusieurs mois. '
                  'Résultat : 3 minutes par jour suffisent, et rien ne se perd.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    _Legend(color: GbeColors.danger, label: 'oublié'),
                    const SizedBox(width: 14),
                    _Legend(color: GbeColors.warning, label: 'difficile'),
                    const SizedBox(width: 14),
                    _Legend(color: GbeColors.forest, label: 'bien'),
                    const SizedBox(width: 14),
                    _Legend(color: GbeColors.plum, label: 'facile'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Réinitialiser ma progression'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dernière activité : ${_formatDate(today)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: GbeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tout réinitialiser ?'),
        content: const Text(
          'Ta progression et ta série seront effacées. Les mots du lexique, eux, restent.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Effacer', style: TextStyle(color: GbeColors.danger)),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await store.reset();
    }
  }

  static String _formatDate(DateTime d) {
    const List<String> months = <String>[
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}
