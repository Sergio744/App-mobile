import '../models/card_state.dart';

/// Résultat d'une révision, du plus douloureux au plus facile.
enum Rating {
  /// « À revoir » — le mot est oublié.
  again,

  /// « Difficile » — retrouvé, mais avec effort.
  hard,

  /// « Bien » — retrouvé normalement.
  good,

  /// « Facile » — retrouvé sans effort.
  easy,
}

/// Algorithme de répétition espacée.
///
/// C'est une variante lisible du SM-2 de Piotr Woźniak (SuperMemo 2), la même
/// famille d'algorithme que celle utilisée par Anki. Elle est volontairement
/// simple : trois variables (`ease`, `repetitions`, `intervalDays`) suffisent,
/// et chaque règle est testée dans `test/srs_test.dart`.
///
/// Principe : plus un mot est retrouvé facilement, plus on attend longtemps
/// avant de le revoir — juste avant qu'il ne soit oublié.
class Srs {
  const Srs._();

  static const double minEase = 1.3;
  static const double maxEase = 2.8;

  /// Intervalles (en jours) utilisés pour les deux premières réussites.
  static const List<int> _firstIntervals = <int>[1, 3];

  /// Intervalle d'un mot oublié, en minutes : on le revoit dans la session.
  static const int relearnMinutes = 10;

  /// Applique une révision et renvoie le nouvel état du mot.
  ///
  /// [now] est injectable pour que les tests soient déterministes.
  static CardState review(CardState current, Rating rating, DateTime now) {
    final bool isFirstContact = current.reviews == 0;

    // 1) On calcule le nouveau facteur de facilité.
    final double ease = _nextEase(current.ease, rating, isFirstContact);

    // 2) On calcule le prochain intervalle et la série de réussites.
    late final int interval;
    late final int repetitions;
    late final int lapses;

    if (rating == Rating.again) {
      // Oublié : on repart de zéro et on revoit le mot tout de suite.
      interval = 0;
      repetitions = 0;
      lapses = current.lapses + 1;
    } else {
      lapses = current.lapses;
      repetitions = current.repetitions + 1;
      interval = _nextInterval(
        current: current,
        rating: rating,
        ease: ease,
        isFirstContact: isFirstContact,
      );
    }

    final DateTime due = rating == Rating.again
        ? now.add(const Duration(minutes: relearnMinutes))
        : now.add(Duration(days: interval));

    return current.copyWith(
      ease: ease,
      intervalDays: interval,
      repetitions: repetitions,
      lapses: lapses,
      reviews: current.reviews + 1,
      due: due,
      lastReviewed: now,
    );
  }

  static double _nextEase(double currentEase, Rating rating, bool isFirstContact) {
    if (isFirstContact) {
      // Un mot jamais vu ne doit pas être puni : on ne baisse pas sa facilité
      // sur le premier contact, on l'ajuste seulement vers le haut.
      return _clampEase(rating == Rating.easy ? currentEase + 0.15 : currentEase);
    }
    final double updated = switch (rating) {
      Rating.again => currentEase - 0.2,
      Rating.hard => currentEase - 0.15,
      Rating.good => currentEase,
      Rating.easy => currentEase + 0.15,
    };
    return _clampEase(updated);
  }

  static int _nextInterval({
    required CardState current,
    required Rating rating,
    required double ease,
    required bool isFirstContact,
  }) {
    // Étape d'apprentissage : 1 jour, puis 3 jours.
    final int step = isFirstContact ? 0 : current.repetitions;
    if (step < _firstIntervals.length) {
      // Étape d'apprentissage : l'intervalle est fixé par la série en cours,
      // quelle que soit la note (la note agit sur la facilité, plus tard).
      return _firstIntervals[step];
    }

    final int previous = current.intervalDays <= 0 ? _firstIntervals.last : current.intervalDays;
    final double factor = switch (rating) {
      Rating.again => 0.0, // jamais atteint ici
      Rating.hard => 1.2,
      Rating.good => ease,
      Rating.easy => ease * 1.3,
    };
    final int next = (previous * factor).round();
    // On garantit toujours au moins +1 jour pour ne pas boucler.
    return next <= previous ? previous + 1 : next;
  }

  static double _clampEase(double value) {
    if (value < minEase) return minEase;
    if (value > maxEase) return maxEase;
    return value;
  }

  /// Libellé de l'intervalle à venir : ce qui est affiché sur les boutons.
  /// Ex. « 1 j », « 3 j », « 1 mois », « 10 min ».
  ///
  /// `now` est accepté pour rester symétrique avec [review] et permettre à
  /// l'interface de calculer un libellé sans effet de bord.
  static String intervalLabel(CardState current, Rating rating, DateTime now) {
    if (rating == Rating.again) return '$relearnMinutes min';
    final bool isFirstContact = current.reviews == 0;
    final double ease = _nextEase(current.ease, rating, isFirstContact);
    final int interval = _nextInterval(
      current: current,
      rating: rating,
      ease: ease,
      isFirstContact: isFirstContact,
    );
    return humanDays(interval);
  }

  static String humanDays(int days) {
    if (days <= 0) return 'aujourd’hui';
    if (days == 1) return '1 j';
    if (days < 30) return '$days j';
    if (days < 365) {
      final double months = days / 30;
      return months < 1.5 ? '1 mois' : '${months.round()} mois';
    }
    final double years = days / 365;
    return years < 1.5 ? '1 an' : '${years.round()} ans';
  }
}
