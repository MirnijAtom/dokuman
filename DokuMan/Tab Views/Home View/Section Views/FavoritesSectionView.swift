//
//  FavoritesSectionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

struct FavoritesSectionView: View {
    @Environment(\.modelContext) var modelContext
    
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 132, height: 187)
    
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false
    
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]

    
    var body: some View {
        
        let favorites = documents.filter { $0.isFavorite }
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            .font(.headline)
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(favorites) { document in
                        Button {
                            selectedDocument = document
                            fullScreenIsPresented = true
                        } label: {
                            PDFPreview(data: document.versions.first!.fileData)
                                .scaleEffect(1.03)
                                .frame(width: a4Size.width, height: a4Size.height)
                                .clipped()
                                .mask(RoundedRectangle(cornerRadius: 5))
                                .shadow(radius: 3)
                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                                .contextMenu {
                                    Button("Favorites toggle") {
                                        toggleFavorites(document, modelContext: modelContext)
                                    }
                                    Button("Archive toggle") {
                                        archiveDocument(document, modelContext: modelContext)
                                    }
                                    Button("Delete", role: .destructive) {
                                        deleteDocument(document, modelContext: modelContext)
                                    }
                                }
                        }
                    }
                    .padding(5)
                }
                .padding(.horizontal)
            }
        }
        .frame(minHeight: 226)
        .padding(.vertical, 12)
        .background(Color.yellow)
        .cornerRadius(0)
        .shadow(radius: 2)

        .fullScreenCover(item: $selectedDocument) { document in
            PDFFullScreenView(document: document)
        }
        
        //Add mockup files
        Button("Add mockup files") {
            addMockupFiles(using: modelContext)
        }
        .padding()
    }
}

#Preview {
    FavoritesSectionView()
        .modelContainer(for: Document.self)
        .onAppear {
            // Create a mock document container
            let container = try! ModelContainer(for: Document.self)
            let context = container.mainContext

            // Add mock documents to the container for preview
            let filenames = [
                "krankenversicherung",
                "lebenslauf",
                "meldebeschainigung",
                "portfolio",
                "versicherung"
            ]

            // Insert mock documents
            for name in filenames {
                if let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
                   let data = try? Data(contentsOf: url) {
                    let version = DocumentVersion(fileData: data, dateAdded: Date())
                    let doc = Document(name: name.capitalized, isFavorite: true, isArchived: false, category: .wohnung, versions: [version])
                    context.insert(doc)
                }
            }
        }
}
