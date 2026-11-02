# 2. Écrans et architecture

## Le parcours en 5 écrans

```
Onboarding (3 pages)   Accueil              Session              Fin de session
────────────────────   ──────────────       ──────────────       ──────────────
1. Promesse            1. Salutation fon    Carte au recto:      Cartes révisées
2. La méthode          2. "N mots à faire"  mot + prononciation  Taux de réussite
3. Objectif quotidien  3. Stats rapides     → révéler
                       4. 4 thèmes          → s'auto-évaluer     → retour accueil
                       5. Onglets
```

Trois onglets permanents :

| Onglet | Rôle |
|---|---|
| **Apprendre** | La session du jour, les statistiques rapides, les thèmes en cours |
| **Lexique** | Les 121 mots par thème, l'état de chaque mot, la fiche détaillée |
| **Progrès** | Série, histogramme 7 jours, objectif quotidien, maîtrise par thème |

## Pourquoi ces écrans, et pas d'autres

- **Pas de page de connexion** : la promesse « sans compte » doit être vraie dès l'ouverture.
  Chaque écran en moins, c'est un utilisateur en moins perdu.
- **L'accueil ne fait qu'une chose** : dire combien de mots restent aujourd'hui et lancer la
  session. Tout le reste est secondaire.
- **L'auto-évaluation à 4 boutons** (À revoir / Difficile / Bien / Facile) est l'écran le plus
  important de l'app : c'est lui qui alimente l'algorithme. Chaque bouton affiche
  l'intervalle qui en résultera (« 1 j », « 3 j », « 8 j », « 10 min »), ce qui rend la
  répétition espacée compréhensible au lieu d'être une boîte noire.

## Architecture

```
app/lib/
├── main.dart                 # bootstrap + coquille à 3 onglets
├── core/
│   ├── srs.dart              # algorithme de répétition espacée (Dart pur, testé)
│   └── theme.dart            # palette, typographie, styles
├── models/
│   ├── word.dart             # Word (lexique) et Deck (thème), immuables
│   └── card_state.dart       # CardState : ce que l'algorithme fait évoluer
├── data/
│   ├── vocabulary.dart       # 121 mots, 9 thèmes (le contenu)
│   └── progress_store.dart   # ChangeNotifier : source de vérité unique
├── screens/
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── study_screen.dart     # la session de révision
│   ├── library_screen.dart   # thèmes + liste + fiche mot
│   └── stats_screen.dart
└── widgets/common.dart       # composants partagés
```

### Les trois décisions structurantes

**1. L'algorithme ne connaît rien de Flutter.**
`core/srs.dart` ne dépend d'aucun widget : c'est une fonction pure
`(CardState, Rating, DateTime) → CardState`. Conséquence directe : 20 tests automatisés
tournent sans émulateur, en une seconde. C'est le genre de détail qui distingue un projet
d'apprentissage d'un projet prêt à évoluer.

**2. Une seule source de vérité : `ProgressStore`.**
Tous les écrans lisent le même `ChangeNotifier`. Pas d'état dupliqué, pas de synchronisation
entre écrans, pas de bug « la série ne s'est pas mise à jour ». En contrepartie : tout est
en mémoire (121 mots, c'est quelques kilo-octets — un problème qui n'existe pas).

**3. La date est injectable.**
`ProgressStore(prefs, clock: ...)` et `Srs.review(..., now)`. Sans cette précaution, un
algorithme dépendant du temps est **intestable**. C'est aussi ce qui permettra plus tard de
simuler « et si je revenais dans 3 mois ? » pour vérifier la courbe.

### Persistance

`shared_preferences` + JSON, deux clés versionnées :

- `gbe.cards.v1` — l'état de chaque mot (`CardState.toJson`)
- `gbe.days.v1` — le journal quotidien (`reviews`, `newWords`), pour la série

Le suffixe `.v1` est volontaire : le jour où le format change, on ajoute `.v2` et on migre,
sans casser la progression des utilisateurs existants. Une lecture JSON corrompue ne fait
jamais planter l'app : on repart propre, avec un log.

## L'algorithme, concrètement

Variante lisible du **SM-2** (SuperMemo 2), la famille d'algorithmes utilisée par Anki.

Trois variables par mot :

| Variable | Sens | Bornes |
|---|---|---|
| `ease` | facilité (facteur multiplicateur des intervalles) | 1.3 → 2.8 |
| `intervalDays` | nombre de jours avant la prochaine révision | ≥ 0 |
| `repetitions` | réussites consécutives | ≥ 0 |

Règles :

1. **Les deux premières réussites valent 1 jour puis 3 jours.** C'est l'étape
   d'apprentissage : on ne saute pas à 30 jours sur un mot vu une fois.
2. Ensuite, `intervalle = intervalle_précédent × facteur`, où le facteur vaut `× 1.2`
   (Difficile), `× ease` (Bien) ou `× ease × 1.3` (Facile).
3. **« À revoir » remet `repetitions` à 0**, augmente les oublis, baisse la facilité de 0.2,
   et replanifie le mot **dans 10 minutes**. Le mot est aussi replacé un peu plus loin dans
   la session en cours.
4. La facilité est bornée : elle ne descend jamais sous 1.3 (sinon les mots deviendraient
   impossibles à sortir de la pile) et ne dépasse pas 2.8.
5. Un intervalle croît **toujours d'au moins un jour**. Sans ce garde-fou, une facilité basse
   et un mauvais arrondi peuvent créer une boucle infinie — c'est un des tests.

Cas couverts par `app/test/srs_test.dart` : premier contact, courbe 1 j → 3 j → 8 j, oubli,
facilité bornée en bas et en haut, monotonie de l'intervalle sur 12 révisions « Difficile »,
acquisition après 6 révisions, sérialisation JSON, JSON incomplet.

## Comment lancer

```bash
# Prérequis : Flutter ≥ 3.27 (Dart ≥ 3.6)
cd app
flutter pub get
flutter test          # les 20+ tests de l'algorithme
flutter run           # sur un appareil ou un émulateur

# Prototype web (aucune installation)
cd prototype && python3 -m http.server 8080   # puis http://localhost:8080
```

Le prototype dans `prototype/` est une maquette fidèle : mêmes écrans, mêmes couleurs,
même algorithme porté en JavaScript, et `prototype/words.js` est **généré** depuis
`app/lib/data/vocabulary.dart` pour que les deux ne divergent jamais.
