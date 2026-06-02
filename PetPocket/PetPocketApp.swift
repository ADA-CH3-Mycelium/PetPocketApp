//
//  PetPocketApp.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI
import SwiftData
import Supabase

@main
struct PetPocketApp: App {
    @State private var authManager = AuthManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    VStack {
                        Text("Logged in as: \(authManager.currentUser?.email ?? "Unknown")")
                        Button("Sign Out") {
                            Task {
                                await authManager.signOut()
                            }
                        }
                    }
                } else {
                    LoginView()
                }
            }
            .environment(authManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
