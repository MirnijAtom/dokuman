//
//  FavoritesSectionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

struct FavoritesSectionView: View {
    @Environment(\.modelContext) var modelContext
    
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 132, height: 187)
    
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false
    
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]

    
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
                        .padding()
                        .padding(.trailing, 30)
                        .foregroundStyle(.secondary)
                    Image("emptyFavoritesIcon")
                        .resizable()
                        .scaledToFit()
                        .padding(.trailing, 30)
                        .frame(height: 100)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(favorites) { document in
                            Button {
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
                                            toggleFavorites(document, modelContext: modelContext)
                                        } label: {
                                            Label(LocalizedStringKey(document.isFavorite ? "Remove from favorites" : "Add to favorites"), systemImage: document.isFavorite ? "star.slash" : "star")
                                        }
                                        Button {
                                            archiveDocument(document, modelContext: modelContext)
                                        } label: {
                                            Label(LocalizedStringKey(document.isArchived ? "Unarchive" : "Archive"), systemImage: document.isArchived ? "archivebox" : "archivebox")
                                        }
                                        Divider()
                                        Button(role: .destructive) {
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
        .frame(minHeight: 226)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(0)

        .fullScreenCover(item: $selectedDocument) { document in
            PDFFullScreenView(document: document)
        }
        
        //Add mockup files
//        Button("Add mockup files") {
//            addMockupFiles(using: modelContext)
//        }
//        .padding()
    }

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
