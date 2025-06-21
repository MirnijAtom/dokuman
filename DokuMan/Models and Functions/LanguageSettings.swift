import SwiftUI

class LanguageSettings: ObservableObject {
    @Published var locale: Locale {
        didSet {
            UserDefaults.standard.set(locale.identifier, forKey: "language")
        }
    }

    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "language") ?? "en"
        self.locale = Locale(identifier: savedLanguage)
    }
} 