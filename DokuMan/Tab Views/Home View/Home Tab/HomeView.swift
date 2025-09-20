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

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
//                    Text("\(purchaseManager.hasProAccess)")
                    FavoritesSectionView()
                    CategoriesSectionView()
                    NumbersSectionView(selectedTab: $selectedTab)
                        .padding(.bottom, 100)
                }
                .padding(.top)
            }
            .padding(.bottom, 50)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(store.isPro ? "DokuMan Pro" : "Home")
            .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)
            .toolbarBackground(.visible, for: .navigationBar)
            .ignoresSafeArea(edges: .bottom)
        }
        .id(store.isPro)
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    HomeView(selectedTab: .constant(0))
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(StoreKitManager())
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
