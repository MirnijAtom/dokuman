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
    
    var body: some View {
        
        Text("Categories")
            .font(.headline)
            .padding(.horizontal)
        
        ForEach(DocumentCategory.allCases, id: \.self) { category in
            let docsInCategory = documents.filter { $0.category == category }
            
            if !docsInCategory.isEmpty {
                NavigationLink {
                    DocumentListView(title: category.label, documents: docsInCategory)
                } label: {
                    Label(category.label, systemImage: category.icon)
                        .foregroundColor(category.color)
                }
            }
        }
    }
}

#Preview {
    CategoriesSectionView()
        .modelContainer(for: Document.self)
}
