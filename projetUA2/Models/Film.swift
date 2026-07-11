//
//  Film.swift
//  projetUA2
//
//  Modèle de données représentant un film dans la cinémathèque.
//

import Foundation
import SwiftUI

// MARK: - Statut de visionnement
// Représente les trois états possibles d'un film dans la collection de l'utilisateur.
enum StatutFilm: String, CaseIterable, Codable, Identifiable {
    case aVoir     = "À voir"
    case enCours   = "En cours"
    case vu        = "Vu"

    var id: String { rawValue }

    // Icône SF Symbol associée à chaque statut (utilisée dans les listes et menus).
    var icone: String {
        switch self {
        case .aVoir:   return "bookmark"
        case .enCours: return "play.circle"
        case .vu:      return "checkmark.circle.fill"
        }
    }

    // Couleur d'accent associée au statut (utilisée pour les badges).
    var couleur: Color {
        switch self {
        case .aVoir:   return .orange
        case .enCours: return .blue
        case .vu:      return .green
        }
    }
}

// MARK: - Genre cinématographique
// Chaque genre a une couleur associée pour l'affichage dans l'UI (graphique de stats, badges…).
enum GenreFilm: String, CaseIterable, Codable, Identifiable {
    case action      = "Action"
    case comedie     = "Comédie"
    case drame       = "Drame"
    case sf          = "Science-fiction"
    case horreur     = "Horreur"
    case animation   = "Animation"
    case documentaire = "Documentaire"
    case romance     = "Romance"

    var id: String { rawValue }

    // Couleur associée au genre — sert notamment au diagramme circulaire dans StatsView.
    var couleur: Color {
        switch self {
        case .action:       return .red
        case .comedie:      return .yellow
        case .drame:        return .purple
        case .sf:           return .cyan
        case .horreur:      return .black
        case .animation:    return .pink
        case .documentaire: return .brown
        case .romance:      return .mint
        }
    }
}

// MARK: - Modèle Film
// Un film est identifié de façon unique par un UUID pour pouvoir être utilisé
// dans un ForEach et dans les listes SwiftUI (protocole Identifiable).
struct Film: Identifiable, Hashable, Codable {
    let id: UUID
    var titre: String
    var realisateur: String
    var annee: Int
    var genre: GenreFilm
    var statut: StatutFilm
    var note: Int          // Note sur 5 étoiles (0 = pas encore noté)
    var favori: Bool
    var synopsis: String
    // Nom d'un SF Symbol utilisé comme "affiche" — évite de gérer des images bitmap.
    var affiche: String

    init(id: UUID = UUID(),
         titre: String,
         realisateur: String,
         annee: Int,
         genre: GenreFilm,
         statut: StatutFilm = .aVoir,
         note: Int = 0,
         favori: Bool = false,
         synopsis: String = "",
         affiche: String = "film") {
        self.id = id
        self.titre = titre
        self.realisateur = realisateur
        self.annee = annee
        self.genre = genre
        self.statut = statut
        self.note = note
        self.favori = favori
        self.synopsis = synopsis
        self.affiche = affiche
    }
}
