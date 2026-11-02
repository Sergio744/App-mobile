# 1. Le concept

## L'idée en une phrase

**Gbè** est une app mobile qui permet d'apprendre le vocabulaire fon avec la répétition
espacée : on révise quelques mots par jour, l'app reprogramme chacun au moment exact où on
risque de l'oublier.

> *gbè* veut dire « langue », « voix » en fon. **Fɔ̀ngbè** = « la langue fon ».

## Pourquoi ce concept, pour toi précisément

Tu n'es pas sûr de la niche, tu n'as **aucun public déjà acquis**, tu as **moins de 5 h par
semaine**, et ton objectif est un **projet qui montre ce que tu sais faire**. Ces quatre
contraintes éliminent la majorité des idées d'app :

| Contrainte | Conséquence |
|---|---|
| Aucun public | On ne fait ni réseau social, ni marketplace, ni app « communautaire ». Une app **locale et hors-ligne** fonctionne parfaitement avec un seul utilisateur : toi. |
| Moins de 5 h/semaine | Pas de backend, pas de comptes, pas de synchronisation, pas de modération. Périmètre borné, chaque session laisse une app qui marche. |
| Objectif portfolio | On privilégie l'exécution visible : algorithmique propre, animations, typographie, tests. Pas le nombre d'utilisateurs. |
| Tu codes | On peut viser un vrai projet technique : un algorithme testé, une architecture lisible. |

**Pour un portfolio, la niche ne compte pas — la singularité compte.** Un vingtième
« habit tracker » cloné d'un tutoriel n'apprend rien au recruteur. Une app de langue
minoritaire, avec un vrai algorithme et une vraie direction artistique, reste en mémoire.

## Le problème réel

Le fon est parlé par plusieurs millions de personnes au Bénin, mais il se transmet de moins
en moins entre générations, et surtout **à l'oral**. Les rares ressources écrites sont des
PDF, des dictionnaires de spécialistes ou des pages web sans suivi. Deux douleurs :

1. **Les outils existants ne sont pas des outils d'apprentissage** : ce sont des listes de
   mots. Aucun ne s'adapte à ce que tu as déjà retenu.
2. **Les apps existantes ne sont pas pensées pour les Béninois** : bilingues approximatives,
   faites pour des touristes et des coopérants, souvent lentes ou connectées.

Gbè répond aux deux : un contenu respectueux et vérifié, une pédagogie qui marche
(la répétition espacée), et une app qui fonctionne sans réseau ni compte.

## La promesse produit

> Trois minutes par jour pour ne plus perdre ton fon.

Trois engagements, affichés dès l'onboarding parce qu'ils sont vérifiables dans le code :

- **Hors-ligne par défaut** — le lexique est embarqué, la progression est locale.
- **Sans compte** — aucune donnée ne quitte l'appareil.
- **Nº 1 sur l'oralité** — chaque mot porte ses tons, sa prononciation, et souvent une note
  culturelle, parce que la langue ne se réduit pas à une traduction.

## Public

Primaire : jeunes Béninois (15-35 ans) et membres de la diaspora, souvent déjà exposés au
fon mais incapables de le parler couramment, qui veulent **renouer** avec la langue.

Secondaire : francophones établis au Bénin (coopérants, humanitaires, fonciers, conjoints)
qui veulent tenir une conversation minimale.

Ce que cela implique dans l'app : interface **en français** (le public est bilingue
français/fon), salutations **situées** selon l'heure, et **notes culturelles** plutôt que
simples traductions.

## Ce que ce projet prouve à un recruteur

- Un **algorithme non trivial** (répétition espacée) implémenté proprement, isolé de l'UI,
  testé sur ses cas limites — pas 30 000 lignes, mais des décisions justifiées.
- Une **architecture lisible** : modèles immuables, source de vérité unique
  (`ProgressStore`), séparation données / logique / présentation.
- Une **robustesse de bas niveau** : persistance JSON tolérante aux données corrompues,
  migration de schéma possible par version de clé.
- Un **sens du produit** : onboarding en 3 écrans, objectif quotidien, état vide,
  états d'apprentissage, série (« streak ») sans manipulation.
- Une **direction artistique** assumée : palette terre/raphia, typographie, micro-animations.
- Une **honnêteté intellectuelle** : les données linguistiques sont sourcées et un verdict
  de relecture native est explicitement affiché dans l'app.

## Ce que le projet n'est pas

- Pas de monétisation au départ, pas de leaderboard, pas de gamification agressive.
- Pas de reconnaissance vocale ni de TTS : ce serait un piège technique et éthique
  (prononciation tonale approximative désapprendrait plus qu'elle n'enseignerait).
- Pas de synchronisation cloud tant que le hors-ligne n'est pas irréprochable.
