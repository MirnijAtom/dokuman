//
//  ArchiveView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 18.04.25.
//

import SwiftData
import SwiftUI

// MARK: - ArchiveView

/// Displays archived documents in a grid, allowing users to unarchive, delete, or preview them.
struct ArchiveView: View {
    // MARK: - Environment & Query
    @Environment(\.modelContext) var modelContext
    /// All archived documents, sorted by name.
    @Query(filter: #Predicate<Document> { $0.isArchived }, sort: \.name) var documents: [Document]

    // MARK: - Layout
    /// Two-column flexible grid layout for document previews.
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: - State
    @State private var fullScreenIsPresented = false
    @State private var listView = false // (Unused, but may be for future toggle)
    @State private var selectedDocument: Document? = nil

    /// A4 size in points (approx. 595 x 842, scaled for preview)
    let a4Size = CGSize(width: 148.75, height: 210.5)

    // MARK: - Body
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
                                    .scaleEffect(1.03)
                                    .frame(width: a4Size.width, height: a4Size.height)
                                    .clipped()
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                    .blur(radius: 0.5)
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Archive")
            Button("Add mockup files") {
                addMockupFiles()
            }
        }
    }

    // MARK: - Actions
    /// Toggles the archive status of a document.
    func archiveDocument(document: Document) {
        document.isArchived.toggle()
        try? modelContext.save()
    }

    /// Deletes a document from the model context.
    func deleteDocument(document: Document) {
        modelContext.delete(document)
        try? modelContext.save()
    }

    /// Adds mockup PDF files to the archive for testing/demo purposes.
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
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    ArchiveView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
