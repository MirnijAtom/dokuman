import SwiftUI

class ThemeSettings: ObservableObject {
    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode") {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
} 