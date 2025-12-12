import SwiftUI
import SwiftData

// MARK: - DocumentListView

struct DocumentListView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var store: StoreKitManager

    var title: LocalizedStringKey
    var documents: [Document]

    @State private var selectedDocument: Document? = nil
    @State private var selectedDocumentToShare: Document? = nil
    @State private var selectedDocuments: Set<Document> = []
    @State private var isSharing = false
    @State private var isSelectionActive = false

    // MARK: - Layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    let a4Size = CGSize(width: 148.75, height: 210.5)

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(documents) { document in
                        documentCell(document)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 70)
            .navigationTitle(title)
            .toolbar { toolbarContent }

            // Fullscreen PDF
            .fullScreenCover(item: $selectedDocument) { document in
                PDFFullScreenView(document: document)
            }

            // Share single
            .sheet(item: $selectedDocumentToShare) { document in
                let urls = exportTempURLs(from: [document])
                if !urls.isEmpty {
                    ShareSheet(activityItems: urls)
                } else {
                    Text("Error sharing document.")
                }
            }

            // Share multiple
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

    // MARK: - Toolbar
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if isSelectionActive {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation {
                        isSelectionActive = false
                        selectedDocuments.removeAll()
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    isSharing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation { isSelectionActive = false }
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
                    withAnimation {
                        isSelectionActive = true
                    }
                }
                .disabled(!store.isPro)
                .opacity(store.isPro ? 1 : 0.4)
            }
        }
    }

    // MARK: - Document Cell
    @ViewBuilder
    func documentCell(_ document: Document) -> some View {
        ZStack(alignment: .topTrailing) {
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                selectedDocument = document
            } label: {
                VStack(spacing: 8) {
                    PDFPreview(data: document.versions.first!.fileData)
                        .scaleEffect(1.03)
                        .frame(width: a4Size.width, height: a4Size.height)
                        .clipped()
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 8))
                        .contextMenu { contextMenu(for: document) }

                    Text(document.name)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
            .padding(10)

            if isSelectionActive {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    toggleSelection(of: document)
                } label: {
                    Image(systemName: selectedDocuments.contains(document) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedDocuments.contains(document) ? .green : .gray)
                        .font(.title)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .padding(15)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Context Menu
    @ViewBuilder
    func contextMenu(for document: Document) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            selectedDocumentToShare = document
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }

        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            toggleFavorites(document, modelContext: modelContext)
        } label: {
            Label(
                document.isFavorite ? "Remove from favorites" : "Add to favorites",
                systemImage: document.isFavorite ? "star.slash" : "star"
            )
        }

        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            archiveDocument(document, modelContext: modelContext)
        } label: {
            Label(
                document.isArchived ? "Unarchive" : "Archive",
                systemImage: "archivebox"
            )
        }
        .disabled(!store.isPro)
        .opacity(store.isPro ? 1 : 0.4)

        Divider()

        Button(role: .destructive) {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
            deleteDocument(document, modelContext: modelContext)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Helpers
    func toggleSelection(of document: Document) {
        if selectedDocuments.contains(document) {
            selectedDocuments.remove(document)
        } else {
            selectedDocuments.insert(document)
        }
    }

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
                print("❌ Failed to export \(doc.name): \(error)")
            }
        }

        return urls
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
