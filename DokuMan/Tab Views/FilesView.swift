//
//  FilesView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

// MARK: - FilesView

/// Displays a grid of documents, with support for search, selection, sharing, and archiving.
struct FilesView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    @Query var documents: [Document]
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var purchaseManager: PurchaseManager
    @FocusState private var isSearchFocused: Bool
    @State private var searchText: String = ""
    @State private var selectedDocument: Document? = nil
    @State private var selectedDocumentToShare: Document? = nil
    @State private var selectedDocuments: Set<Document> = []
    @State private var isSelectionActive = false
    @State private var showArchived: Bool = false
    @State private var isShareSheetPresented = false

    // MARK: - Layout
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let a4Size = CGSize(width: 148.75, height: 210.5)

    // MARK: - Computed Properties
    /// Returns the filtered documents based on search and archive state.
    var filteredDocuments: [Document] {
        let filtered = searchText.isEmpty ? documents : documents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        return showArchived ? filtered.filter { $0.isArchived } : filtered.filter { !$0.isArchived }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if documents.isEmpty {
                        VStack {
                            Image("emptyFilesIcon")
                                .resizable()
                                .scaledToFit()
                                .padding(.trailing, 30)
                                .frame(height: 100)
                            Text("Tap the plus button to add your first document. You can upload from Files, Photos, or scan with your camera.")
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .padding()
                                .padding(.trailing, 30)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach(filteredDocuments) { document in
                                    documentCell(document)
                                }
                                .animation(.default, value: filteredDocuments)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .padding(.bottom, 10)
                        .background(Color(.systemGroupedBackground))
                    }
                }
                .toolbar { toolbarContent }
                .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)
                .navigationTitle(showArchived ? LocalizedStringKey("Archive") : LocalizedStringKey("Documents"))
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .focused($isSearchFocused)
                .fullScreenCover(item: $selectedDocument) { document in
                    PDFFullScreenView(document: document)
                }
                .sheet(item: $selectedDocumentToShare) { document in
                    let urls = exportTempURLs(from: [document])
                    if !urls.isEmpty {
                        ShareSheet(activityItems: urls)
                    } else {
                        Text("Error sharing document.")
                    }
                }
                .sheet(isPresented: $isShareSheetPresented) {
                    let urls = exportTempURLs(from: selectedDocuments)
                    if !urls.isEmpty {
                        ShareSheet(activityItems: urls)
                    } else {
                        Text("Error sharing document.")
                    }
                }
                .toolbarBackground(Material.bar, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)

                // Archive toggle floating button
                if purchaseManager.hasProAccess {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    showArchived.toggle()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: showArchived ? "document.on.document" : "archivebox")
                                    Text(LocalizedStringKey(showArchived ? "Show documents" : "Show archive"))
                                }
                                .font(.callout)
                                .foregroundStyle(.teal)
                                .frame(height: 15)
                                .padding()
                                .background(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 5)
                                .transition(.blurReplace)
                                .id(showArchived) // key for animating between states
                            }
                            .padding(.bottom, 38)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if isSelectionActive {
            ToolbarItem(placement: .topBarLeading) {
                Button(LocalizedStringKey("Cancel")) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation {
                        isSelectionActive = false
                        selectedDocuments = []
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    isShareSheetPresented = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation { isSelectionActive = false }
                    }
                } label: {
                    Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up")
                }
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation { isSelectionActive = true }
                } label: {
                    Text(LocalizedStringKey("Select"))
                    .disabled(!purchaseManager.hasProAccess)
                    .opacity(purchaseManager.hasProAccess ? 1 : 0.4)
                }
            }

        }
    }

    // MARK: - Document Cell
    /// Renders a single document cell in the grid, with context menu and selection support.
    @ViewBuilder
    func documentCell(_ document: Document) -> some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                selectedDocument = document
            }) {
                VStack {
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
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                selectedDocumentToShare = document
                            } label: {
                                Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up")
                            }
                            if !showArchived {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    toggleFavorites(document, modelContext: modelContext)
                                } label: {
                                    Label(LocalizedStringKey(document.isFavorite ? "Remove from favorites" : "Add to favorites"), systemImage: document.isFavorite ? "star.slash" : "star")
                                }
                            }

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                archiveDocument(document, modelContext: modelContext)
                            } label: {
                                Label(LocalizedStringKey(document.isArchived ? "Unarchive" : "Archive"), systemImage: document.isArchived ? "archivebox" : "archivebox")
                            }
                            .disabled(!purchaseManager.hasProAccess)
                            .opacity(purchaseManager.hasProAccess ? 1 : 0.4)
                            Divider()
                            Button(role: .destructive) {
                                let generator = UIImpactFeedbackGenerator(style: .rigid)
                                generator.impactOccurred()
                                deleteDocument(document, modelContext: modelContext)
                            } label: {
                                Label(LocalizedStringKey("Delete"), systemImage: "trash")
                            }
                        }
                    if let firstVersion = document.versions.first {
                        Text(firstVersion.dateFormatted)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .padding(.top, 6)
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
    let purchaseManager = PurchaseManager()

    return FilesView()
        .modelContainer(for: Document.self)
        .environmentObject(purchaseManager)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
