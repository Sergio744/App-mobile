import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/progress_store.dart';
import '../data/vocabulary.dart';
import '../widgets/common.dart';

/// Trois écrans pour expliquer la promesse et faire choisir un objectif.
/// Volontairement très court : chaque écran supplémentaire perd des gens.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.store, required this.onDone});

  final ProgressStore store;
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  int _goal = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 2) {
      widget.store.setDailyGoal(_goal);
      widget.store.setOnboarded();
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GbeProgressBar(value: (_page + 1) / 3, height: 5),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      widget.store.setOnboarded();
                      widget.onDone();
                    },
                    child: const Text('Passer'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _page = i),
                children: <Widget>[
                  const _Page1(),
                  const _Page2(),
                  _Page3(
                    goal: _goal,
                    onGoal: (int g) => setState(() => _goal = g),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: <Widget>[
                  FilledButton(
                    onPressed: _next,
                    child: Text(_page == 2 ? 'Commencer' : 'Continuer'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sans compte · sans publicité · hors-ligne',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
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

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GbePill(label: 'FƆ̀NGBÈ', color: GbeColors.terracotta, icon: Icons.circle),
          const SizedBox(height: 24),
          Text(
            'Une langue\nse transmet\nà l’oral.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 44),
          ),
          const SizedBox(height: 20),
          Text(
            'Gbè t’aide à garder le fon vivant : des mots justes, leurs tons, et le moment exact où les réviser.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GbeColors.inkSoft,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            children: <Widget>[
              GbePill(label: '${Vocabulary.words.length} mots', color: GbeColors.forest),
              const SizedBox(width: 8),
              const GbePill(label: '9 thèmes', color: GbeColors.ochre),
              const SizedBox(width: 8),
              const GbePill(label: 'hors-ligne', color: GbeColors.plum),
            ],
          ),
        ],
      ),
    );
  }
}

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Trois minutes,\npuis on oublie\nvolontairement.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 18),
          Text(
            'La répétition espacée replace chaque mot juste avant que tu ne l’oublies. Moins de temps, plus de mémoire.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GbeColors.inkSoft,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 30),
          GbeCard(
            child: Column(
              children: <Widget>[
                _SrsRow(label: 'Oublié', interval: '10 min', color: GbeColors.danger),
                const SizedBox(height: 12),
                _SrsRow(label: 'Difficile', interval: '4 jours', color: GbeColors.warning),
                const SizedBox(height: 12),
                _SrsRow(label: 'Bien', interval: '8 jours', color: GbeColors.forest),
                const SizedBox(height: 12),
                _SrsRow(label: 'Facile', interval: '1 mois', color: GbeColors.plum),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SrsRow extends StatelessWidget {
  const _SrsRow({required this.label, required this.interval, required this.color});

  final String label;
  final String interval;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(
          interval,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3({required this.goal, required this.onGoal});

  final int goal;
  final ValueChanged<int> onGoal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Combien de mots\npar jour ?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Tu pourras changer d’avis à tout moment.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GbeColors.inkSoft,
                ),
          ),
          const SizedBox(height: 30),
          ...<MapEntry<int, String>>[
            const MapEntry<int, String>(5, 'Léger — 5 mots, 2 minutes'),
            const MapEntry<int, String>(10, 'Régulier — 10 mots, 4 minutes'),
            const MapEntry<int, String>(20, 'Intensif — 20 mots, 8 minutes'),
          ].map((MapEntry<int, String> e) {
            final bool selected = goal == e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: selected ? GbeColors.forest.withValues(alpha: 0.08) : GbeColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onGoal(e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? GbeColors.forest : GbeColors.sand,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            e.value,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight:
                                      selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: GbeColors.forest, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
