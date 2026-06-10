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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var auth = AuthManager.shared
    @State private var store = PetStore()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // UI styling
    
    init() {
        // bg color of the entire picker
        UISegmentedControl.appearance().backgroundColor =
            UIColor.secondaryG

        // bg color of the selected
        UISegmentedControl.appearance()
            .selectedSegmentTintColor = UIColor.primaryG

        // text color for the selected
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [.foregroundColor: UIColor.white],
                for: .selected
            )

        // text color for unselected
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [.foregroundColor: UIColor.black],
                for: .normal
            )
        
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.isAuthenticated {
                PetListView(store: store)
                    .tint(Color("AccentColor"))
            } else {
                OnboardingView()
                    .tint(Color("AccentColor"))
            }
        }
        .environment(auth)
        .modelContainer(sharedModelContainer)
    }
}
