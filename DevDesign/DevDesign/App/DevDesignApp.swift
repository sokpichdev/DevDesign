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
    // All Phase 1 models registered here. Add new models each phase.
    //
    // CloudKit is deliberately off: the app ships no iCloud entitlement or container, so
    // `.automatic` could never sync and only risked container errors at launch. Enabling it
    // means adding the iCloud capability *and* auditing SavedPalette/SavedColor for
    // CloudKit's constraints (all properties optional or defaulted, no unique attributes).
    let container: ModelContainer = {
        let schema = Schema([
            SavedPalette.self,
            SavedColor.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
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
