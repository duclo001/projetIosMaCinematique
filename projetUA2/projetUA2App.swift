//
//  projetUA2App.swift
//  projetUA2
//
//  Point d'entrée de l'application "Ma Cinémathèque".
//  On instancie le FilmStore une seule fois ici et on l'injecte dans
//  l'environnement SwiftUI pour qu'il soit accessible partout dans l'app.
//

import SwiftUI

@main
struct projetUA2App: App {

    // Le store est créé une seule fois pour toute la durée de vie de l'app.
    // @State garantit que l'instance persiste à travers les recompositions.
    @State private var store = FilmStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Injection du store dans l'environnement : toutes les vues enfant
                // peuvent le récupérer via @Environment(FilmStore.self).
                .environment(store)
        }
    }
}
