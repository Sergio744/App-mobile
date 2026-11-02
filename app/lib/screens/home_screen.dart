import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/progress_store.dart';
import '../data/vocabulary.dart';
import '../models/word.dart';
import '../widgets/common.dart';
import 'library_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.onOpenStats,
    required this.onOpenLibrary,
  });

  final ProgressStore store;
  final VoidCallback onOpenStats;
  final VoidCallback onOpenLibrary;

  /// Salutation fon adaptée au moment de la journée — la première leçon,
  /// appliquée dès l'accueil.
  static String greetingFor(DateTime now) {
    final int h = now.hour;
    if (h < 11) return 'Kúdó zǎnzǎn';
    if (h < 16) return 'Kúdó hwemɛ';
    return 'Kúdó gbadà';
  }

  @override
  Widget build(BuildContext context) {
    final int remaining = store.remainingToday;
    final List<Word> queue = store.queue;
    final List<Word> session = queue.take(store.remainingToday).toList();
    final double goalProgress =
        store.dailyGoal == 0 ? 0 : store.reviewsToday / store.dailyGoal;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            // En-tête
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        greetingFor(store.now),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: GbeColors.terracotta,
                              letterSpacing: 1.6,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gbè',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onOpenStats,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: store.streak > 0
                          ? GbeColors.ochre.withValues(alpha: 0.15)
                          : GbeColors.sand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.local_fire_department_rounded,
                            size: 20, color: GbeColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          '${store.streak}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: GbeColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Carte de session du jour
            _TodayCard(
              remaining: remaining,
              queueSize: queue.length,
              reviewsToday: store.reviewsToday,
              goal: store.dailyGoal,
              goalProgress: goalProgress,
              onStart: session.isEmpty
                  ? null
                  : () => _startSession(context, session),
            ),
            const SizedBox(height: 22),

            // Statistiques rapides
            GbeCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StatTile(
                      value: '${store.acquiredCount}',
                      label: 'mots acquis',
                      color: GbeColors.forest,
                    ),
                  ),
                  Container(width: 1, height: 38, color: GbeColors.sand),
                  const SizedBox(width: 18),
                  Expanded(
                    child: StatTile(
                      value: '${(store.mastery * 100).round()} %',
                      label: 'du lexique',
                    ),
                  ),
                  Container(width: 1, height: 38, color: GbeColors.sand),
                  const SizedBox(width: 18),
                  Expanded(
                    child: StatTile(
                      value: '${store.totalReviews}',
                      label: 'révisions',
                      color: GbeColors.plum,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Thèmes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Tes thèmes', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: onOpenLibrary,
                  child: const Text('Tout voir'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...Vocabulary.decks.take(4).map(
                  (Deck deck) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DeckRow(
                      deck: deck,
                      mastery: store.deckMastery(deck.id),
                      seen: store.deckSeen(deck.id),
                      total: Vocabulary.byDeck(deck.id).length,
                      onTap: () => _openDeck(context, deck),
                    ),
                  ),
                ),
            const SizedBox(height: 10),
            Text(
              '${Vocabulary.words.length} mots · hors-ligne · sans compte',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession(BuildContext context, List<Word> words) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => StudySessionScreen(
          store: store,
          words: words,
          title: 'Aujourd’hui',
        ),
      ),
    );
  }

  Future<void> _openDeck(BuildContext context, Deck deck) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeckDetailScreen(store: store, deck: deck),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.remaining,
    required this.queueSize,
    required this.reviewsToday,
    required this.goal,
    required this.goalProgress,
    required this.onStart,
  });

  final int remaining;
  final int queueSize;
  final int reviewsToday;
  final int goal;
  final double goalProgress;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final bool done = remaining == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[GbeColors.forest, Color(0xFF24544A)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            done ? 'Objectif atteint' : 'Ta session du jour',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            done ? 'Kwabɔ̀ !' : '$remaining ${remaining == 1 ? 'mot' : 'mots'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1.05,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            done
                ? 'Reviens demain : la répétition fait le reste.'
                : 'prêts à être révisés',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 22),
          GbeProgressBar(
            value: goalProgress,
            color: GbeColors.ochre,
            background: Colors.white.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 8),
          Text(
            '$reviewsToday / $goal aujourd’hui${queueSize > remaining ? ' · ${queueSize - remaining} en attente' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: GbeColors.cream,
                foregroundColor: GbeColors.ink,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.2),
                disabledForegroundColor: Colors.white54,
              ),
              child: Text(done ? 'Tout est fait pour aujourd’hui' : 'Commencer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  const _DeckRow({
    required this.deck,
    required this.mastery,
    required this.seen,
    required this.total,
    required this.onTap,
  });

  final Deck deck;
  final double mastery;
  final int seen;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color(deck.colorValue);
    return GbeCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(deck.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(deck.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '$seen / $total mots vus',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                GbeProgressBar(value: mastery, height: 5, color: accent),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right_rounded, color: GbeColors.inkSoft),
        ],
      ),
    );
  }
}
