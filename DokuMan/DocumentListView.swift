import SwiftUI

struct DocumentListView: View {
    @Environment(\.modelContext) var modelContext
    
    var title: String
    var documents: [Document]
    
    @State private var listView = false
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false
    @State private var isSelected = true
    
    @State private var selectedDocuments: Set<Document> = []
    
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
                    ForEach(documents) { document in
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
                                
                                ZStack(alignment: .topTrailing) {
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
                                    }
                                    .padding()
                                    
                                    
                                    Button(action: {
                                        toggleSelection(of: document)
                                    }) {
                                        Image(systemName: selectedDocuments.contains(document) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedDocuments.contains(document) ? . green : .gray)
                                            .opacity(selectedDocuments.contains(document) ? 1 : 0.4)
                                            .font(.title)
                                            .background(Color.white.opacity(1))
                                            .clipShape(Circle())
                                            .padding(20)
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
            .fullScreenCover(item: $selectedDocument) { document in
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
    
    func addToFavorites(_ document: Document) {
        document.isFavorite.toggle()
        try? modelContext.save()
    }
    
    func toggleSelection(of document: Document) {
        if selectedDocuments.contains(document) {
            selectedDocuments.remove(document)
        } else {
            selectedDocuments.insert(document)
        }
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
