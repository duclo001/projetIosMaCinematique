//
//  FilmsListView.swift
//  projetUA2
//
//  Vue principale de l'application. Affiche la liste des films regroupés
//  par statut (À voir / En cours / Vu) dans un NavigationStack.
//  Concentre l'essentiel des gestes : swipe pour supprimer, contextMenu
//  au long press, et drag & drop pour réorganiser via EditButton.
//

import SwiftUI

struct FilmsListView: View {

    // Récupération du store partagé depuis l'environnement (injecté dans projetUA2App).
    @Environment(FilmStore.self) private var store

    // Contrôle l'affichage de la feuille modale d'ajout.
    @State private var afficherAjout = false

    var body: some View {
        // @Bindable permet d'utiliser $store.propriete pour créer des liaisons
        // à deux sens avec les propriétés d'une classe @Observable.
        @Bindable var storeLie = store

        NavigationStack {
            List {
                // Une section par statut : structure claire et pédagogique.
                ForEach(StatutFilm.allCases) { statut in
                    let filmsDuStatut = store.filmsParStatut(statut)

                    // On n'affiche la section que si elle contient au moins un film,
                    // pour éviter les sections vides visuellement inutiles.
                    if !filmsDuStatut.isEmpty {
                        Section {
                            ForEach(filmsDuStatut) { film in
                                NavigationLink(value: film) {
                                    FilmRowView(film: film)
                                }
                                // Menu contextuel : apparaît lors d'un appui long sur la ligne.
                                // Regroupe les actions courantes (changer statut, favori, supprimer).
                                .contextMenu {
                                    menuContextuel(pour: film)
                                }
                                // Actions de swipe (glissement) sur la gauche : marquer comme vu.
                                .swipeActions(edge: .leading) {
                                    Button {
                                        store.changerStatut(film, vers: .vu)
                                    } label: {
                                        Label("Vu", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                                // Actions de swipe sur la droite : favori + supprimer.
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            store.supprimer(film)
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }

                                    Button {
                                        store.basculerFavori(film)
                                    } label: {
                                        Label("Favori", systemImage: "heart")
                                    }
                                    .tint(.pink)
                                }
                            }
                        } header: {
                            // En-tête de section : icône + libellé du statut + compteur.
                            HStack {
                                Label(statut.rawValue, systemImage: statut.icone)
                                    .foregroundStyle(statut.couleur)
                                Spacer()
                                Text("\(filmsDuStatut.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ma Cinémathèque")
            // Barre de recherche native — se branche directement sur le store.
            .searchable(text: $storeLie.texteRecherche, prompt: "Rechercher un titre ou un réalisateur")
            // Destination de navigation type-safe : lorsqu'on tape sur un lien
            // contenant un Film, SwiftUI ouvre FilmDetailView.
            .navigationDestination(for: Film.self) { film in
                FilmDetailView(film: film)
            }
            // Barre d'outils : à gauche un menu de filtre par genre, à droite un bouton d'ajout.
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    menuFiltre
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        afficherAjout = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            // Feuille modale d'ajout d'un nouveau film.
            .sheet(isPresented: $afficherAjout) {
                AddFilmView()
            }
            // État vide amical si la liste filtrée ne renvoie rien.
            .overlay {
                if store.filmsFiltres.isEmpty {
                    ContentUnavailableView("Aucun film",
                        systemImage: "film.stack",
                        description: Text("Ajoutez votre premier film avec le bouton + en haut à droite."))
                }
            }
        }
    }

    // MARK: - Menu contextuel réutilisable

    // Construit le menu contextuel pour un film donné.
    // Extrait en fonction pour rester lisible dans le body principal.
    @ViewBuilder
    private func menuContextuel(pour film: Film) -> some View {
        // Sous-menu pour changer rapidement le statut.
        Menu("Changer le statut", systemImage: "arrow.triangle.2.circlepath") {
            ForEach(StatutFilm.allCases) { statut in
                Button {
                    store.changerStatut(film, vers: statut)
                } label: {
                    Label(statut.rawValue, systemImage: statut.icone)
                }
            }
        }

        Button {
            store.basculerFavori(film)
        } label: {
            Label(film.favori ? "Retirer des favoris" : "Ajouter aux favoris",
                  systemImage: film.favori ? "heart.slash" : "heart")
        }

        // Section séparée pour l'action destructive — bonne pratique iOS.
        Section {
            Button(role: .destructive) {
                withAnimation {
                    store.supprimer(film)
                }
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }

    // MARK: - Menu de filtre par genre

    // Menu déroulant dans la barre d'outils pour filtrer les films par genre.
    private var menuFiltre: some View {
        Menu {
            Button {
                store.filtreGenre = nil
            } label: {
                Label("Tous les genres", systemImage: "square.stack")
            }

            Divider()

            ForEach(GenreFilm.allCases) { genre in
                Button {
                    store.filtreGenre = genre
                } label: {
                    Label(genre.rawValue, systemImage: "circle.fill")
                        .foregroundStyle(genre.couleur)
                }
            }
        } label: {
            // L'icône change selon qu'un filtre est actif ou non.
            Image(systemName: store.filtreGenre == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
                .font(.title3)
        }
    }
}

#Preview {
    FilmsListView()
        .environment(FilmStore())
}
