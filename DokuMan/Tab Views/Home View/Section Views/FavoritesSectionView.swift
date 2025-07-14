//
//  FavoritesSectionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

// MARK: - FavoritesSectionView

/// Displays a horizontal scrollable list of favorite documents, with context menu actions for sharing, archiving, and deleting.
struct FavoritesSectionView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    /// A4 size in points (scaled for preview)
    let a4Size = CGSize(width: 132, height: 187)
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false // (Unused, could be removed)
    /// All non-archived documents, sorted by name.
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]

    // MARK: - Body
    var body: some View {
        let favorites = documents.filter { $0.isFavorite }
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                Text(LocalizedStringKey("Favorites"))
            }
            .font(.headline)
            .padding(.horizontal)
            if favorites.isEmpty {
                HStack {
                    Text(LocalizedStringKey("Add your first number"))
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 150)
                        .padding()
                        .padding(.trailing, 15)
                        .padding(.leading, 10)
                    Image("emptyFavoritesIcon")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .padding(.trailing, 10)
                        .frame(width: 180, height: 100)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(favorites) { document in
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                selectedDocument = document
                                fullScreenIsPresented = true
                            } label: {
                                PDFPreview(data: document.versions.first!.fileData)
                                    .scaleEffect(1.03)
                                    .frame(width: a4Size.width, height: a4Size.height)
                                    .clipped()
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                                    )
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                                    .contextMenu {
                                        Button {
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                            // Share logic: open PDF in share sheet
                                            if let url = exportTempURL(for: document) {
                                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                                   let window = windowScene.windows.first {
                                                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                                    window.rootViewController?.present(activityVC, animated: true, completion: nil)
                                                }
                                            }
                                        } label: {
                                            Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up")
                                        }
                                        Button {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            toggleFavorites(document, modelContext: modelContext)
                                        } label: {
                                            Label(LocalizedStringKey(document.isFavorite ? "Remove from favorites" : "Add to favorites"), systemImage: document.isFavorite ? "star.slash" : "star")
                                        }
                                        Button {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            archiveDocument(document, modelContext: modelContext)
                                        } label: {
                                            Label(LocalizedStringKey(document.isArchived ? "Unarchive" : "Archive"), systemImage: document.isArchived ? "archivebox" : "archivebox")
                                        }
                                        Divider()
                                        Button(role: .destructive) {
                                            let generator = UIImpactFeedbackGenerator(style: .rigid)
                                            generator.impactOccurred()
                                            deleteDocument(document, modelContext: modelContext)
                                        } label: {
                                            Label(LocalizedStringKey("Delete"), systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(5)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxHeight: 226)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(27)
        .fullScreenCover(item: $selectedDocument) { document in
            PDFFullScreenView(document: document)
        }
    }

    // MARK: - Helpers
    /// Exports a single document as a temporary PDF URL for sharing.
    func exportTempURL(for document: Document) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(document.name).appendingPathExtension("pdf")
        do {
            try document.versions.first!.fileData.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to write PDF to temp: \(error)")
            return nil
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    FavoritesSectionView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
//        .onAppear {
//            // Create a mock document container
//            let container = try! ModelContainer(for: Document.self)
//            let context = container.mainContext
//
//            // Add mock documents to the container for preview
//            let filenames = [
//                "krankenversicherung",
//                "lebenslauf",
//                "meldebeschainigung",
//                "portfolio",
//                "versicherung"
//            ]
//
//            // Insert mock documents
//            for name in filenames {
//                if let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
//                   let data = try? Data(contentsOf: url) {
//                    let version = DocumentVersion(fileData: data, dateAdded: Date())
//                    let doc = Document(name: name.capitalized, isFavorite: true, isArchived: false, category: .wohnung, versions: [version])
//                    context.insert(doc)
//                }
//            }
//        }
}
