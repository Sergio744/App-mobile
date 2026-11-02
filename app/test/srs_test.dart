import 'package:flutter_test/flutter_test.dart';

import 'package:gbe/core/srs.dart';
import 'package:gbe/models/card_state.dart';

/// Tests de l'algorithme : c'est la partie du projet qui doit être fiable à
/// 100 %. On peut les lancer sans appareil ni émulateur : `flutter test`.
void main() {
  final DateTime t0 = DateTime(2026, 11, 2, 9);

  CardState fresh({DateTime? now}) => CardState(
        wordId: 'w1',
        due: now ?? t0,
      );

  group('Premier contact', () {
    test('un mot neuf est dû et sans historique', () {
      final CardState c = fresh();
      expect(c.isNew, isTrue);
      expect(c.isDue(t0), isTrue);
      expect(c.strength, 0);
    });

    test('« Bien » planifie la première révision à 1 jour', () {
      final CardState next = Srs.review(fresh(), Rating.good, t0);
      expect(next.intervalDays, 1);
      expect(next.repetitions, 1);
      expect(next.reviews, 1);
      expect(next.due, t0.add(const Duration(days: 1)));
    });

    test('un premier « À revoir » ne baisse pas la facilité', () {
      final CardState next = Srs.review(fresh(), Rating.again, t0);
      expect(next.ease, 2.5);
      expect(next.lapses, 1);
      expect(next.intervalDays, 0);
      expect(next.due, t0.add(const Duration(minutes: Srs.relearnMinutes)));
    });

    test('« Facile » au premier contact augmente légèrement la facilité', () {
      expect(Srs.review(fresh(), Rating.easy, t0).ease, 2.65);
    });
  });

  group('Courbe d’apprentissage', () {
    test('deuxième réussite → 3 jours, puis allongement géométrique', () {
      CardState s = Srs.review(fresh(), Rating.good, t0); // 1 j
      s = Srs.review(s, Rating.good, t0.add(const Duration(days: 1))); // 3 j
      expect(s.intervalDays, 3);
      final CardState third = Srs.review(s, Rating.good, t0.add(const Duration(days: 4)));
      expect(third.intervalDays, (3 * 2.5).round()); // 8 j
      expect(third.intervalDays, greaterThan(s.intervalDays));
    });

    test('un oubli remet la série à zéro et compte un lapse', () {
      CardState s = Srs.review(fresh(), Rating.good, t0);
      s = Srs.review(s, Rating.good, t0.add(const Duration(days: 1)));
      final CardState forgotten =
          Srs.review(s, Rating.again, t0.add(const Duration(days: 4)));
      expect(forgotten.repetitions, 0);
      expect(forgotten.lapses, 1);
      expect(forgotten.intervalDays, 0);
      expect(forgotten.ease, closeTo(2.3, 1e-9));
      expect(forgotten.isAcquired, isFalse);
    });

    test('« Difficile » fait baisser la facilité et ralentir la courbe', () {
      CardState s = Srs.review(fresh(), Rating.good, t0); // 1 j
      s = Srs.review(s, Rating.good, t0.add(const Duration(days: 1))); // 3 j
      final CardState hard = Srs.review(s, Rating.hard, t0.add(const Duration(days: 4)));
      expect(hard.ease, closeTo(2.35, 1e-9));
      expect(hard.intervalDays, (3 * 1.2).round()); // 4 j
    });

    test('« Facile » allonge plus vite que « Bien »', () {
      CardState base = Srs.review(fresh(), Rating.good, t0);
      base = Srs.review(base, Rating.good, t0.add(const Duration(days: 1)));
      base = Srs.review(base, Rating.good, t0.add(const Duration(days: 4)));
      final CardState good = Srs.review(base, Rating.good, t0.add(const Duration(days: 12)));
      final CardState easy = Srs.review(base, Rating.easy, t0.add(const Duration(days: 12)));
      expect(easy.intervalDays, greaterThan(good.intervalDays));
      expect(easy.ease, greaterThan(good.ease));
    });
  });

  group('Bornes de sûreté', () {
    test('la facilité ne descend jamais sous 1.3', () {
      CardState s = fresh();
      for (int i = 0; i < 40; i++) {
        s = Srs.review(s, Rating.hard, t0);
      }
      expect(s.ease, Srs.minEase);
    });

    test('la facilité ne dépasse jamais 2.8', () {
      CardState s = fresh();
      for (int i = 0; i < 40; i++) {
        s = Srs.review(s, Rating.easy, t0);
      }
      expect(s.ease, Srs.maxEase);
    });

    test('l’intervalle croît toujours d’au moins un jour', () {
      CardState s = fresh();
      int previous = 0;
      for (int i = 0; i < 12; i++) {
        s = Srs.review(s, Rating.hard, t0);
        expect(s.intervalDays, greaterThan(previous));
        previous = s.intervalDays;
      }
    });

    test('la date de prochaine révision est toujours dans le futur', () {
      for (final Rating r in Rating.values) {
        final CardState next = Srs.review(fresh(), r, t0);
        expect(next.due.isAfter(t0), isTrue, reason: '$r');
      }
    });
  });

  group('Acquisition', () {
    test('un mot révisé régulièrement finit acquis', () {
      CardState s = fresh();
      DateTime cursor = t0;
      for (int i = 0; i < 6; i++) {
        s = Srs.review(s, Rating.good, cursor);
        cursor = s.due;
      }
      expect(s.isAcquired, isTrue);
      expect(s.intervalDays, greaterThanOrEqualTo(21));
    });

    test('humanDays formate lisiblement', () {
      expect(Srs.humanDays(1), '1 j');
      expect(Srs.humanDays(7), '7 j');
      expect(Srs.humanDays(45), '2 mois');
      expect(Srs.humanDays(400), '1 an');
    });

    test('intervalLabel annonce « 10 min » après un oubli', () {
      expect(Srs.intervalLabel(fresh(), Rating.again, t0), '10 min');
    });
  });

}
