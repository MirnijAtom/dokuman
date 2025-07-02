//
//  DocumentListView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 17.04.25.
//

import SwiftUI

struct DocumentListView: View {
    var title: String
    var documents: [Document]
    @State private var fullScreenIsPresented = false
    
    @State private var listView = false
    @State private var selectedDocument: Document? = nil
    
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
                    }
                    .navigationTitle(title)
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
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .sheet(item: $selectedDocument) { document in
                    PDFFullScreenView(document: document)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        listView.toggle()
                    } label: {
                        
                        listView ? Label("Grid View", systemImage: "square.grid.2x2") : Label("List View", systemImage: "list.bullet")
                    }
                }
            }
            .navigationTitle(title)
        }

    }
}

func loadPDF(named name: String) -> Data {
    guard let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
          let data = try? Data(contentsOf: url) else {
        return Data()
    }
    return data
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
                            name: "Krankenversicherung",
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
