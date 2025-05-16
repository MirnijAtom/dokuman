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
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(systemName: "tag.fill")
                Text("Categories")
            }
            .font(.headline)
            .padding(.horizontal)
            
            ForEach(DocumentCategory.allCases, id: \.self) { category in
                let docsInCategory = documents.filter { $0.category == category }
                
                if !docsInCategory.isEmpty {
                                    NavigationLink {
                                        DocumentListView(title: category.label, documents: docsInCategory)
                                    } label: {
                                        HStack {
                                            Label(category.label, systemImage: category.icon)
                                                .foregroundColor(category.color)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(.regularMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal)
                                    }
                                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 226)
        .padding(.vertical, 12)
        .background(Color.teal.tertiary)
        .cornerRadius(0)
//        .shadow(radius: 2)
    }
}

#Preview {
    CategoriesSectionView()
        .modelContainer(for: Document.self)
}
