//
//  HomeView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

// MARK: - HomeView

/// The main home screen, showing favorites, categories, and numbers sections.
struct HomeView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var store: StoreKitManager
    /// All non-archived documents, sorted by name.
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]
    /// The selected tab index (bound to parent TabView).
    @Binding var selectedTab: Int
    let onAddTap: () -> Void
    
    private var nonEmptyCategories: [DocumentCategory] {
        DocumentCategory.allCases.filter { category in
            documents.contains(where: { $0.category == category })
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section("Favorites") {
                    FavoritesSectionView()
                }

                Section("Documents") {
                    if nonEmptyCategories.isEmpty {
                        ContentUnavailableView(
                            "No documents yet",
                            systemImage: "doc",
                            description: Text("Add files from Photos, Files, or scan them with your camera.")
                        )
                    } else {
                        ForEach(nonEmptyCategories, id: \.self) { category in
                            NavigationLink {
                                DocumentListView(
                                    title: category.label,
                                    documents: documents.filter { $0.category == category }
                                )
                            } label: {
                                HStack {
                                    HStack {
                                        Image(systemName: category.icon)
                                            .frame(width: 25)
                                        Text(category.label)
                                    }
                                    .foregroundColor(category.color)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    Button(LocalizedStringKey("Add document")) {
                        onAddTap()
                    }
                    .font(.headline)
                    .foregroundStyle(.teal)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .glassEffect()
                }

                Section("Numbers") {
                    NumbersSectionView(selectedTab: $selectedTab)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(store.isPro ? "DokuMan Pro" : "Home")
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    HomeView(selectedTab: .constant(0)) { }
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(StoreKitManager())
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
