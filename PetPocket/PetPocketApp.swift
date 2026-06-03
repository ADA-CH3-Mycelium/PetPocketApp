//
//  PetPocketApp.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI
import SwiftData

@main
struct PetPocketApp: App {
    @State private var auth = AuthManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if auth.isAuthenticated {
                EmptyStatePetList()
            } else {
                AuthView()
            }
        }
        .environment(auth)
        .modelContainer(sharedModelContainer)
    }
}
