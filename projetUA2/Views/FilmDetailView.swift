//
//  FilmDetailView.swift
//  projetUA2
//
//  Vue de détail affichée lorsqu'on tape sur un film dans la liste.
//  Met en pratique plusieurs gestes (double tap pour agrandir l'affiche,
//  tap pour noter avec des étoiles) et une animation .spring().
//

import SwiftUI

struct FilmDetailView: View {

    @Environment(FilmStore.self) private var store

    // L'ID du film — on relit toujours depuis le store pour rester à jour
    // si l'utilisateur modifie le film via un menu contextuel ailleurs.
    let film: Film

    // État local pour agrandir l'affiche au double tap.
    @State private var afficheAgrandie = false

    // Petite animation d'apparition de la vue.
    @State private var estApparu = false

    // Retrouve le film à jour depuis le store à chaque re-composition.
    // Si le film a été supprimé, on utilise la version passée en paramètre.
    private var filmActuel: Film {
        store.films.first(where: { $0.id == film.id }) ?? film
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: Affiche cliquable

                // L'affiche est un SF Symbol coloré. Un double tap la fait grossir.
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(filmActuel.genre.couleur.gradient)

                    Image(systemName: filmActuel.affiche)
                        .font(.system(size: afficheAgrandie ? 140 : 90))
                        .foregroundStyle(.white)
                        // Animation "spring" — donne un effet de rebond naturel au grossissement.
                        .animation(.spring(response: 0.5, dampingFraction: 0.6),
                                   value: afficheAgrandie)
                }
                .frame(height: afficheAgrandie ? 320 : 220)
                .padding(.horizontal)
                // Geste : double tap pour agrandir/réduire l'affiche.
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        afficheAgrandie.toggle()
                    }
                }
                // Indice visuel pour l'utilisateur : petit texte sous l'affiche.
                .overlay(alignment: .bottomTrailing) {
                    Label("Double tap", systemImage: "hand.tap")
                        .font(.caption2)
                        .padding(6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(10)
                }

                // MARK: Informations principales

                VStack(alignment: .leading, spacing: 12) {
                    Text(filmActuel.titre)
                        .font(.largeTitle.bold())

                    // Ligne d'informations secondaires (réalisateur + année).
                    HStack {
                        Label(filmActuel.realisateur, systemImage: "person.fill")
                        Spacer()
                        Label(String(filmActuel.annee), systemImage: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    // Badges (statut + genre) en ligne.
                    HStack(spacing: 8) {
                        Label(filmActuel.statut.rawValue, systemImage: filmActuel.statut.icone)
                            .badgeStyle(couleur: filmActuel.statut.couleur)

                        Label(filmActuel.genre.rawValue, systemImage: "tag.fill")
                            .badgeStyle(couleur: filmActuel.genre.couleur)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Système de notation par étoiles

                VStack(alignment: .leading, spacing: 8) {
                    Text("Votre note")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= filmActuel.note ? "star.fill" : "star")
                                .font(.title)
                                .foregroundStyle(.yellow)
                                // Geste : tap sur une étoile pour donner cette note.
                                // Tap sur la même étoile deux fois = remise à 0.
                                .onTapGesture {
                                    withAnimation(.spring) {
                                        let nouvelleNote = (filmActuel.note == index) ? 0 : index
                                        store.noter(filmActuel, note: nouvelleNote)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Synopsis

                if !filmActuel.synopsis.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synopsis")
                            .font(.headline)
                        Text(filmActuel.synopsis)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // MARK: Actions rapides

                actionsRapides
                    .padding(.horizontal)
            }
            .padding(.vertical)
            // Animation d'entrée : la vue "apparaît" en glissant + fondu.
            .opacity(estApparu ? 1 : 0)
            .offset(y: estApparu ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    estApparu = true
                }
            }
        }
        .navigationTitle(filmActuel.titre)
        .navigationBarTitleDisplayMode(.inline)
        // Barre d'outils : bouton favori (cœur) en haut à droite.
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring) {
                        store.basculerFavori(filmActuel)
                    }
                } label: {
                    Image(systemName: filmActuel.favori ? "heart.fill" : "heart")
                        .foregroundStyle(filmActuel.favori ? .red : .primary)
                }
            }
        }
    }

    // MARK: - Grille d'actions rapides

    // Boutons rapides pour changer le statut du film sans passer par le menu contextuel.
    private var actionsRapides: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Marquer comme")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(StatutFilm.allCases) { statut in
                    Button {
                        withAnimation {
                            store.changerStatut(filmActuel, vers: statut)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: statut.icone)
                                .font(.title3)
                            Text(statut.rawValue)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            filmActuel.statut == statut
                                ? statut.couleur.opacity(0.2)
                                : Color.gray.opacity(0.1)
                        )
                        .foregroundStyle(
                            filmActuel.statut == statut ? statut.couleur : .primary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Style de badge réutilisable
// Petit modificateur pour uniformiser les badges (statut, genre) dans l'app.
private extension View {
    func badgeStyle(couleur: Color) -> some View {
        self
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(couleur.opacity(0.15))
            .foregroundStyle(couleur)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        FilmDetailView(film: Film(titre: "Inception",
                                  realisateur: "Christopher Nolan",
                                  annee: 2010,
                                  genre: .sf,
                                  statut: .vu,
                                  note: 5,
                                  favori: true,
                                  synopsis: "Un voleur qui s'introduit dans les rêves.",
                                  affiche: "brain.head.profile"))
    }
    .environment(FilmStore())
}
