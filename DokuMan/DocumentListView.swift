import SwiftUI

struct DocumentListView: View {
    @Environment(\.modelContext) var modelContext

    var title: String
    var documents: [Document]

    @State private var listView = false
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false
    
    @State private var documentsToRemove: Set<Document> = []

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 148.75, height: 210.5)

    var body: some View {
        NavigationStack {
            Group {
                if listView {
                    ForEach(documents.filter { !documentsToRemove.contains($0) }) { document in
                        Text(document.name)
                            .swipeActions {
                                Button("Archive", systemImage: "archivebox") {
                                    archiveDocument(document)
                                }
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deleteDocument(document)
                                }
                            }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(documents.filter { !documentsToRemove.contains($0) }) { document in
                                Button(action: {
                                    selectedDocument = document
                                    fullScreenIsPresented = true
                                }) {
                                    VStack(spacing: 8) {
                                        PDFPreview(data: document.versions.first!.fileData)
                                            .scaleEffect(1.03) // Adjust the scale factor for zooming in (1.0 is normal size, 1.2 is 20% zoomed in)
                                            .frame(width: a4Size.width, height: a4Size.height)
                                            .clipped() // Ensure that the overflow content is clipped (cut off)
                                            .cornerRadius(5)
                                            .shadow(radius: 3)
                                            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                                            .contextMenu {
                                                Button("Add to Favorites") {
                                                    addToFavorites(document)
                                                }
                                                Button("Archive") {
                                                    archiveDocument(document)
                                                }
                                                Button("Delete", role: .destructive) {
                                                    deleteDocument(document)
                                                }
                                            }

                                        Text(document.name)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    .padding()
                                }

                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 1), value: documentsToRemove)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        listView.toggle()
                    } label: {
                        listView
                        ? Label("Grid View", systemImage: "square.grid.2x2")
                        : Label("List View", systemImage: "list.bullet")
                    }
                }
            }
            .fullScreenCover(item: $selectedDocument) { document in
                PDFFullScreenView(document: document)
            }
        }
    }

    func archiveDocument(_ document: Document) {
        _ = withAnimation(.easeInOut(duration: 0.4)) {
            documentsToRemove.insert(document)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            document.isArchived.toggle()
            try? modelContext.save()
        }
    }

    func deleteDocument(_ document: Document) {
        _ = withAnimation(.spring()) {
            documentsToRemove.insert(document)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            modelContext.delete(document)
            try? modelContext.save()
        }
    }
    
    func addToFavorites(_ document: Document) {
            document.isFavorite.toggle()
            try? modelContext.save()
    }
}

// Helper function for preview
func loadPDF(named name: String) -> Data {
    guard let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
          let data = try? Data(contentsOf: url) else {
        return Data()
    }
    return data
}

#Preview {
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
}
