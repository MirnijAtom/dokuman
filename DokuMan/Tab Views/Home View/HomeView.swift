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
    @EnvironmentObject var purchaseManager: PurchaseManager
    /// All non-archived documents, sorted by name.
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]
    /// The selected tab index (bound to parent TabView).
    @Binding var selectedTab: Int

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(purchaseManager.hasProAccess)")
                    FavoritesSectionView()
                    CategoriesSectionView()
                    NumbersSectionView(selectedTab: $selectedTab)
                        .padding(.bottom, 100)
                }
                .padding(.top)
            }
            .padding(.bottom, 10)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(purchaseManager.hasProAccess ? "DokuMan Pro" : "Home")
            .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)
            .toolbarBackground(Material.bar, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .id(purchaseManager.hasProAccess)
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    HomeView(selectedTab: .constant(0))
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
