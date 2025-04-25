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
        GridItem(.flexible())
    ]

    @State private var fullScreenIsPresented = false
    @State private var listView = false
    @State private var selectedDocument: Document? = nil

    
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 148.75, height: 210.5)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(documents) { document in
                        Button(action: {
                            selectedDocument = document
                            fullScreenIsPresented = true
                        }) {
                            VStack(spacing: 8) {
                                
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
                                        .contextMenu {
                                            Button("Archive") {
                                                archiveDocument(document: document)
                                            }
                                            Button("Delete", role: .destructive) {
                                                deleteDocument(document: document)
                                            }
                                        }


                                Text(document.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
