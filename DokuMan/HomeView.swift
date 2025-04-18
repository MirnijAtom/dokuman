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
            List {
                // Pinned Section
                Section(header: Text("Pinned")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(documents) { document in
                                PDFPreview(data: document.versions.first!.fileData)
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(10)
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
                let document = Document(name: name.capitalized, category: category, versions: [version])
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
