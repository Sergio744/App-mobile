/// Modèles de données de Gbè.
///
/// Un [Deck] est un thème (« Saluer », « Nourriture »…) et un [Word] est une
/// entrée de lexique. Ces deux objets sont immuables : l'état d'apprentissage
/// d'un mot vit dans `CardState`, jamais dans le mot lui-même.
library;

class Deck {
  const Deck(this.id, this.label, this.subtitle, this.emoji, this.colorValue);

  final String id;
  final String label;
  final String subtitle;
  final String emoji;
  final int colorValue;

  @override
  String toString() => 'Deck($id)';
}

class Word {
  const Word(
    this.id,
    this.fon,
    this.french,
    this.deckId,
    this.pronunciation, [
    this.exampleFon,
    this.exampleFrench,
    this.note,
  ]);

  /// Identifiant stable : sert de clé de progression. Ne jamais le changer,
  /// sinon l'utilisateur perd son historique sur ce mot.
  final String id;

  /// Le mot en fɔ̀ngbè, avec les tons (le mot peut contenir des espaces).
  final String fon;

  /// Traduction française courte.
  final String french;

  final String deckId;

  /// Prononciation approximative à la française, entre crochets.
  final String pronunciation;

  final String? exampleFon;
  final String? exampleFrench;

  /// Note culturelle ou grammaticale affichée au verso de la carte.
  final String? note;

  @override
  String toString() => 'Word($id, $fon)';
}
