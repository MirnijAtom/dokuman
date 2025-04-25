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
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 119, height: 168.4)


    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]

    var body: some View {
        let favorites = documents.filter { $0.isFavorite }

        NavigationStack {
            List {
                // Pinned Section
                Section(header: Text("Favourites")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(favorites) { document in
                                PDFPreview(data: document.versions.first!.fileData)
                                    .scaledToFill() // Scale the PDF to fill the fixed container
                                    .frame(width: a4Size.width, height: a4Size.height) // Set the fixed size
                                    .blur(radius: 0.4)
                                    .opacity(0.9)
                                    .cornerRadius(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                                        .fill(Color.gray.opacity(0.2)))
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                                }
                        }
                        .padding(.vertical)
                    }
                }

                // Button to add mockup files
                Button("Add mockup files") {
                    addMockupFiles()
                }

                // Categories Section
                Section(header: Text("Categories")) {
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

                // Debug Count
                Text("Documents count: \(documents.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Home")
        }
    }

    func addMockupFiles() {
        let fileNames = [
            ("krankenversicherung", DocumentCategory.versicherung),
            ("lebenslauf", DocumentCategory.arbeit),
            ("meldebescheinigung", DocumentCategory.wohnung),
            ("portfolio", DocumentCategory.studium),
            ("versicherung", DocumentCategory.versicherung)
        ]

        for (name, category) in fileNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
               let data = try? Data(contentsOf: url) {
                let version = DocumentVersion(fileData: data, dateAdded: Date())
                let document = Document(name: name.capitalized, category: category,  versions: [version])
                document.isFavorite = true
                modelContext.insert(document)
            }
        }

        try? modelContext.save()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Document.self)
}
