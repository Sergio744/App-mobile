# 3. Feuille de route en sessions de 2 à 3 h

Le MVP est déjà dans ce dépôt. Cette feuille de route sert à construire **par-dessus**, une
session à la fois, en gardant toujours une app qui fonctionne à la fin de chaque session.

La règle : une session = une fonctionnalité utilisable, testée, commitée. Jamais
« commencer le design » puis « finir le design » trois semaines plus tard.

---

## Phase 0 — Faire tourner le projet (1 session)

À faire toi-même en premier, parce que c'est là que tu apprends le plus.

- [ ] Installer Flutter (`flutter doctor` doit être vert).
- [ ] `cd app && flutter pub get && flutter test` → les tests passent.
- [ ] `flutter run` sur un appareil réel.
- [ ] Parcourir le prototype web et noter 5 choses qui te déplaisent.

**Livrable :** l'app tourne sur ton téléphone.
**Piège à éviter :** passer 3 soirées sur la configuration Android. Si ça bloque plus d'une
session, passe sur `flutter run -d chrome` et reviens-y plus tard.

---

## Phase 1 — Rendre le contenu juste (2 sessions) ⚠️ la plus importante

C'est le seul travail que tu ne peux pas déléguer à l'IA : **la validité linguistique**.

- [ ] Imprimer / exporter la liste des 121 mots (`app/lib/data/vocabulary.dart`).
- [ ] La faire relire par **deux locuteurs natifs** du fon, si possible de régions
      différentes (Abomey, Porto-Novo, Ouidah).
- [ ] Noter chaque désaccord : l'orthographe du fon n'est pas unifiée, c'est normal.
      Documenter le choix retenu dans une colonne « source ».
- [ ] Corriger le fichier, ajouter les mots manquants.

**Livrable :** un lexique relu, avec les corrections appliquées.
**C'est aussi le meilleur contenu pour ton portfolio :** un commit « lexique relu par deux
locuteurs natifs, sources documentées » raconte une histoire que personne d'autre n'aura.

---

## Phase 2 — L'audio (2 sessions)

La prononciation est le point faible de toute app de langue écrite.

- [ ] Enregistrer les 121 mots avec un locuteur natif (téléphone suffit, dans une pièce
      calme, format m4a).
- [ ] Normaliser le volume (Audacity, effet « Normaliser »), exporter en `.m4a` mono 64 kbps.
- [ ] Placer dans `app/assets/audio/<id_du_mot>.m4a`, ajouter `assets/` au `pubspec.yaml`.
- [ ] Ajouter un bouton 🔊 sur la carte d'étude et la fiche mot (`just_audio`).

**Livrable :** chaque mot se prononce d'un tap.
**Détail qui compte :** ne pas utiliser de synthèse vocale. Les tons du fon seraient faux, et
enseigner une mauvaise prononciation est pire que de ne rien enseigner.

---

## Phase 3 — La session du jour, mieux réglée (1 session)

- [ ] Limiter le nombre de **nouveaux** mots par jour (aujourd'hui, la file met les mots
      neufs après les révisions, mais rien ne plafonne les nouveautés).
- [ ] Ajouter un réglage « nouveaux mots par jour » à côté de l'objectif.
- [ ] Tester la sensation : 10 nouveaux mots d'un coup est trop dur le lendemain.

**Livrable :** un réglage dans l'écran Progrès, et une file qui respecte le plafond.

---

## Phase 4 — Type de carte « production » (2 sessions)

Aujourd'hui on reconnaît le fon → français. On ne *produit* pas.

- [ ] Ajouter un type de carte inverse : français → fon (saisie libre ou choix multiple).
- [ ] Stocker le type dans `CardState` (un mot peut avoir deux états indépendants).
- [ ] Adapter l'algorithme : la production est plus difficile, prévoir un bonus/malus.

**Livrable :** deux modes de révision, sélectionnables dans l'onboarding.
**C'est la fonctionnalité qui fait passer un prototype à une vraie app d'apprentissage.**

---

## Phase 5 — Finitions de démo (1 session)

Ce sont ces détails qu'on remarque dans une vidéo de 30 secondes.

- [ ] Police serif pour les titres (Fraunces ou Literata, licence libre) — voir le commentaire
      dans `core/theme.dart`.
- [ ] Haptique plus fine sur la révélation et les boutons.
- [ ] Écran d'accueil avant première utilisation (état vide) soigné.
- [ ] Icône d'app + écran de démarrage.
- [ ] Notifications locales à 8 h (« 12 mots t'attendent en fɔ̀ngbè »).

**Livrable :** une app qu'on peut filmer.

---

## Phase 6 — Le portfolio (1 session)

- [ ] Enregistrer une vidéo de 45 s : onboarding → session → progression.
- [ ] Captures d'écran sur 3 écrans, avec la palette.
- [ ] README soigné avec l'architecture et les décisions techniques.
- [ ] Publier sur GitHub Pages le prototype cliquable (dossier `prototype/`) : un recruteur
      peut essayer l'app **sans rien installer**. C'est un avantage énorme.

---

## Ce qu'on ne fait PAS (pour l'instant)

Ces idées sont bonnes mais elles tueraient le projet en moins de 5 h/semaine :

- ❌ Backend, comptes, synchronisation multi-appareils
- ❌ Réseau social, classements, partage
- ❌ Monétisation (abonnement) — à envisager seulement après 100 utilisateurs réels
- ❌ Reconnaissance vocale
- ❌ Multi-langues (yoruba, bariba) avant que le fon soit irréprochable

**Le vrai risque du projet n'est pas de manquer de fonctionnalités : c'est de ne pas finir.**
