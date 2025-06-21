//
//  DokuManApp.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

@main
struct DokuManApp: App {
    @StateObject private var themeSettings = ThemeSettings()
    @StateObject private var languageSettings = LanguageSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
                .environmentObject(languageSettings)
                .environment(\.locale, languageSettings.locale)
                .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [Document.self, Number.self])
    }
}
