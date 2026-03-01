//
//  LanguageSettings.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

// MARK: - Language Settings

/// Stores and manages the app's language/locale setting.
class LanguageSettings: ObservableObject {
    /// The current locale for the app. Updates UserDefaults when changed.
    @Published var locale: Locale {
        didSet {
            UserDefaults.standard.set(locale.identifier, forKey: "language")
        }
    }

    /// Initializes the language settings, loading from UserDefaults if available.
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "language"), !savedLanguage.isEmpty {
            self.locale = Locale(identifier: savedLanguage)
            return
        }

        // First launch: pick app language from device preferences (supports DE/EN).
        let supportedLanguages: Set<String> = ["de", "en"]
        let preferred = Locale.preferredLanguages
            .compactMap { Locale(identifier: $0).language.languageCode?.identifier.lowercased() }
            .first { supportedLanguages.contains($0) } ?? "en"

        self.locale = Locale(identifier: preferred)
    }
}
