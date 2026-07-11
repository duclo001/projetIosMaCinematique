//
//  FavoritesView.swift
//  projetUA2
//
//  Deuxième onglet du TabView. Affiche uniquement les films marqués comme
//  favoris. Utilise NavigationStack et navigue vers FilmDetailView.
//

import SwiftUI

struct FavoritesView: View {

    @Environment(FilmStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if store.favoris.isEmpty {
                    // État vide — invite l'utilisateur à ajouter des favoris.
                    ContentUnavailableView(
                        "Aucun favori",
                        systemImage: "heart.slash",
                        description: Text("Ajoutez des favoris en appuyant sur le cœur d'un film ou via son menu contextuel.")
                    )
                } else {
                    List {
                        ForEach(store.favoris) { film in
                            NavigationLink(value: film) {
                                FilmRowView(film: film)
                            }
                            // Le swipe permet de retirer le film des favoris.
                            .swipeActions(edge: .trailing) {
                                Button {
                                    withAnimation {
                                        store.basculerFavori(film)
                                    }
                                } label: {
                                    Label("Retirer", systemImage: "heart.slash")
                                }
                                .tint(.pink)
                            }
                            // Menu contextuel simplifié : basculer favori + supprimer.
                            .contextMenu {
                                Button {
                                    store.basculerFavori(film)
                                } label: {
                                    Label("Retirer des favoris", systemImage: "heart.slash")
                                }

                                Button(role: .destructive) {
                                    withAnimation {
                                        store.supprimer(film)
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mes favoris")
            .navigationDestination(for: Film.self) { film in
                FilmDetailView(film: film)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environment(FilmStore())
}
