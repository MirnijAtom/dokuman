//
//  DokuManApp.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI
import StoreKit

// MARK: - DokuManApp

/// The main entry point for the DokuMan app. Sets up global environment objects and model containers.
@main
struct DokuManApp: App {
    // MARK: - State Objects
    @StateObject private var themeSettings = ThemeSettings()
    @StateObject private var languageSettings = LanguageSettings()
    @StateObject private var store = StoreKitManager()

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
                .environmentObject(languageSettings)
                .environment(\.locale, languageSettings.locale)
                .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
                .environmentObject(store)
                .task { await store.loadProducts() }
        }
        .modelContainer(for: [Document.self, Number.self])
    }
}
