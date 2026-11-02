import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/srs.dart';
import '../core/theme.dart';
import '../data/progress_store.dart';
import '../data/vocabulary.dart';
import '../models/card_state.dart';
import '../models/word.dart';
import '../widgets/common.dart';

/// Une session d'étude : on présente les cartes une par une, on révèle la
/// réponse, puis l'utilisateur s'auto-évalue avec les quatre boutons.
class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({
    super.key,
    required this.store,
    required this.words,
    this.title = 'Révision',
  });

  final ProgressStore store;
  final List<Word> words;
  final String title;

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  /// Copie de travail : une carte oubliée peut être replacée dans la session
  /// sans modifier la file d'origine.
  late final List<Word> _queue = <Word>[...widget.words];

  int _index = 0;
  bool _revealed = false;
  int _answered = 0;
  int _correct = 0;
  bool _finished = false;

  Word get _current => _queue[_index];

  double get _progress => _queue.isEmpty ? 0 : _answered / _queue.length;

  void _reveal() {
    if (_revealed) return;
    HapticFeedback.selectionClick();
    setState(() => _revealed = true);
  }

  void _rate(Rating rating) {
    if (!_revealed) return;
    final CardState current =
        widget.store.cardFor(_current.id) ?? CardState(wordId: _current.id, due: widget.store.now);
    final CardState next = Srs.review(current, rating, widget.store.now);
    widget.store.recordReview(_current, next);

    if (rating == Rating.again) {
      HapticFeedback.lightImpact();
      // On revoit le mot tout de suite : on le replace un peu plus loin.
      final int insertAt = (_index + 4).clamp(_index + 1, _queue.length).toInt();
      _queue.insert(insertAt, _current);
    } else {
      HapticFeedback.mediumImpact();
      _correct++;
    }

    setState(() {
      _answered++;
      _revealed = false;
      if (_index + 1 >= _queue.length) {
        _finished = true;
      } else {
        _index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished || _queue.isEmpty) {
      return _SessionSummary(
        title: widget.title,
        answered: _answered,
        correct: _correct,
        onDone: () => Navigator.of(context).pop(true),
      );
    }

    final Word word = _current;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          '${_index + 1} / ${_queue.length}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GbePill(
                label: widget.title,
                color: GbeColors.inkSoft,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: GbeProgressBar(value: _progress, height: 6),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: _reveal,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: _CardFace(
                    word: word,
                    revealed: _revealed,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _revealed
                  ? _RatingPad(
                      store: widget.store,
                      word: word,
                      onRate: _rate,
                    )
                  : Column(
                      children: <Widget>[
                        FilledButton(
                          onPressed: _reveal,
                          child: const Text('Révéler la réponse'),
                        ),
                        const SizedBox(height: 10),
                        const _Hint(text: 'Devine d’abord à voix haute, puis vérifie.'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.word, required this.revealed});

  final Word word;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final Deck? deck = Vocabulary.deckById(word.deckId);
    final Color accent = Color(deck?.colorValue ?? 0xFFC4623F);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      child: Container(
        key: ValueKey<bool>(revealed),
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: GbeColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GbeColors.sand),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: GbeColors.ink.withValues(alpha: 0.05),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GbePill(
              label: (deck?.label ?? '').toUpperCase(),
              color: accent,
              icon: Icons.circle,
            ),
            const SizedBox(height: 28),
            Text(
              word.fon,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 44,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              word.pronunciation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 26),
            if (!revealed)
              const _Hint(text: 'Touche la carte pour révéler')
            else
              _Answer(word: word),
          ],
        ),
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 40, height: 3, color: GbeColors.sand),
        const SizedBox(height: 22),
        Text(
          word.french,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
        ),
        if (word.exampleFon != null) ...<Widget>[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GbeColors.cream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  word.exampleFon!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (word.exampleFrench != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    word.exampleFrench!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (word.note != null) ...<Widget>[
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 16, color: GbeColors.ochre),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  word.note!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RatingPad extends StatelessWidget {
  const _RatingPad({
    required this.store,
    required this.word,
    required this.onRate,
  });

  final ProgressStore store;
  final Word word;
  final void Function(Rating) onRate;

  @override
  Widget build(BuildContext context) {
    final CardState current =
        store.cardFor(word.id) ?? CardState(wordId: word.id, due: store.now);

    final List<_RatingSpec> specs = <_RatingSpec>[
      _RatingSpec('À revoir', Rating.again, GbeColors.danger),
      _RatingSpec('Difficile', Rating.hard, GbeColors.warning),
      _RatingSpec('Bien', Rating.good, GbeColors.forest),
      _RatingSpec('Facile', Rating.easy, GbeColors.plum),
    ];

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < 2; i++) ...<Widget>[
              Expanded(
                child: _RatingButton(
                  spec: specs[i],
                  interval: Srs.intervalLabel(current, specs[i].rating, store.now),
                  onTap: () => onRate(specs[i].rating),
                ),
              ),
              if (i == 0) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            for (int i = 2; i < 4; i++) ...<Widget>[
              Expanded(
                child: _RatingButton(
                  spec: specs[i],
                  interval: Srs.intervalLabel(current, specs[i].rating, store.now),
                  onTap: () => onRate(specs[i].rating),
                ),
              ),
              if (i == 2) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _RatingSpec {
  const _RatingSpec(this.label, this.rating, this.color);

  final String label;
  final Rating rating;
  final Color color;
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.spec,
    required this.interval,
    required this.onTap,
  });

  final _RatingSpec spec;
  final String interval;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: spec.color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: spec.color.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                spec.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: spec.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                interval,
                style: const TextStyle(fontSize: 12, color: GbeColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
    );
  }
}

/// Écran de fin de session : la récompense doit rester sobre mais satisfaisante.
class _SessionSummary extends StatelessWidget {
  const _SessionSummary({
    required this.title,
    required this.answered,
    required this.correct,
    required this.onDone,
  });

  final String title;
  final int answered;
  final int correct;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final int accuracy = answered == 0 ? 0 : ((correct / answered) * 100).round();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: GbeColors.forest.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 48, color: GbeColors.forest),
              ),
              const SizedBox(height: 28),
              Text(
                answered == 0 ? 'Rien à réviser' : 'Session terminée',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                answered == 0
                    ? 'Reviens plus tard : les mots reviennent au bon moment.'
                    : answered == 1
                        ? '1 carte révisée en $title'
                        : '$answered cartes révisées en $title',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (answered > 0) ...<Widget>[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    StatTile(value: '$correct', label: 'retenues', color: GbeColors.forest),
                    const SizedBox(width: 40),
                    StatTile(value: '$accuracy %', label: 'de réussite'),
                  ],
                ),
              ],
              const Spacer(),
              FilledButton(onPressed: onDone, child: const Text('Continuer')),
            ],
          ),
        ),
      ),
    );
  }
}
