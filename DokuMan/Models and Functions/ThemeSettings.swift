//
//  ThemeSettings.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

// MARK: - Theme Settings

/// Stores and manages the app's theme (dark mode/light mode) setting.
class ThemeSettings: ObservableObject {
    /// Whether dark mode is enabled. Updates UserDefaults when changed.
    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode") {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
}


