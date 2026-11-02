# 4. Sources du lexique

Chaque entrée de `app/lib/data/vocabulary.dart` a été recoupée sur au moins deux des sources
ci-dessous. **Ce document existe pour que la relecture native soit possible et traçable** :
une app de langue sans sources n'est pas vérifiable, donc pas crédible.

## Sources consultées

| # | Source | Type | Usage |
|---|---|---|---|
| 1 | *Common Fon Phrases*, lughayangu.com | liste de phrases | salutations, formules de politesse |
| 2 | *Fon language: essential phrases for travelers*, visitabomey.com | guide de voyage | salutations, expressions du quotidien |
| 3 | *Say Hello and Greetings in Fon*, polyglotclub.com | wiki collaboratif | variantes de salutations, réponses |
| 4 | *Fon language*, Grokipedia | encyclopédie | tons, contexte culturel, salutations horaires |
| 5 | *Guide d'apprentissage en Fon*, Peace Corps (livelingua.com) | manuel de formation | pronoms, famille, verbes, salutations |
| 6 | *Greetings in more than 3000 languages*, users.elite.net | base de données | recoupement des salutations |
| 7 | *Les salutations les plus importantes en fon*, oocities.org/fon_is_fun | ressource associative | usages culturels, réponses rituelles |
| 8 | *Apprendre le Fon*, parrainagepaulbert.free.fr | fiche pédagogique | nombres, jours, pronoms |
| 9 | *Useful Fon Vocabulary*, oocities.org/fon_is_fun | lexique thématique | nature, animaux, nourriture, famille |
| 10 | *Fɔ̀ngbè — 87 mots essentiels*, langmaps.com | lexique phonétique | corps, nature, nombres, tons |
| 11 | *Comment dire bonjour en fon*, parlons-fongbe.com | cours en ligne | salutations horaires, Ɛ et Ɔ |
| 12 | *Dictionnaire syntaxique fɔ̀ngbè*, fongbebenin.com | dictionnaire | exemples en contexte, usage |

## Points de vigilance relevés

Ces divergences sont **normales** (la langue n'est pas standardisée) et doivent être tranchées
par des natifs, pas par une IA :

1. **« Merci »** — trois formes circulent : `kú dó nú wè`, `àwǎnú`, `kúdó`. Le lexique retient
   `kú dó nú wè` (forme la plus fréquente dans les guides), avec `tawun` pour « beaucoup ».
2. **« Bonjour »** — `kúdó` seul, ou précisé par le moment : `kúdó zǎnzǎn` (matin),
   `kúdó hwemɛ` (après-midi), `kúdó gbadà` (soir). Certaines sources donnent
   `a fɔ́n ganji à ?` comme salutation du matin : c'est une question, pas un équivalent strict.
3. **« Au revoir »** — `odàbò` est le plus universel ; `ma yi bo wá` (« va et reviens ») est
   plus chaleureux. Les deux sont conservés, avec la nuance en note.
4. **« Non »** — `eo` et `eho` coexistent ; le lexique retient `eo` et le signale en note.
5. **« Chat »** — `kpɔnyɔ́` et `asé` selon les régions ; la note le précise.
6. **Orthographe des tons** — l'usage des accents (´ ` ˇ) varie d'une source à l'autre.
   Le lexique suit la notation la plus répandue chez les ressources pédagogiques récentes
   (accent aigu = ton haut, accent grave = ton bas, caron = ton montant).
7. **Nombres** — `atɔ́ɔ́n` (5), `ayizɛ́n` (6), `tɛ́nwé` (7), `tantɔn` (8), `tɛ́nnɛ` (9),
   `wǒ` (10). Les formes varient ; elles sont cohérentes avec la source 8.

## Ce qui reste à faire

- [ ] Relecture intégrale par **deux locuteurs natifs** (régions différentes).
- [ ] Enregistrement audio par un natif (phase 2 de la feuille de route).
- [ ] Ajouter une colonne « source » par entrée, pour la traçabilité.
- [ ] Décider d'une convention orthographique unique et la documenter dans l'app.
