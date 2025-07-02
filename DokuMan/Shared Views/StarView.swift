//
//  StarView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

// MARK: - StarView

/// A simple interactive star icon for toggling favorite state (for demo or preview purposes).
struct StarView: View {
    // MARK: - State
    @State private var isFavourite: Bool = false

    // MARK: - Body
    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundColor(isFavourite ? .yellow : Color(.systemBackground))
            Button(action: { isFavourite.toggle() }) {
                Image(systemName: "star")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    StarView()
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
