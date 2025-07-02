//
//  StorageInfoView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftData
import SwiftUI


struct StorageInfoView: View {
    @Query var documents: [Document]
    @Query var numbers: [Number]
    var body: some View {
        List {
            Text(String(format: NSLocalizedString("Documents saved: %@", comment: ""), "\(documents.count)"))
            Text(String(format: NSLocalizedString("Numbers saved: %@", comment: ""), "\(numbers.count)"))
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    StorageInfoView()
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
