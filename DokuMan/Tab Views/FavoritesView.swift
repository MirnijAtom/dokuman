//
//  FavouritesView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct FilesView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var documents: [Document]
    
    @FocusState private var isSearchFocused: Bool
    
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false
    @State private var selectedDocuments: Set<Document> = []
    @State private var isSharing = false
    @State private var isSelectionActive = false
    
    @State private var searchText: String = ""

    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 148.75, height: 210.5)
    
    var body: some View {
        
        var filteredDocuments: [Document] {
            if searchText.isEmpty {
                return documents
            } else {
                return documents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        ZStack(alignment: .bottom) {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredDocuments) { document in
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
                                                Button("Favorites toggle") {
                                                    toggleFavorites(document, modelContext: modelContext)
                                                }
                                                Button("Archive toggle") {
                                                    archiveDocument(document, modelContext: modelContext)
                                                }
                                                Button("Delete", role: .destructive) {
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
                                        toggleSelection(of: document)
                                    }) {
                                        Image(systemName: selectedDocuments.contains(document) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedDocuments.contains(document) ? .green : .gray)
                                            .opacity(selectedDocuments.contains(document) ? 1 : 0.4)
                                            .font(.title)
                                            .background(Color.white.opacity(1))
                                            .clipShape(Circle())
                                            .padding(20)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .animation(.spring(), value: filteredDocuments)
                    }
                    .padding(.horizontal)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isSearchFocused = false
                    searchText = ""
                    print("taptap")
                }
                .toolbar {
                    if isSelectionActive {
                        ToolbarItem(placement: .topBarTrailing) {
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
            
            //Search Button
            
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText)
                    .focused($isSearchFocused)
            }
            .frame(maxWidth: 250)
            .padding()
            .background(Color.teal.opacity(0.1))
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
            .padding(.horizontal)
            .padding(.bottom, 20)
            
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
