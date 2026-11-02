import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/progress_store.dart';
import '../data/vocabulary.dart';
import '../models/card_state.dart';
import '../models/word.dart';
import '../widgets/common.dart';
import 'study_screen.dart';

/// Le lexique complet, organisé en thèmes.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Le lexique')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: <Widget>[
          Text(
            '${Vocabulary.words.length} mots en 9 thèmes. Tout est hors-ligne.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          ...Vocabulary.decks.map((Deck deck) {
            final List<Word> words = Vocabulary.byDeck(deck.id);
            final int seen = store.deckSeen(deck.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GbeCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DeckDetailScreen(store: store, deck: deck),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(deck.colorValue).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(deck.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(deck.label,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            deck.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              GbePill(
                                label: '${words.length} mots',
                                color: Color(deck.colorValue),
                              ),
                              const SizedBox(width: 8),
                              if (seen > 0)
                                GbePill(
                                  label: '$seen vus',
                                  color: GbeColors.inkSoft,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: GbeColors.inkSoft),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Liste des mots d'un thème, avec leur état d'apprentissage.
class DeckDetailScreen extends StatelessWidget {
  const DeckDetailScreen({super.key, required this.store, required this.deck});

  final ProgressStore store;
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final List<Word> words = Vocabulary.byDeck(deck.id);
    final Color accent = Color(deck.colorValue);

    return Scaffold(
      appBar: AppBar(title: Text(deck.label)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => StudySessionScreen(
              store: store,
              words: words,
              title: deck.label,
            ),
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Réviser ce thème'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
        itemCount: words.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                deck.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          final Word word = words[index - 1];
          return _WordTile(
            word: word,
            state: store.cardFor(word.id),
            accent: accent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WordDetailScreen(word: word),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.word,
    required this.state,
    required this.accent,
    required this.onTap,
  });

  final Word word;
  final CardState? state;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CardState? s = state;
    final String status;
    final Color statusColor;
    if (s == null || s.isNew) {
      status = 'nouveau';
      statusColor = GbeColors.inkSoft;
    } else if (s.isAcquired) {
      status = 'acquis';
      statusColor = GbeColors.forest;
    } else {
      status = 'en cours';
      statusColor = GbeColors.ochre;
    }

    return GbeCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  word.fon,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 19,
                      ),
                ),
                const SizedBox(height: 2),
                Text(word.french,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GbePill(label: status, color: statusColor),
        ],
      ),
    );
  }
}

/// Fiche complète d'un mot : prononciation, exemple, note culturelle.
class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final Deck? deck = Vocabulary.deckById(word.deckId);
    final Color accent = Color(deck?.colorValue ?? 0xFFC4623F);

    return Scaffold(
      appBar: AppBar(actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: GbePill(label: deck?.label ?? '', color: accent),
          ),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: <Widget>[
          Text(
            word.fon,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            word.pronunciation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: GbeColors.inkSoft,
                ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text('Français', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(word.french, style: Theme.of(context).textTheme.titleLarge),
          if (word.exampleFon != null) ...<Widget>[
            const SizedBox(height: 26),
            Text('En contexte', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: GbeColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: GbeColors.sand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    word.exampleFon!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                  ),
                  if (word.exampleFrench != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(word.exampleFrench!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
          if (word.note != null) ...<Widget>[
            const SizedBox(height: 26),
            Text('À savoir', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              word.note!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ],
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GbeColors.sand.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: GbeColors.inkSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Le fon est une langue tonale et son orthographe varie encore selon les sources. Fais relire ce mot par un locuteur natif avant publication.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
