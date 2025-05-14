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
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    

                    FavoritesSectionView()



                    CategoriesSectionView()



                    NumbersSectionView()

                    // Debug Count
                    Text("Documents count: \(documents.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // Button to add mockup files
                    Button("Add mockup files") {
                        addMockupFiles(using: modelContext)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            .background(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Document.self)
}
