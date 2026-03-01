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
    @Query(sort: \Document.createdDate, order: .reverse) var documents: [Document]
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var store: StoreKitManager
    @FocusState private var isSearchFocused: Bool
    @State private var searchText: String = ""
    @State private var selectedDocument: Document? = nil
    @State private var selectedDocumentToShare: Document? = nil
    @State private var selectedDocuments: Set<Document> = []
    @State private var isSelectionActive = false
    @State private var showArchived: Bool = false
    @State private var isShareSheetPresented = false
    @State private var documentPendingDeletion: Document?
    @State private var showDeleteSelectedConfirmation = false
    @State private var showGetPro = false

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
                    .safeAreaPadding(.bottom, 92)
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
            .confirmationDialog(
                "Delete document?",
                isPresented: Binding(
                    get: { documentPendingDeletion != nil },
                    set: { newValue in
                        if !newValue { documentPendingDeletion = nil }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let document = documentPendingDeletion {
                        deleteDocument(document, modelContext: modelContext)
                    }
                    documentPendingDeletion = nil
                }
                Button("Cancel", role: .cancel) {
                    documentPendingDeletion = nil
                }
            }
            .confirmationDialog(
                "Delete selected documents?",
                isPresented: $showDeleteSelectedConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    for document in selectedDocuments {
                        deleteDocument(document, modelContext: modelContext)
                    }
                    selectedDocuments.removeAll()
                    withAnimation { isSelectionActive = false }
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showGetPro) {
                NavigationStack {
                    SubscriptionView()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if isSelectionActive {
            if !store.isPro {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Get Pro") {
                        showGetPro = true
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation {
                        isSelectionActive = false
                        selectedDocuments = []
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    isShareSheetPresented = true
                } label: {
                    Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    showDeleteSelectedConfirmation = true
                } label: {
                    Label(LocalizedStringKey("Delete"), systemImage: "trash")
                }
                Spacer()
            }
        } else {
            if !store.isPro {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Get Pro") {
                        showGetPro = true
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation { isSelectionActive = true }
                    } label: {
                        Label(LocalizedStringKey("Select"), systemImage: "checkmark.circle")
                    }
                    .disabled(!store.isPro)

                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            showArchived.toggle()
                        }
                    } label: {
                        Label(LocalizedStringKey(showArchived ? "Show documents" : "Show archive"),
                              systemImage: showArchived ? "doc.text" : "archivebox")
                    }
                    .disabled(!store.isPro)
                } label: {
                    Image(systemName: "ellipsis")
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
                            .disabled(!store.isPro)
                            .opacity(store.isPro ? 1 : 0.4)
                            Divider()
                            Button(role: .destructive) {
                                let generator = UIImpactFeedbackGenerator(style: .rigid)
                                generator.impactOccurred()
                                documentPendingDeletion = document
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
    let store = StoreKitManager()
    store.isPro = true
    
    return FilesView()
        .modelContainer(for: Document.self)
        .environmentObject(store)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
