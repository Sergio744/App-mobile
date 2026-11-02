import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/card_state.dart';
import '../models/word.dart';
import 'vocabulary.dart';

/// Journal d'une journée d'étude, pour la série (« streak »).
@immutable
class DayLog {
  const DayLog({required this.day, required this.reviews, required this.newWords});

  /// Jour sans heure, au format AAAA-MM-JJ.
  final String day;
  final int reviews;
  final int newWords;
}

/// Source de vérité unique de la progression.
///
/// Volontairement sans backend : la promesse « fonctionne hors-ligne » est plus
/// forte qu'une synchronisation bancale, et c'est aussi ce qui rend le projet
/// tenable en moins de 5 h par semaine.
class ProgressStore extends ChangeNotifier {
  ProgressStore(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _load();
  }

  static const String _kCards = 'gbe.cards.v1';
  static const String _kDays = 'gbe.days.v1';
  static const String _kOnboarded = 'gbe.onboarded.v1';
  static const String _kDailyGoal = 'gbe.dailyGoal.v1';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  final Map<String, CardState> _cards = <String, CardState>{};
  final Map<String, DayLog> _days = <String, DayLog>{};
  bool _onboarded = false;
  int _dailyGoal = 10;
  bool _loaded = false;

  DateTime get now => _clock();
  bool get isLoaded => _loaded;
  bool get onboarded => _onboarded;
  int get dailyGoal => _dailyGoal;

  // ───────────────────────────── Lecture ─────────────────────────────

  CardState? cardFor(String wordId) => _cards[wordId];

  /// Tous les mots triés par priorité de révision :
  /// d'abord les mots neufs, puis les mots dus du plus en retard au plus récent.
  List<Word> get queue {
    final DateTime reference = now;
    final List<Word> due = <Word>[];
    final List<Word> fresh = <Word>[];

    for (final Word w in _allWords()) {
      final CardState? c = _cards[w.id];
      if (c == null || c.isNew) {
        fresh.add(w);
      } else if (c.isDue(reference)) {
        due.add(w);
      }
    }

    due.sort((Word a, Word b) {
      final DateTime da = _cards[a.id]!.due;
      final DateTime db = _cards[b.id]!.due;
      return da.compareTo(db);
    });

    return <Word>[...due, ...fresh];
  }

  /// Ce qui reste à faire aujourd'hui, plafonné par l'objectif quotidien.
  int get remainingToday {
    final int done = reviewsToday;
    final int left = _dailyGoal - done;
    final int available = queue.length;
    if (left <= 0) return 0;
    return left < available ? left : available;
  }

  int get reviewsToday => _days[_key(now)]?.reviews ?? 0;

  int get newWordsToday => _days[_key(now)]?.newWords ?? 0;

  int get totalReviews {
    int total = 0;
    for (final DayLog d in _days.values) {
      total += d.reviews;
    }
    return total;
  }

  /// Nombre de jours consécutifs avec au moins une révision, en terminant
  /// aujourd'hui **ou** hier (sinon la série semblerait cassée le matin).
  int get streak {
    int count = 0;
    DateTime cursor = DateTime(now.year, now.month, now.day);
    if ((_days[_key(cursor)]?.reviews ?? 0) == 0) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (true) {
      final DayLog? log = _days[_key(cursor)];
      if (log == null || log.reviews == 0) break;
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Nombre de mots acquis (intervalle long et révisions réussies).
  int get acquiredCount =>
      _cards.values.where((CardState c) => c.isAcquired).length;

  int get learningCount =>
      _cards.values.where((CardState c) => c.isLearning).length;

  /// Pourcentage de maîtrise du lexique, 0 → 1.
  double get mastery {
    final int total = _allWords().length;
    if (total == 0) return 0;
    double sum = 0;
    for (final Word w in _allWords()) {
      sum += _cards[w.id]?.strength ?? 0;
    }
    return sum / total;
  }

  double deckMastery(String deckId) {
    final List<Word> deckWords = _allWords().where((Word w) => w.deckId == deckId).toList();
    if (deckWords.isEmpty) return 0;
    double sum = 0;
    for (final Word w in deckWords) {
      sum += _cards[w.id]?.strength ?? 0;
    }
    return sum / deckWords.length;
  }

  int deckSeen(String deckId) => _allWords()
      .where((Word w) => w.deckId == deckId)
      .where((Word w) => _cards[w.id]?.isNew == false)
      .length;

  /// Les 7 derniers jours, du plus ancien à aujourd'hui (pour l'histogramme).
  List<DayLog> lastSevenDays() {
    final DateTime today = DateTime(now.year, now.month, now.day);
    return List<DayLog>.generate(7, (int i) {
      final DateTime d = today.subtract(Duration(days: 6 - i));
      return _days[_key(d)] ??
          DayLog(day: _key(d), reviews: 0, newWords: 0);
    });
  }

  // ───────────────────────────── Écriture ─────────────────────────────

  /// Enregistre une révision. Renvoie l'état mis à jour.
  CardState recordReview(Word word, CardState next) {
    final bool wasNew = _cards[word.id]?.isNew ?? true;
    _cards[word.id] = next;

    final String key = _key(now);
    final DayLog existing =
        _days[key] ?? DayLog(day: key, reviews: 0, newWords: 0);
    _days[key] = DayLog(
      day: key,
      reviews: existing.reviews + 1,
      newWords: existing.newWords + (wasNew ? 1 : 0),
    );

    _persist();
    return next;
  }

  void setOnboarded() {
    _onboarded = true;
    _prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    _prefs.setInt(_kDailyGoal, goal);
    notifyListeners();
  }

  /// Réinitialise tout (utile en démo, et en développement).
  Future<void> reset() async {
    _cards.clear();
    _days.clear();
    _onboarded = false;
    _dailyGoal = 10;
    await _prefs.remove(_kCards);
    await _prefs.remove(_kDays);
    await _prefs.remove(_kOnboarded);
    await _prefs.remove(_kDailyGoal);
    notifyListeners();
  }

  // ───────────────────────────── Interne ─────────────────────────────

  List<Word> _allWords() => Vocabulary.words;

  void _load() {
    try {
      final String? rawCards = _prefs.getString(_kCards);
      if (rawCards != null) {
        final Map<String, dynamic> decoded =
            jsonDecode(rawCards) as Map<String, dynamic>;
        decoded.forEach((String id, dynamic value) {
          _cards[id] = CardState.fromJson(value as Map<String, dynamic>);
        });
      }

      final String? rawDays = _prefs.getString(_kDays);
      if (rawDays != null) {
        final Map<String, dynamic> decoded =
            jsonDecode(rawDays) as Map<String, dynamic>;
        decoded.forEach((String day, dynamic value) {
          final Map<String, dynamic> m = value as Map<String, dynamic>;
          _days[day] = DayLog(
            day: day,
            reviews: (m['reviews'] as num?)?.toInt() ?? 0,
            newWords: (m['newWords'] as num?)?.toInt() ?? 0,
          );
        });
      }

      _onboarded = _prefs.getBool(_kOnboarded) ?? false;
      _dailyGoal = _prefs.getInt(_kDailyGoal) ?? 10;
    } catch (error) {
      // Des données corrompues ne doivent jamais bloquer l'app : on repart propre.
      debugPrint('ProgressStore: données illisibles, réinitialisation ($error)');
      _cards.clear();
      _days.clear();
    }
    _loaded = true;
    notifyListeners();
  }

  void _persist() {
    final Map<String, dynamic> cards = <String, dynamic>{};
    _cards.forEach((String id, CardState c) => cards[id] = c.toJson());

    final Map<String, dynamic> days = <String, dynamic>{};
    _days.forEach((String key, DayLog d) {
      days[key] = <String, dynamic>{'reviews': d.reviews, 'newWords': d.newWords};
    });

    _prefs.setString(_kCards, jsonEncode(cards));
    _prefs.setString(_kDays, jsonEncode(days));
    notifyListeners();
  }

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
