//
//  CategoriesView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 15.04.25.
//

import SwiftUI

// MARK: - CategoriesView

/// Displays a preview list of all document categories with their icons and colors.
struct CategoriesView: View {
    // MARK: - Body
    var body: some View {
        List(DocumentCategory.allCases, id: \.self) { category in
            HStack {
                ZStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 32, height: 32)
                    Image(systemName: category.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(category.label)
                    .font(.body)
                    .padding(.leading, 8)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Category Preview")
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    return CategoriesView()
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
