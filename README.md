# Ma Cinémathèque — Projet iOS SwiftUI

Application iOS développée avec SwiftUI dans le cadre du cours **IFM025921 — Développement d'applications mobiles pour iOS**.

L'application permet de gérer une collection personnelle de films : ajouter, classer, noter, marquer en favoris et consulter des statistiques.

---

## Table des matières

1. [Présentation](#1-présentation)
2. [Exigences du projet](#2-exigences-du-projet)
3. [Choix du thème](#3-choix-du-thème)
4. [Architecture du projet](#4-architecture-du-projet)
5. [Étapes de réalisation](#5-étapes-de-réalisation)
6. [Fonctionnalités](#6-fonctionnalités)
7. [Correspondance avec les modules du cours](#7-correspondance-avec-les-modules-du-cours)
8. [Comment tester l'application](#8-comment-tester-lapplication)
9. [Structure des fichiers](#9-structure-des-fichiers)

---

## 1. Présentation

**Ma Cinémathèque** est une application iOS qui simule un "carnet de films" personnel. L'utilisateur peut :

- consulter sa liste de films regroupés par statut (À voir / En cours / Vu) ;
- ouvrir la fiche détaillée d'un film ;
- ajouter de nouveaux films via un formulaire ;
- marquer des films en favoris ;
- attribuer une note de 1 à 5 étoiles ;
- filtrer par genre et faire une recherche par titre ou réalisateur ;
- visualiser des statistiques (nombre total, répartition par genre, note moyenne).

L'application est développée entièrement en **SwiftUI** avec le nouveau macro `@Observable` d'iOS 17 et met en pratique tous les modules du cours (menus contextuels, gestes, animations, dessin 2D, listes, navigation, cycle de vie, objets observables).

---

## 2. Exigences du projet

Les exigences techniques obligatoires du projet sont respectées :

| Exigence | Emplacement dans le code |
|----------|--------------------------|
| Liste d'éléments d'une source de données | `FilmStore.swift` (source) + `FilmsListView.swift` (affichage) |
| Navigation vers une vue de détails | `FilmsListView` → `FilmDetailView` via `NavigationLink(value:)` |
| Reconnaissance de gestes personnalisés | swipe, long press, double tap, tap simple — voir plus bas |
| Menus contextuels avec actions utiles | `.contextMenu` dans `FilmsListView` et `FavoritesView` |
| Interface claire et fluide en SwiftUI | Cartes arrondies, dégradés, animations `.spring()` |
| Code structuré (séparation vues/données) | Dossiers `Models/`, `Store/`, `Views/` |
| Commentaires clairs | Commentaires en français dans chaque fichier |

---

## 3. Choix du thème

Parmi les idées suggérées dans l'énoncé (films, recettes, tâches, œuvres, livres, lieux…), le thème **cinémathèque personnelle** a été retenu pour plusieurs raisons :

- **Richesse des données** : un film a plusieurs propriétés naturelles (titre, réalisateur, année, genre, note, statut, synopsis), ce qui donne du contenu à afficher dans la vue de détail.
- **Bon terrain pour les gestes** : le domaine se prête bien à toutes les interactions demandées :
  - swipe pour supprimer ou marquer comme vu
  - long press pour ouvrir un menu contextuel
  - double tap pour agrandir une affiche
  - tap pour attribuer une note
- **Aspect visuel** : les couleurs par genre et les symboles SF permettent de créer une interface colorée sans avoir à gérer d'images.
- **Statistiques naturelles** : la répartition par genre justifie un diagramme circulaire (dessin 2D custom du Module 9).

---

## 4. Architecture du projet

Le projet suit une architecture simple mais claire, avec **séparation des responsabilités** entre le modèle, les données et les vues.

```
projetUA2/
├── projetUA2App.swift        → Point d'entrée + injection du store
├── ContentView.swift         → TabView racine (Films / Favoris / Stats)
│
├── Models/
│   └── Film.swift            → Struct Film + enums StatutFilm et GenreFilm
│
├── Store/
│   └── FilmStore.swift       → Classe @Observable qui gère toutes les données
│
└── Views/
    ├── FilmRowView.swift     → Composant réutilisable (ligne de film)
    ├── FilmsListView.swift   → Liste principale avec sections et gestes
    ├── FilmDetailView.swift  → Vue détaillée d'un film
    ├── AddFilmView.swift     → Formulaire d'ajout
    ├── FavoritesView.swift   → Onglet des favoris
    └── StatsView.swift       → Statistiques et diagramme circulaire
```

### Principes suivis

- **Un seul store partagé** (`FilmStore`) injecté via `@Environment` — évite de passer les données de vue en vue manuellement.
- **Composants réutilisables** : `FilmRowView` est utilisée à la fois dans la liste principale et dans les favoris, ce qui garantit une apparence cohérente.
- **Séparation vues / données** : les vues ne stockent pas de données — elles lisent depuis le store et appellent ses méthodes pour modifier.
- **Types Swift stricts** : `StatutFilm` et `GenreFilm` sont des enums pour éviter les fautes de frappe et bénéficier de l'auto-complétion.

---

## 5. Étapes de réalisation

Le projet a été réalisé selon les étapes suivantes.

### Étape 1 — Lecture de l'énoncé et choix du thème

Lecture attentive de la fiche du projet pour repérer les exigences obligatoires (liste, navigation, gestes, menu contextuel) et les critères d'évaluation. Le thème "cinémathèque" a été choisi car il permet de couvrir naturellement tous les critères.

### Étape 2 — Conception du modèle de données

Création d'un modèle `Film` en tant que `struct` conforme à `Identifiable`, `Hashable` et `Codable`. Ajout de deux enums (`StatutFilm`, `GenreFilm`) pour représenter les catégories de manière type-safe. Chaque enum expose une couleur et une icône associées, ce qui simplifie l'affichage dans les vues.

### Étape 3 — Création du store observable

Écriture de la classe `FilmStore` marquée `@Observable` (macro iOS 17). Cette classe centralise :

- la collection de films ;
- l'état des filtres (genre, texte de recherche) ;
- toutes les opérations CRUD (ajouter, supprimer, modifier, changer statut, basculer favori, noter).

Des vues calculées (`filmsFiltres`, `filmsParStatut`, `favoris`, `repartitionParGenre`) fournissent les données déjà triées aux vues, ce qui garde le code des vues simple.

Ajout de 8 films par défaut au démarrage pour que l'application ne soit jamais vide au premier lancement.

### Étape 4 — Point d'entrée de l'application

Modification de `projetUA2App.swift` pour instancier le `FilmStore` une seule fois et l'injecter dans l'environnement SwiftUI via `.environment(store)`. Toutes les vues peuvent ensuite le récupérer avec `@Environment(FilmStore.self)`.

### Étape 5 — Vue racine et navigation par onglets

Réécriture de `ContentView.swift` avec un `TabView` à trois onglets : **Films**, **Favoris**, **Statistiques**. Chaque onglet contient sa propre `NavigationStack` pour permettre une navigation indépendante entre les onglets.

### Étape 6 — Composant réutilisable de ligne

Création de `FilmRowView` qui présente une ligne de film cohérente : "affiche" (SF Symbol coloré avec dégradé), titre, réalisateur, année, badge de statut, étoiles de note, et cœur si favori. Ce composant est utilisé dans la liste principale et dans les favoris.

### Étape 7 — Liste principale avec sections et gestes

Écriture de `FilmsListView`, la vue la plus riche du projet. Elle contient :

- une `List` avec une `Section` par statut (avec en-tête personnalisé et compteur) ;
- un `NavigationLink(value: film)` sur chaque ligne ;
- un `.contextMenu` sur chaque ligne (long press) avec sous-menu pour changer le statut, action favori et action supprimer ;
- des `.swipeActions` sur les deux côtés (swipe gauche = marquer vu, swipe droit = favori + supprimer) ;
- une `.searchable` connectée au store ;
- un menu de filtre par genre dans la `.toolbar` ;
- un bouton `+` qui ouvre `AddFilmView` en `.sheet` ;
- un état vide (`ContentUnavailableView`) affiché quand la liste filtrée est vide.

### Étape 8 — Vue de détail avec gestes personnalisés

Écriture de `FilmDetailView` qui affiche toutes les informations d'un film. Points d'intérêt :

- **Double tap sur l'affiche** → agrandit avec animation `.spring()` ;
- **Tap sur les étoiles** → attribue la note (0 à 5) ; taper sur une étoile déjà sélectionnée remet la note à 0 ;
- **Boutons rapides de statut** pour changer À voir / En cours / Vu sans passer par le menu contextuel ;
- **Bouton favori** (cœur) dans la barre d'outils ;
- **Animation d'entrée** avec `onAppear` : la vue apparaît en fondu avec un léger décalage.

Comme le film est passé en paramètre (valeur), une propriété calculée `filmActuel` va rechercher la version à jour dans le store à chaque re-composition — ainsi les modifications faites via le menu contextuel restent synchronisées.

### Étape 9 — Formulaire d'ajout

Création de `AddFilmView`, une feuille modale présentant un `Form` avec quatre sections :

1. Informations (titre, réalisateur, année avec `Stepper`) ;
2. Classification (`Picker` pour le genre et le statut) ;
3. Affiche (aperçu + grille de 16 SF Symbols à sélectionner) ;
4. Synopsis (`TextEditor`).

Le bouton "Ajouter" est désactivé tant que les champs obligatoires (titre, réalisateur) ne sont pas remplis. Utilisation de `@Environment(\.dismiss)` pour fermer la feuille après ajout.

### Étape 10 — Vue des favoris

`FavoritesView` reprend le composant `FilmRowView` mais filtre pour n'afficher que `store.favoris`. Elle propose un swipe et un menu contextuel simplifiés (retirer des favoris, supprimer). Un état vide invite l'utilisateur à ajouter des favoris quand la liste est vide.

### Étape 11 — Vue statistiques avec dessin 2D custom

`StatsView` combine plusieurs composants :

- **Cartes de résumé** en haut (Total, Vus, Favoris) ;
- **Diagramme circulaire (camembert)** dessiné à la main avec le protocole `Shape` et `Path.addArc()` — chaque secteur est un `SecteurShape` proportionnel au nombre de films dans le genre ;
- **Animation d'entrée** : le camembert se remplit progressivement à l'apparition de la vue (utilisation de `onAppear` + `.easeOut`) ;
- **Cercle central blanc** superposé pour créer un effet "donut" avec le total des films au centre ;
- **Légende** à droite avec pastilles de couleur ;
- **Carte "Note moyenne"** avec étoiles proportionnelles (étoile pleine, demi-étoile, ou vide).

### Étape 12 — Vérification et build

Compilation du projet avec `BuildProject`. Correction d'un problème de placement des fichiers dans le navigateur Xcode (les fichiers avaient été créés au mauvais niveau et n'étaient pas inclus dans la cible). Une fois les fichiers correctement placés sous `projetUA2/projetUA2/`, la compilation passe sans erreur.

### Étape 13 — Dépôt sur GitHub

Nettoyage de l'état git, création d'un commit propre et push sur le dépôt distant.

---

## 6. Fonctionnalités

### Fonctionnalités demandées

- **Liste dynamique** avec sections par statut, compteurs et en-têtes stylisés.
- **Navigation** vers la vue de détail via `NavigationStack` + `NavigationLink(value:)`.
- **Gestes personnalisés** :
  - swipe droit → favori et suppression ;
  - swipe gauche → marquer comme vu ;
  - long press → menu contextuel ;
  - double tap sur l'affiche → agrandir ;
  - tap sur les étoiles → attribuer une note.
- **Menu contextuel** avec sous-menu de statut, action favori et suppression.

### Fonctionnalités bonus (créativité)

- **Diagramme circulaire dessiné à la main** avec `Path` et `Shape`.
- **Système de notation par étoiles** interactif (5 étoiles cliquables).
- **Filtre par genre** avec menu dans la barre d'outils.
- **Barre de recherche** intégrée (`.searchable`).
- **Grille de SF Symbols** à choisir comme "affiche" lors de l'ajout.
- **Animations fluides** : `.spring()` sur les interactions, animation d'entrée sur la vue de détail, remplissage progressif du camembert.
- **Interface visuellement riche** : dégradés de couleur par genre, badges arrondis, cartes ombrées.
- **États vides amicaux** avec `ContentUnavailableView`.

---

## 7. Correspondance avec les modules du cours

L'application met en pratique le contenu des modules suivants :

### Module 5 — Listes et navigation
- `List` avec `Section` et en-têtes personnalisés ;
- Structures conformes à `Identifiable` ;
- `NavigationStack` + `NavigationLink(value:)` + `.navigationDestination(for:)` ;
- `.toolbar` avec `ToolbarItem` ;
- `Form` avec `Section`, `Picker`, `TextField`, `Stepper`, `TextEditor` ;
- `.swipeActions` (variante moderne de `.onDelete`).

### Module 6 — Cycle de vie et objets observables
- `TabView` avec `.tabItem` ;
- `@Observable` sur la classe `FilmStore` (macro iOS 17) ;
- `.environment(store)` pour injecter dans l'arbre de vues ;
- `@Environment(FilmStore.self)` pour lire dans les vues ;
- `@Bindable` pour créer des liaisons vers les propriétés du store ;
- `.onAppear` et `.onDisappear` pour déclencher les animations.

### Module 9 — Menus contextuels, dessin, animations, gestes
- `.contextMenu` avec `Section`, `Menu`, boutons destructifs ;
- **Dessin 2D custom** : protocole `Shape`, `Path`, `addArc`, forme personnalisée `SecteurShape` ;
- Formes prédéfinies : `RoundedRectangle`, `Circle`, `Capsule` ;
- Dégradés : `.fill(couleur.gradient)` ;
- Animations implicites `.animation(_, value:)` et explicites `withAnimation { }` ;
- Animation `.spring()` avec `response` et `dampingFraction` ;
- Gestes : `.onTapGesture`, `.onTapGesture(count: 2)` (double tap).

---

## 8. Comment tester l'application

### Prérequis

- Xcode 15 ou plus récent ;
- iOS 17 ou plus récent (requis pour `@Observable` et `ContentUnavailableView`).

### Lancement

1. Ouvrir `projetUA2.xcodeproj` dans Xcode.
2. Sélectionner un simulateur (iPhone 15, par exemple) ou un appareil réel.
3. Appuyer sur **⌘ + R** pour lancer.

### Scénario de démonstration recommandé

1. **Onglet Films** : parcourir la liste, remarquer les sections par statut, les badges de couleur, les cœurs sur les favoris.
2. **Recherche** : taper "Nolan" dans la barre de recherche → seuls les films de Christopher Nolan restent.
3. **Filtre** : ouvrir le menu de filtre (icône entonnoir en haut à gauche) et choisir "Science-fiction".
4. **Swipe** : glisser un film vers la gauche pour voir apparaître les actions "Vu".
5. **Swipe** : glisser vers la droite pour voir "Favori" et "Supprimer".
6. **Long press** sur un film : le menu contextuel apparaît avec sous-menu de statut.
7. **Tap** sur un film : ouvre la vue de détail avec animation.
8. **Double tap** sur l'affiche : elle grossit avec effet spring.
9. **Tap sur les étoiles** : attribue une note ; retaper sur la même étoile remet à 0.
10. **Bouton +** en haut à droite : ouvre le formulaire d'ajout.
11. **Onglet Favoris** : voir uniquement les films marqués comme favoris.
12. **Onglet Statistiques** : voir le diagramme circulaire s'animer, la note moyenne et les compteurs.

---

## 9. Structure des fichiers

```
projetUA2/
├── README.md                            → Ce fichier
├── projetUA2.xcodeproj/                 → Projet Xcode
└── projetUA2/
    ├── projetUA2App.swift               → @main de l'application
    ├── ContentView.swift                → TabView racine
    ├── Assets.xcassets                  → Ressources graphiques (icônes système)
    │
    ├── Models/
    │   └── Film.swift                   → Modèle Film + enums StatutFilm et GenreFilm
    │
    ├── Store/
    │   └── FilmStore.swift              → Store @Observable (données et opérations)
    │
    └── Views/
        ├── FilmRowView.swift            → Composant "ligne de film" réutilisable
        ├── FilmsListView.swift          → Vue liste principale avec gestes
        ├── FilmDetailView.swift         → Vue détail avec notation et double tap
        ├── AddFilmView.swift            → Formulaire modal d'ajout
        ├── FavoritesView.swift          → Liste filtrée sur les favoris
        └── StatsView.swift              → Statistiques + diagramme circulaire custom
```

---

## Auteur

Projet réalisé par **duclo001** dans le cadre du cours IFM025921.
