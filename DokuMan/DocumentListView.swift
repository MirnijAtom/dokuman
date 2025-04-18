import SwiftUI

struct DocumentListView: View {
    @Environment(\.modelContext) var modelContext

    var title: String
    var documents: [Document]

    @State private var listView = false
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                if listView {
                    List(documents) { document in
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
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                                .contextMenu {
                                    Button("Archive") {
                                        archiveDocument(document)
                                    }
                                    Button("Delete", role: .destructive) {
                                        deleteDocument(document)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
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
            .sheet(item: $selectedDocument) { document in
                PDFFullScreenView(document: document)
            }
        }
    }

    func archiveDocument(_ document: Document) {
        document.isArchived.toggle()
        try? modelContext.save()
    }

    func deleteDocument(_ document: Document) {
        modelContext.delete(document)
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
