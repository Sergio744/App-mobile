# Gbè — apprends le fon, un mot à la fois

**Gbè** (*gbè* = « langue, voix » en fon) est une app mobile Flutter pour apprendre le
vocabulaire **fɔ̀ngbè** avec la **répétition espacée** : quelques mots par jour, reprogrammés
au moment exact où tu risques de les oublier.

> ⚠️ **Projet personnel / portfolio.** Le lexique est une base de travail sourcée, à faire
> relire par un locuteur natif avant toute publication.

---

## Voir à quoi ça ressemble

| Dossier | Contenu |
|---|---|
| [`prototype/`](prototype/) | **Prototype cliquable** — tous les écrans, aucune installation |
| [`app/`](app/) | L'application Flutter (MVP complet) |
| [`docs/`](docs/) | Cadrage produit, architecture, feuille de route |

### Essayer le prototype

```bash
cd prototype && python3 -m http.server 8080
# → http://localhost:8080
```

C'est une maquette fidèle de l'app Flutter : mêmes écrans, mêmes couleurs, **même algorithme**
(porté en JavaScript). Le fichier `prototype/words.js` est généré depuis
`app/lib/data/vocabulary.dart`, pour que les deux versions ne divergent jamais.

### Lancer l'app

```bash
cd app
flutter pub get
flutter test     # 20+ tests de l'algorithme, sans émulateur
flutter run
```

Prérequis : Flutter ≥ 3.27 (Dart ≥ 3.6).

---

## Le produit en trois écrans

```
Onboarding              Accueil                    Session
──────────              ────────                   ───────
La promesse             « 10 mots »                kúdó zǎnzǎn
La méthode              Commencer                  [kou-do zan-zan]
L'objectif quotidien    Série · maîtrise           → Révéler
                                                   → À revoir / Difficile / Bien / Facile
                                                     avec l'intervalle annoncé
```

- **121 mots** en 9 thèmes (salutations, politesse, famille, nourriture, nombres, nature,
  corps, verbes, quotidien)
- **Répétition espacée** (variante lisible du SM-2), 4 notes, intervalles annoncés
- **Hors-ligne, sans compte** : le lexique est embarqué, la progression locale
- **Notes culturelles** : *hweví* = « poisson » veut littéralement dire « enfant du soleil »
- **Palette terre et raphia**, typographie serif, micro-animations

## Architecture

```
lib/
├── core/srs.dart              algorithme SM-2 — Dart pur, 0 dépendance Flutter
├── core/theme.dart            palette, typographie
├── models/word.dart           Word + Deck (immuables)
├── models/card_state.dart     l'état que l'algorithme fait évoluer
├── data/vocabulary.dart       le lexique (121 entrées)
├── data/progress_store.dart   ChangeNotifier — source de vérité unique
├── screens/                   onboarding, accueil, étude, lexique, stats
└── widgets/common.dart        composants partagés
```

### Trois décisions dont je suis content

1. **L'algorithme ne connaît pas Flutter.** `Srs.review(CardState, Rating, now) → CardState`
   est une fonction pure — donc 20 tests automatisés qui tournent en une seconde, sans
   appareil. Les cas limites (facilité bornée, intervalle qui doit toujours croître,
   oubli, acquisition) sont tous couverts.
2. **La date est injectable.** Un algorithme dépendant de `DateTime.now()` est intestable.
   Ici `now` est un paramètre, ce qui permet de simuler « et si je revenais dans 3 mois ? ».
3. **Une seule source de vérité.** Tous les écrans écoutent le même `ProgressStore` :
   pas d'état dupliqué, pas de bug de synchronisation entre onglets.

### L'algorithme en cinq règles

| Règle | Détail |
|---|---|
| Étape d'apprentissage | les deux premières réussites valent 1 jour, puis 3 jours |
| Croissance | `intervalle × 1.2` (Difficile), `× ease` (Bien), `× ease × 1.3` (Facile) |
| Oubli | série remise à zéro, facilité −0.2, mot replanifié dans **10 minutes** |
| Bornes de facilité | jamais sous 1.3, jamais au-dessus de 2.8 |
| Garde-fou | l'intervalle croît **toujours** d'au moins un jour (évite les boucles) |

## Le lexique

Les entrées sont **recoupées sur plusieurs sources** : guides de conversation fon,
dictionnaires fɔ̀ngbè-français, lexiques associatifs, manuel de formation type Peace Corps.

L'orthographe du fon n'est pas unifiée : les tons (´ ` ˇ) changent le sens, et les sources
divergent parfois. Le lexique du dépôt est donc une **base de travail**, pas une référence
académique — et l'app le dit elle-même à l'utilisateur.

**Prochaine étape prioritaire : la relecture par deux locuteurs natifs** (voir
[`docs/03-roadmap.md`](docs/03-roadmap.md), phase 1).

## Ce que ce projet n'est pas

Pas de backend, pas de compte, pas de réseau social, pas de monétisation, pas de synthèse
vocale (les tons seraient faux). Le vrai risque de ce genre de projet n'est pas le manque de
fonctionnalités, c'est de ne pas finir.

## Licence

Code sous MIT. Contenu linguistique : à valider et attribuer avant toute diffusion publique.
