//
//  ContentView.swift
//  projetUA2
//
//  Vue racine de l'application. Contient un TabView qui donne accès aux
//  trois sections principales : Films, Favoris et Statistiques.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // TabView est le conteneur d'onglets standard d'iOS.
        // Chaque .tabItem définit l'icône et le libellé de l'onglet.
        TabView {
            FilmsListView()
                .tabItem {
                    Label("Films", systemImage: "film.stack")
                }

            FavoritesView()
                .tabItem {
                    Label("Favoris", systemImage: "heart.fill")
                }

            StatsView()
                .tabItem {
                    Label("Statistiques", systemImage: "chart.pie.fill")
                }
        }
        // Teinte globale de l'app — donne une identité visuelle cohérente.
        .tint(.indigo)
    }
}

#Preview {
    ContentView()
        .environment(FilmStore())
}
