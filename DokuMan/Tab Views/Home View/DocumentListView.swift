import SwiftUI

// MARK: - DocumentListView

/// Displays a grid of documents for a given category or filter, with support for selection, sharing, and context menu actions.
struct DocumentListView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    /// The title for the navigation bar.
    var title: LocalizedStringKey
    /// The documents to display in the grid.
    var documents: [Document]
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false // (Unused, could be removed)
    @State private var selectedDocuments: Set<Document> = []
    @State private var isSharing = false
    @State private var isSelectionActive = false
    /// Two-column flexible grid layout for document previews.
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    /// A4 size in points (approx. 595 x 842, scaled for preview)
    let a4Size = CGSize(width: 148.75, height: 210.5)

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(documents) { document in
                        ZStack(alignment: .topTrailing) {
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                selectedDocument = document
                                fullScreenIsPresented = true
                            }) {
                                VStack(spacing: 8) {
                                    PDFPreview(data: document.versions.first!.fileData)
                                        .scaleEffect(1.03)
                                        .frame(width: a4Size.width, height: a4Size.height)
                                        .clipped()
                                        .cornerRadius(5)
                                        .shadow(radius: 3)
                                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                                        .contextMenu {
                                            Button("Favorites toggle") {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                                toggleFavorites(document, modelContext: modelContext)
                                            }
                                            Button("Archive toggle") {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                                archiveDocument(document, modelContext: modelContext)
                                            }
                                            Button("Delete", role: .destructive) {
                                                let generator = UIImpactFeedbackGenerator(style: .rigid)
                                                generator.impactOccurred()
                                                deleteDocument(document, modelContext: modelContext)
                                            }
                                        }
                                    Text(document.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                            .padding()
                            if isSelectionActive {
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    toggleSelection(of: document)
                                }) {
                                    Image(systemName: selectedDocuments.contains(document) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedDocuments.contains(document) ? .green : .gray)
                                        .opacity(selectedDocuments.contains(document) ? 1 : 0.4)
                                        .font(.title)
                                        .background(Color(.systemBackground))
                                        .clipShape(Circle())
                                        .padding(20)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .toolbar {
                if isSelectionActive {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isSharing = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isSelectionActive = false
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Select") {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation { isSelectionActive = true }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .fullScreenCover(item: $selectedDocument) { document in
                PDFFullScreenView(document: document)
            }
            .sheet(isPresented: $isSharing) {
                let urls = exportTempURLs(from: selectedDocuments)
                if !urls.isEmpty {
                    ShareSheet(activityItems: urls)
                } else {
                    Text("Error sharing documents.")
                }
            }
        }
    }

    // MARK: - Helpers
    /// Exports the selected documents as temporary PDF URLs for sharing.
    func exportTempURLs(from documents: Set<Document>) -> [URL] {
        var urls: [URL] = []
        for doc in documents {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(doc.name)
                .appendingPathExtension("pdf")
            do {
                try doc.versions.first!.fileData.write(to: tempURL)
                urls.append(tempURL)
            } catch {
                print("Failed to write PDF to temp for \(doc.name): \(error)")
            }
        }
        return urls
    }
    /// Toggles the selection state of a document in selection mode.
    func toggleSelection(of document: Document) {
        if selectedDocuments.contains(document) {
            selectedDocuments.remove(document)
        } else {
            selectedDocuments.insert(document)
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    DocumentListView(title: "Wohnung",
                     documents: [
                        Document(
                            name: "Meldebescheinigung",
                            category: .wohnung,
                            versions: [DocumentVersion(fileData: loadPDF(named: "meldebescheinigung"), dateAdded: Date())]
                        ),
                        Document(
                            name: "Wohnung Vertrag",
                            category: .wohnung,
                            versions: [DocumentVersion(fileData: loadPDF(named: "krankenversicherung"), dateAdded: Date())]
                        )
                     ]
    )
    .modelContainer(for: Document.self)
    .environmentObject(themeSettings)
    .environmentObject(languageSettings)
    .environment(\.locale, languageSettings.locale)
    .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
