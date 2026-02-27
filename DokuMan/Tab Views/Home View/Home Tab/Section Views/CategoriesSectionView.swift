//
//  CategoriesSectionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

// MARK: - CategoriesSectionView

/// Displays a list of document categories that have at least one document, with navigation to each category's document list.
struct CategoriesSectionView: View {
    // MARK: - Query & Environment
    /// All non-archived documents, sorted by name.
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]
    // MARK: - Computed Properties
    /// Categories that have at least one document.
    private var nonEmptyCategories: [DocumentCategory] {
        DocumentCategory.allCases.filter { category in
            documents.contains(where: { $0.category == category })
        }
    }

    // MARK: - Category Row
    /// Renders a navigation row for a given document category.
    @ViewBuilder
    private func categoryRow(for category: DocumentCategory) -> some View {
        NavigationLink {
            DocumentListView(title: category.label, documents: documents.filter { $0.category == category })
        } label: {
            HStack {
                HStack {
                    Image(systemName: category.icon)
                        .frame(width: 25)
                    Text(category.label)
                }
                .foregroundColor(category.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.vertical, 0)
        }
        .simultaneousGesture(TapGesture().onEnded {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        })
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if nonEmptyCategories.isEmpty {
                ContentUnavailableView(
                    "No documents yet",
                    systemImage: "doc",
                    description: Text("Add files from Photos, Files, or scan them with your camera.")
                )
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(nonEmptyCategories, id: \.self) { category in
                        categoryRow(for: category)
                        if category != nonEmptyCategories.last {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 226)
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    return CategoriesSectionView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
