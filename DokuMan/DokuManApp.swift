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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
                .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [Document.self, Number.self])
    }
}
