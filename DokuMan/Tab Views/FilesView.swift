//
//  FilesView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct FilesView: View {
    @Environment(\.modelContext) var modelContext
    @Query var documents: [Document]
    
    @EnvironmentObject var themeSettings: ThemeSettings
    
    @FocusState private var isSearchFocused: Bool
    @State private var searchText: String = ""
    
    @State private var selectedDocument: Document? = nil
    @State private var selectedDocuments: Set<Document> = []
    @State private var isSharing = false
    @State private var isSelectionActive = false
    
    @State private var showArchived: Bool = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let a4Size = CGSize(width: 148.75, height: 210.5)
    
    var filteredDocuments: [Document] {
        let filtered = searchText.isEmpty ? documents : documents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        return showArchived ? filtered.filter { $0.isArchived } : filtered.filter { !$0.isArchived }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
//                    Text("\(themeSettings.isDarkMode)")
//                        .background(.red)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(filteredDocuments) { document in
                                documentCell(document)
                            }
                            .animation(.default, value: filteredDocuments)
                        }
                        .padding(.horizontal)
                    }
                    .background(Color(.systemGroupedBackground))
                }
                .toolbar { toolbarContent }
                .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)
                .navigationTitle(showArchived ? " Archive" : "Documents")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .focused($isSearchFocused)
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
                .toolbarBackground(Material.bar, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showArchived.toggle()
                        } label: {
                            Label(showArchived ? "Show documents" : " Show archive", systemImage: showArchived ? "document.on.document" : "archivebox")
                                .frame(height: 30)
                                .padding()
                                .foregroundStyle(.teal)
                                .background(.ultraThinMaterial)
                                .clipShape(.capsule)
                                .shadow(radius: 2)
                        }
                        .padding(.bottom, 28)
                        Spacer()
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if isSelectionActive {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    isSelectionActive = false
                    selectedDocuments = []
                }
            }
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
                    isSelectionActive = true
                }
            }
        }
    }
    
    @ViewBuilder
    func documentCell(_ document: Document) -> some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                selectedDocument = document
            }) {
                VStack(spacing: 16) {
                    PDFPreview(data: document.versions.first!.fileData)
                        .scaleEffect(1.03)
                        .frame(width: a4Size.width, height: a4Size.height)
                        .clipped()
                        .cornerRadius(8)
                        .shadow(radius: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                                .fill(Color.gray.opacity(showArchived ? 0.4 : 0))
                        )
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 8))
                        .contextMenu {
                            Button {
                                selectedDocuments = [document]
                                isSharing = true
                                print("Selected document for sharing: \(document.name)")
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            if !showArchived {
                                Button {
                                    toggleFavorites(document, modelContext: modelContext)
                                } label: {
                                    Label(document.isFavorite ? "Remove from favorites" : "Add to favorites", systemImage: document.isFavorite ? "star.slash" : "star")
                                }
                            }
                            
                            Button {
                                archiveDocument(document, modelContext: modelContext)
                            } label: {
                                Label(document.isArchived ? "Unarchive" : "Archive", systemImage: document.isArchived ? "archivebox" : "archivebox")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                deleteDocument(document, modelContext: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    
                    Text(document.name)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            
            if isSelectionActive {
                Button(action: {
                    toggleSelection(of: document)
                }) {
                    Image(systemName: selectedDocuments.contains(document) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedDocuments.contains(document) ? .green : .gray)
                        .font(.title)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .padding(15)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func exportTempURLs(from documents: Set<Document>) -> [URL] {
        var urls: [URL] = []
        for doc in documents {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(doc.name)
                .appendingPathExtension("pdf")
            do {
                try doc.versions.first!.fileData.write(to: tempURL)
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    urls.append(tempURL)
                    print("Successfully wrote PDF to temp for \(doc.name) at \(tempURL)")
                } else {
                    print("File does not exist at \(tempURL)")
                }
            } catch {
                print("Failed to write PDF to temp for \(doc.name): \(error)")
            }
        }
        return urls
    }
    
    func toggleSelection(of document: Document) {
        if selectedDocuments.contains(document) {
            selectedDocuments.remove(document)
        } else {
            selectedDocuments.insert(document)
        }
    }
}


#Preview {
    FilesView()
        .modelContainer(for: Document.self)
}
