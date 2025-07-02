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
        let savedLanguage = UserDefaults.standard.string(forKey: "language") ?? "en"
        self.locale = Locale(identifier: savedLanguage)
    }
} 