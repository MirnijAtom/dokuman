//
//  ArchiveView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 18.04.25.
//

import SwiftData
import SwiftUI

struct ArchiveView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Document> { $0.isArchived }, sort: \.name) var documents: [Document]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State private var fullScreenIsPresented = false
    @State private var listView = false
    @State private var selectedDocument: Document? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(documents) { document in
                        Button(action: {
                            selectedDocument = document
                            fullScreenIsPresented = true
                        }) {
                            VStack(spacing: 8) {
                                PDFPreview(data: document.versions.first!.fileData)
                                    .frame(height: 200)
                                    .cornerRadius(12)

                                Text(document.name)
                                    .font(.caption)
                            }
                        }
                        .contextMenu {
                            Button("Archive") {
                                archiveDocument(document: document)
                            }
                            Button("Delete", role: .destructive) {
                                deleteDocument(document: document)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Archive")

            Button("Add mockup files") {
                addMockupFiles()
            }
        }
    }

    func archiveDocument(document: Document) {
        document.isArchived.toggle()
        try? modelContext.save()
    }

    func deleteDocument(document: Document) {
        modelContext.delete(document)
        try? modelContext.save()
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
                let document = Document(name: name.capitalized, isArchived: true, category: category, versions: [version])
                modelContext.insert(document)
            }
        }

        try? modelContext.save()
    }
}

#Preview {
    ArchiveView()
        .modelContainer(for: Document.self)
}
