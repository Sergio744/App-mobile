import 'package:flutter/foundation.dart';

/// État d'apprentissage d'un mot : c'est ce que l'algorithme SM-2 fait évoluer.
@immutable
class CardState {
  const CardState({
    required this.wordId,
    required this.due,
    this.ease = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.lapses = 0,
    this.reviews = 0,
    this.lastReviewed,
  });

  final String wordId;

  /// Facteur de facilité (SM-2). Plus il est haut, plus les intervalles
  /// s'allongent vite. Borné entre 1.3 et 2.8 par [Srs].
  final double ease;

  final int intervalDays;

  /// Nombre de réussites consécutives.
  final int repetitions;

  /// Nombre de fois où le mot a été oublié (« À revoir »).
  final int lapses;

  /// Nombre total de révisions, tous résultats confondus.
  final int reviews;

  /// Date (heure incluse) de la prochaine révision.
  final DateTime due;

  final DateTime? lastReviewed;

  bool get isNew => reviews == 0;

  /// « Acquis » : intervalle long et plusieurs réussites d'affilée.
  bool get isAcquired => intervalDays >= 21 && repetitions >= 3;

  /// « En cours » : déjà rencontré mais pas encore acquis.
  bool get isLearning => !isNew && !isAcquired;

  bool isDue(DateTime now) => !due.isAfter(now);

  /// Progression visuelle 0 → 1, utilisée par les barres de progression.
  double get strength {
    if (isNew) return 0;
    final double r = (intervalDays / 21).clamp(0.0, 1.0).toDouble();
    return 0.15 + r * 0.85;
  }

  CardState copyWith({
    double? ease,
    int? intervalDays,
    int? repetitions,
    int? lapses,
    int? reviews,
    DateTime? due,
    DateTime? lastReviewed,
  }) {
    return CardState(
      wordId: wordId,
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      lapses: lapses ?? this.lapses,
      reviews: reviews ?? this.reviews,
      due: due ?? this.due,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'wordId': wordId,
        'ease': ease,
        'intervalDays': intervalDays,
        'repetitions': repetitions,
        'lapses': lapses,
        'reviews': reviews,
        'due': due.toIso8601String(),
        'lastReviewed': lastReviewed?.toIso8601String(),
      };

  static CardState fromJson(Map<String, dynamic> json) {
    return CardState(
      wordId: json['wordId'] as String,
      ease: (json['ease'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      due: DateTime.tryParse(json['due'] as String? ?? '') ?? DateTime.now(),
      lastReviewed: DateTime.tryParse(json['lastReviewed'] as String? ?? ''),
    );
  }

  @override
  String toString() =>
      'CardState($wordId, interval=${intervalDays}j, ease=${ease.toStringAsFixed(2)}, reps=$repetitions)';
}
