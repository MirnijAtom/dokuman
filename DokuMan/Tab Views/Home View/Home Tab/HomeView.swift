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
    @Query(sort: \Number.date) var numbers: [Number]
    @State private var showDocumentsView = false
    @State private var showNumbersView = false
    let onAddTap: () -> Void
    let onNumbersEditingChange: (Bool) -> Void
    
    private var nonEmptyCategories: [DocumentCategory] {
        DocumentCategory.allCases.filter { category in
            documents.contains(where: { $0.category == category })
        }
    }

    // MARK: - Body
    var body: some View {
        List {
            Section("Favorites") {
                FavoritesSectionView()
            }

            Section("Documents") {
                if nonEmptyCategories.isEmpty {
                    VStack(spacing: 12) {
                        ContentUnavailableView(
                            "No documents yet",
                            systemImage: "doc",
                            description: Text("Add files from Photos, Files, or scan them with your camera.")
                        )
                        Button(LocalizedStringKey("Add document")) {
                            onAddTap()
                        }
                        .font(.headline)
                        .foregroundStyle(.teal)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .glassEffect()
                    }
                    .listRowSeparator(.hidden)
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
                    Button(LocalizedStringKey("See all")) {
                        showDocumentsView = true
                    }
                    .font(.headline)
                    .foregroundStyle(.teal)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .glassEffect()
                }
            }

            Section("Numbers") {
                NumbersSectionView()
                Button(LocalizedStringKey(numbers.isEmpty ? "Add number" : "See all")) {
                    showNumbersView = true
                }
                .font(.headline)
                .foregroundStyle(.teal)
                .frame(maxWidth: .infinity, minHeight: 56)
                .glassEffect()
            }
        }
        .safeAreaPadding(.bottom, 92)
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AccountView()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .navigationDestination(isPresented: $showDocumentsView) {
            FilesView()
        }
        .navigationDestination(isPresented: $showNumbersView) {
            NumbersEditView(onEditingStateChange: onNumbersEditingChange)
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    HomeView(onAddTap: { }, onNumbersEditingChange: { _ in })
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(StoreKitManager())
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
