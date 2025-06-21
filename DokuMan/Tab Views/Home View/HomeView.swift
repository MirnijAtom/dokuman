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
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .modelContainer(for: Document.self)
}
