//
//  HomeView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var themeSettings: ThemeSettings

    
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]
    
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    FavoritesSectionView()

                    CategoriesSectionView()

                    NumbersSectionView(selectedTab: $selectedTab)
                        .padding(.bottom, 100)
                }
                .padding(.top)
            }
            
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)

            .toolbarBackground(Material.bar, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
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
