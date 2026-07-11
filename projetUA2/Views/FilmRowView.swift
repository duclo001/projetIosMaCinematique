//
//  FilmRowView.swift
//  projetUA2
//
//  Composant réutilisable pour afficher une ligne de film dans une liste.
//  Utilisé dans FilmsListView et FavoritesView pour rester cohérent.
//

import SwiftUI

struct FilmRowView: View {
    let film: Film

    var body: some View {
        HStack(spacing: 14) {
            // "Affiche" du film — un SF Symbol coloré dans un carré arrondi.
            // Utilise la couleur du genre pour donner un repère visuel rapide.
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(film.genre.couleur.gradient)
                    .frame(width: 54, height: 54)

                Image(systemName: film.affiche)
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            // Colonne d'informations principales : titre, réalisateur, année.
            VStack(alignment: .leading, spacing: 4) {
                Text(film.titre)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(film.realisateur) • \(String(film.annee))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Ligne de badges : statut + note en étoiles (si notée).
                HStack(spacing: 6) {
                    Label(film.statut.rawValue, systemImage: film.statut.icone)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(film.statut.couleur.opacity(0.15))
                        .foregroundStyle(film.statut.couleur)
                        .clipShape(Capsule())

                    if film.note > 0 {
                        HStack(spacing: 1) {
                            ForEach(0..<film.note, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Cœur affiché si le film est favori.
            if film.favori {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        FilmRowView(film: Film(titre: "Inception",
                               realisateur: "Christopher Nolan",
                               annee: 2010,
                               genre: .sf,
                               statut: .vu,
                               note: 5,
                               favori: true,
                               affiche: "brain.head.profile"))
    }
}
