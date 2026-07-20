# Ma Cinémathèque

Projet iOS fait dans le cadre du cours IFM025921 (Développement d'applications mobiles).

C'est une petite app SwiftUI pour gérer sa collection de films : on peut en ajouter, les noter, les mettre en favoris et voir quelques stats.

## Ce que l'app fait

- Une liste de films rangés en 3 sections : À voir / En cours / Vu
- On tape sur un film pour ouvrir sa fiche détaillée
- On peut ajouter un nouveau film avec un formulaire
- Noter les films de 1 à 5 étoiles
- Mettre en favoris avec un cœur
- Rechercher par titre ou par réalisateur
- Filtrer par genre
- Un onglet Stats avec un camembert (les genres) et la note moyenne

## Organisation du code

Le projet est séparé en 3 dossiers :

- `Models/` – la struct `Film` et les enums (`StatutFilm`, `GenreFilm`)
- `Store/` – la classe `FilmStore` qui gère toutes les données (ajout, suppression, favoris, notation, filtres)
- `Views/` – toutes les vues SwiftUI

J'ai fait un composant `FilmRowView` que je réutilise dans la liste principale et dans les favoris pour pas dupliquer le code.

## Les gestes qu'on peut faire

- **Swipe vers la gauche** sur un film → le marquer comme vu
- **Swipe vers la droite** → supprimer ou mettre en favori
- **Appui long** sur un film → menu contextuel avec toutes les actions
- **Double tap** sur l'affiche dans la vue détail → elle grossit
- **Tap sur les étoiles** → donner une note (retap = remettre à 0)

## Ce qui vient des modules du cours

- Module 5 : `List` avec sections, `NavigationStack`, `NavigationLink(value:)`, `Form`, `.swipeActions`, `.toolbar`
- Module 6 : `TabView`, `@Observable` (macro iOS 17), `@Environment` pour partager le store, `.onAppear` / `.onDisappear`
- Module 9 : `.contextMenu`, animations `.spring()`, gestes tap et double tap, dessin 2D avec `Shape` et `Path` pour le camembert

## Pour lancer

1. Ouvrir `projetUA2.xcodeproj` dans Xcode
2. Choisir un simulateur (iPhone 15 par exemple)
3. Cmd + R

Il faut Xcode 15 et iOS 17 minimum à cause du macro `@Observable`.
