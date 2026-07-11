//
//  StatsView.swift
//  projetUA2
//
//  Vue de statistiques. Illustre le dessin 2D custom du Module 9 :
//  un diagramme circulaire (camembert) dessiné à la main avec Path,
//  ainsi que des cartes de résumé.
//

import SwiftUI

struct StatsView: View {

    @Environment(FilmStore.self) private var store

    // État qui déclenche l'animation d'entrée du diagramme.
    @State private var progressionAnimation: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Cartes de résumé
                    cartesResume

                    // MARK: Diagramme circulaire des genres
                    if !store.repartitionParGenre.isEmpty {
                        VStack(spacing: 16) {
                            Text("Répartition par genre")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Diagramme + légende côte à côte.
                            HStack(alignment: .top, spacing: 20) {
                                CamembertView(
                                    donnees: store.repartitionParGenre,
                                    progression: progressionAnimation
                                )
                                .frame(width: 160, height: 160)

                                legende
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // MARK: Note moyenne
                    if let moyenne = noteMoyenne {
                        carteNoteMoyenne(moyenne)
                    }
                }
                .padding()
            }
            .navigationTitle("Statistiques")
            // Animation d'entrée : le camembert se remplit progressivement.
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    progressionAnimation = 1
                }
            }
            .onDisappear {
                // Remise à zéro pour rejouer l'animation à chaque affichage de l'onglet.
                progressionAnimation = 0
            }
        }
    }

    // MARK: - Cartes de résumé (3 mini-cartes)

    private var cartesResume: some View {
        HStack(spacing: 12) {
            CarteStat(
                titre: "Total",
                valeur: "\(store.films.count)",
                icone: "film.stack",
                couleur: .indigo
            )
            CarteStat(
                titre: "Vus",
                valeur: "\(store.filmsParStatut(.vu).count)",
                icone: "checkmark.circle.fill",
                couleur: .green
            )
            CarteStat(
                titre: "Favoris",
                valeur: "\(store.favoris.count)",
                icone: "heart.fill",
                couleur: .red
            )
        }
    }

    // MARK: - Légende du diagramme

    private var legende: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(store.repartitionParGenre, id: \.genre) { entree in
                HStack(spacing: 6) {
                    Circle()
                        .fill(entree.genre.couleur)
                        .frame(width: 10, height: 10)
                    Text(entree.genre.rawValue)
                        .font(.caption)
                    Spacer()
                    Text("\(entree.nombre)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Note moyenne

    private var noteMoyenne: Double? {
        let filmsNotes = store.films.filter { $0.note > 0 }
        guard !filmsNotes.isEmpty else { return nil }
        let total = filmsNotes.reduce(0) { $0 + $1.note }
        return Double(total) / Double(filmsNotes.count)
    }

    private func carteNoteMoyenne(_ moyenne: Double) -> some View {
        VStack(spacing: 8) {
            Text("Note moyenne")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Text(String(format: "%.1f", moyenne))
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(.yellow)

                VStack(alignment: .leading) {
                    // Étoiles proportionnelles à la note moyenne.
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: Double(i) <= moyenne ? "star.fill"
                                  : (Double(i) - 0.5 <= moyenne ? "star.leadinghalf.filled" : "star"))
                                .foregroundStyle(.yellow)
                        }
                    }
                    Text("sur 5")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Composant : Carte statistique
// Petite carte utilisée dans la rangée du haut pour afficher un chiffre clé.
private struct CarteStat: View {
    let titre: String
    let valeur: String
    let icone: String
    let couleur: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icone)
                .font(.title2)
                .foregroundStyle(couleur)
            Text(valeur)
                .font(.title.bold())
            Text(titre)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Composant : Diagramme circulaire (camembert)
// Forme personnalisée dessinée avec Path (Module 9).
// Chaque part est un secteur (Slice) construit avec addArc.
private struct CamembertView: View {
    let donnees: [(genre: GenreFilm, nombre: Int)]
    // progression : 0 = pas encore dessiné, 1 = dessin complet (pour l'animation).
    let progression: Double

    // Total des films représentés — sert à calculer la proportion de chaque secteur.
    private var total: Int {
        donnees.reduce(0) { $0 + $1.nombre }
    }

    var body: some View {
        // ZStack : on empile chaque secteur les uns sur les autres.
        ZStack {
            ForEach(0..<donnees.count, id: \.self) { index in
                SecteurShape(
                    debut: angleDebut(index: index),
                    fin: angleFin(index: index, progression: progression)
                )
                .fill(donnees[index].genre.couleur)
            }

            // Cercle central blanc pour donner un effet "donut".
            Circle()
                .fill(Color(.systemBackground))
                .padding(45)

            // Total au centre.
            VStack(spacing: 0) {
                Text("\(total)")
                    .font(.title2.bold())
                Text("films")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Angle de départ du secteur d'index i (en degrés, 0 = midi).
    private func angleDebut(index: Int) -> Double {
        let partiesAvant = donnees.prefix(index).reduce(0) { $0 + $1.nombre }
        return Double(partiesAvant) / Double(total) * 360
    }

    // Angle de fin, multiplié par la progression pour l'animation.
    private func angleFin(index: Int, progression: Double) -> Double {
        let partiesJusquIci = donnees.prefix(index + 1).reduce(0) { $0 + $1.nombre }
        let angleComplet = Double(partiesJusquIci) / Double(total) * 360
        // Interpole entre l'angle de début et l'angle complet selon la progression.
        return angleDebut(index: index) + (angleComplet - angleDebut(index: index)) * progression
    }
}

// MARK: - Forme personnalisée : un secteur de camembert
// Implémente le protocole Shape (Module 9). Dessine un triangle "en pointe"
// entre le centre du cercle et deux angles sur le pourtour.
private struct SecteurShape: Shape {
    let debut: Double  // Angle de début en degrés (0 = haut du cercle)
    let fin: Double    // Angle de fin en degrés

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let rayon = min(rect.width, rect.height) / 2

        // On part du centre, on trace un arc, puis on referme.
        // -90° pour que le secteur commence en haut (à midi) plutôt qu'à 3h.
        path.move(to: centre)
        path.addArc(
            center: centre,
            radius: rayon,
            startAngle: .degrees(debut - 90),
            endAngle: .degrees(fin - 90),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    StatsView()
        .environment(FilmStore())
}
