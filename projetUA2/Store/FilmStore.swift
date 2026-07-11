//
//  FilmStore.swift
//  projetUA2
//
//  Store observable qui centralise toutes les données de l'application.
//  Utilise le macro @Observable (iOS 17+) pour la synchronisation automatique
//  avec les vues SwiftUI. Ce store est injecté dans l'environnement à la racine
//  de l'app et récupéré dans les vues via @Environment(FilmStore.self).
//

import Foundation
import SwiftUI

@Observable
final class FilmStore {

    // Liste principale des films. Les vues qui la lisent se re-dessinent
    // automatiquement lorsqu'elle change (ajout, suppression, modification).
    var films: [Film]

    // Filtre de genre appliqué à la liste principale (nil = tous les genres).
    var filtreGenre: GenreFilm? = nil

    // Texte de recherche saisi par l'utilisateur (filtre par titre ou réalisateur).
    var texteRecherche: String = ""

    init(films: [Film] = FilmStore.filmsParDefaut()) {
        self.films = films
    }

    // MARK: - Opérations CRUD

    // Ajoute un nouveau film à la collection.
    func ajouter(_ film: Film) {
        films.append(film)
    }

    // Supprime les films aux positions indiquées (utilisé par .onDelete).
    func supprimer(aux offsets: IndexSet) {
        films.remove(atOffsets: offsets)
    }

    // Supprime un film précis par son identifiant.
    func supprimer(_ film: Film) {
        films.removeAll { $0.id == film.id }
    }

    // Déplace les films dans la liste (utilisé par .onMove pour le drag & drop).
    func deplacer(de source: IndexSet, vers destination: Int) {
        films.move(fromOffsets: source, toOffset: destination)
    }

    // Bascule l'état favori d'un film.
    func basculerFavori(_ film: Film) {
        if let index = films.firstIndex(where: { $0.id == film.id }) {
            films[index].favori.toggle()
        }
    }

    // Change le statut d'un film (À voir / En cours / Vu).
    func changerStatut(_ film: Film, vers nouveauStatut: StatutFilm) {
        if let index = films.firstIndex(where: { $0.id == film.id }) {
            films[index].statut = nouveauStatut
        }
    }

    // Attribue une note (0 à 5) à un film.
    func noter(_ film: Film, note: Int) {
        if let index = films.firstIndex(where: { $0.id == film.id }) {
            films[index].note = max(0, min(5, note))
        }
    }

    // MARK: - Vues calculées (filtres et regroupements)

    // Renvoie les films filtrés par genre et par texte de recherche.
    var filmsFiltres: [Film] {
        films.filter { film in
            let correspondGenre = filtreGenre == nil || film.genre == filtreGenre
            let correspondTexte = texteRecherche.isEmpty
                || film.titre.localizedCaseInsensitiveContains(texteRecherche)
                || film.realisateur.localizedCaseInsensitiveContains(texteRecherche)
            return correspondGenre && correspondTexte
        }
    }

    // Regroupe les films filtrés par statut — utilisé par les sections de FilmsListView.
    func filmsParStatut(_ statut: StatutFilm) -> [Film] {
        filmsFiltres.filter { $0.statut == statut }
    }

    // Liste des films favoris (utilisée par FavoritesView).
    var favoris: [Film] {
        films.filter { $0.favori }
    }

    // Compte les films par genre — sert au diagramme circulaire de StatsView.
    var repartitionParGenre: [(genre: GenreFilm, nombre: Int)] {
        GenreFilm.allCases
            .map { genre in
                (genre: genre, nombre: films.filter { $0.genre == genre }.count)
            }
            .filter { $0.nombre > 0 }
    }

    // MARK: - Données de démarrage
    // Films par défaut chargés au premier lancement pour que l'app ne soit pas vide.
    private static func filmsParDefaut() -> [Film] {
        [
            Film(titre: "Inception",
                 realisateur: "Christopher Nolan",
                 annee: 2010,
                 genre: .sf,
                 statut: .vu,
                 note: 5,
                 favori: true,
                 synopsis: "Un voleur qui s'introduit dans les rêves des autres pour dérober leurs secrets.",
                 affiche: "brain.head.profile"),
            Film(titre: "Parasite",
                 realisateur: "Bong Joon-ho",
                 annee: 2019,
                 genre: .drame,
                 statut: .vu,
                 note: 5,
                 favori: true,
                 synopsis: "Une famille pauvre s'infiltre dans la vie d'une famille riche.",
                 affiche: "house.fill"),
            Film(titre: "Dune : Deuxième partie",
                 realisateur: "Denis Villeneuve",
                 annee: 2024,
                 genre: .sf,
                 statut: .aVoir,
                 note: 0,
                 favori: false,
                 synopsis: "Paul Atréides s'unit avec les Fremen pour venger sa famille.",
                 affiche: "sun.max.fill"),
            Film(titre: "Le Fabuleux Destin d'Amélie Poulain",
                 realisateur: "Jean-Pierre Jeunet",
                 annee: 2001,
                 genre: .romance,
                 statut: .vu,
                 note: 4,
                 favori: false,
                 synopsis: "Une jeune femme parisienne décide d'aider les autres à trouver le bonheur.",
                 affiche: "heart.fill"),
            Film(titre: "Interstellar",
                 realisateur: "Christopher Nolan",
                 annee: 2014,
                 genre: .sf,
                 statut: .enCours,
                 note: 4,
                 favori: false,
                 synopsis: "Un groupe d'explorateurs voyage à travers un trou de ver pour sauver l'humanité.",
                 affiche: "moon.stars.fill"),
            Film(titre: "Spider-Man : Across the Spider-Verse",
                 realisateur: "Joaquim Dos Santos",
                 annee: 2023,
                 genre: .animation,
                 statut: .aVoir,
                 note: 0,
                 favori: true,
                 synopsis: "Miles Morales voyage à travers le multivers et rencontre d'autres Spider-Man.",
                 affiche: "sparkles"),
            Film(titre: "Get Out",
                 realisateur: "Jordan Peele",
                 annee: 2017,
                 genre: .horreur,
                 statut: .vu,
                 note: 4,
                 favori: false,
                 synopsis: "Un jeune homme noir découvre un terrible secret en visitant la famille de sa petite amie.",
                 affiche: "eye.trianglebadge.exclamationmark"),
            Film(titre: "La La Land",
                 realisateur: "Damien Chazelle",
                 annee: 2016,
                 genre: .romance,
                 statut: .aVoir,
                 note: 0,
                 favori: false,
                 synopsis: "Une comédie musicale sur la rencontre entre une actrice et un pianiste de jazz.",
                 affiche: "music.note")
        ]
    }
}
