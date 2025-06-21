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

//                    // Debug Count
//                    Text("Documents count: \(documents.count)")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                    
//                    // Button to add mockup files
//                    Button("Add mockup files") {
//                        addMockupFiles(using: modelContext)
//                    }
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
    HomeView(selectedTab: .constant(0))
        .modelContainer(for: Document.self)
}
