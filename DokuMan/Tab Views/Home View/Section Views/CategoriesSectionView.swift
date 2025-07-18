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
    @EnvironmentObject var languageSettings: LanguageSettings

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
            HStack {
                Image(systemName: "tag.fill")
                Text(LocalizedStringKey("Categories"))
            }
            .font(.headline)
            .padding(.horizontal)
            .padding(.vertical, 5)
            if nonEmptyCategories.isEmpty {
                GeometryReader { geometry in
                    HStack {
                        VStack {
                            Text(LocalizedStringKey("No documents yet. Add files from Photos, Files, or scan them with your camera."))
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .frame(width: geometry.size.width * 0.6)
                                .padding(.horizontal)
                                .padding(.leading, 26) // extra left padding
                        }
                        .frame(width: geometry.size.width * 0.6, alignment: .center)

                        VStack {
                            Image("emptyCategoriesIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.25, height: 70)
                                .padding()
                        }
                        .frame(width: geometry.size.width * 0.4, alignment: .center)
                    }
                }
                .frame(height: 110)
                .padding(.bottom, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(nonEmptyCategories, id: \.self) { category in
                        categoryRow(for: category)
                        if category != nonEmptyCategories.last {
                            Divider()
                        }
                    }
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 226)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(27)
        .id(languageSettings.locale.identifier) // Force refresh when locale changes
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
