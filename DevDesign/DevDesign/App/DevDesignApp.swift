//
//  DevDesignApp.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import SwiftData

@main
struct DevDesignApp: App {

    // MARK: - SwiftData Container
    // All Phase 1 models registered here.
    // Add new models each phase — CloudKit sync is automatic via .cloud store.
    let container: ModelContainer = {
        let schema = Schema([
            SavedPalette.self,
            SavedColor.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic   // iCloud sync out of the box
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // In production, handle this gracefully with a fallback local store
            fatalError("DevDesign: Failed to create ModelContainer — \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                // Lock to portrait for iPhone v1
                .onAppear {
                    AppearanceConfigurator.apply()
                }
        }
    }
}

// MARK: - Appearance Configurator
// Centralises any UIKit appearance overrides needed globally.
enum AppearanceConfigurator {
    static func apply() {
        // Ensure navigation bars adopt our design system tint
        UINavigationBar.appearance().tintColor = UIColor(DSColors.accent)
    }
}
