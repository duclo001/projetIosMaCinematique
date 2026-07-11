//
//  AddFilmView.swift
//  projetUA2
//
//  Formulaire d'ajout d'un nouveau film à la cinémathèque.
//  Utilise Form (Module 5) et se présente dans une feuille modale (.sheet).
//

import SwiftUI

struct AddFilmView: View {

    @Environment(FilmStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    // MARK: - Champs du formulaire (états locaux)

    @State private var titre = ""
    @State private var realisateur = ""
    @State private var annee = Calendar.current.component(.year, from: .now)
    @State private var genre: GenreFilm = .drame
    @State private var statut: StatutFilm = .aVoir
    @State private var synopsis = ""
    @State private var symboleAffiche = "film"

    // Liste de SF Symbols au choix pour représenter le film.
    private let symbolesDisponibles = [
        "film", "star.fill", "heart.fill", "sparkles", "moon.stars.fill",
        "sun.max.fill", "flame.fill", "bolt.fill", "leaf.fill", "cloud.fill",
        "music.note", "gamecontroller.fill", "brain.head.profile", "eye.fill",
        "camera.fill", "theatermasks.fill"
    ]

    // Le bouton "Ajouter" n'est actif que si les champs obligatoires sont remplis.
    private var formulaireValide: Bool {
        !titre.trimmingCharacters(in: .whitespaces).isEmpty
        && !realisateur.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Section — Informations générales
                Section("Informations") {
                    TextField("Titre", text: $titre)
                    TextField("Réalisateur", text: $realisateur)

                    // Stepper pour l'année : évite les erreurs de saisie clavier.
                    Stepper(value: $annee, in: 1900...2100) {
                        HStack {
                            Text("Année")
                            Spacer()
                            Text(String(annee))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: Section — Classification
                Section("Classification") {
                    Picker("Genre", selection: $genre) {
                        ForEach(GenreFilm.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }

                    Picker("Statut", selection: $statut) {
                        ForEach(StatutFilm.allCases) { s in
                            Label(s.rawValue, systemImage: s.icone).tag(s)
                        }
                    }
                }

                // MARK: Section — Choix d'un symbole "affiche"
                Section("Affiche") {
                    // Aperçu de l'affiche sélectionnée.
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(genre.couleur.gradient)
                                .frame(width: 100, height: 100)
                            Image(systemName: symboleAffiche)
                                .font(.system(size: 44))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)

                    // Grille de symboles au choix — tap pour sélectionner.
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6),
                              spacing: 12) {
                        ForEach(symbolesDisponibles, id: \.self) { symbole in
                            Image(systemName: symbole)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(
                                    symboleAffiche == symbole
                                        ? genre.couleur.opacity(0.3)
                                        : Color.gray.opacity(0.15)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        symboleAffiche = symbole
                                    }
                                }
                        }
                    }
                }

                // MARK: Section — Synopsis
                Section("Synopsis") {
                    TextEditor(text: $synopsis)
                        .frame(minHeight: 90)
                }
            }
            .navigationTitle("Nouveau film")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Bouton d'annulation à gauche.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                // Bouton de confirmation à droite (désactivé si formulaire invalide).
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { ajouter() }
                        .disabled(!formulaireValide)
                }
            }
        }
    }

    // MARK: - Action

    // Construit le film à partir des champs, l'ajoute au store et ferme la feuille.
    private func ajouter() {
        let nouveauFilm = Film(
            titre: titre.trimmingCharacters(in: .whitespaces),
            realisateur: realisateur.trimmingCharacters(in: .whitespaces),
            annee: annee,
            genre: genre,
            statut: statut,
            synopsis: synopsis,
            affiche: symboleAffiche
        )
        withAnimation {
            store.ajouter(nouveauFilm)
        }
        dismiss()
    }
}

#Preview {
    AddFilmView()
        .environment(FilmStore())
}
