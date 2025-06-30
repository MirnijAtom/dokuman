//
//  CategoriesSectionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

struct CategoriesSectionView: View {
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]
    @EnvironmentObject var languageSettings: LanguageSettings
    
    private var nonEmptyCategories: [DocumentCategory] {
        DocumentCategory.allCases.filter { category in
            documents.contains(where: { $0.category == category })
        }
    }
    
    @ViewBuilder
    private func categoryRow(for category: DocumentCategory) -> some View {
        NavigationLink {
            DocumentListView(title: category.label, documents: documents.filter { $0.category == category })
        } label: {
            HStack {
                Label(category.label, systemImage: category.icon)
                    .padding(.horizontal)
                    .foregroundColor(category.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.vertical, 0)
        }
    }
    
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
                Text(LocalizedStringKey("No categories yet"))
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
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
        .cornerRadius(0)
        .id(languageSettings.locale.identifier) // Force refresh when locale changes
    }
}

#Preview {
    let languageSettings = LanguageSettings()
    
    return CategoriesSectionView()
        .modelContainer(for: Document.self)
        .environmentObject(languageSettings)
}
