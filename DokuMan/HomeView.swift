//
//  HomeView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    
    var documents: [Document]
    @State private var mockupDocument: Document?
    @State private var mockupDocument2: Document?
    
    var categories = ["Wohnung", "Versicherungen", "Visa"]
    
    var body: some View {
        NavigationStack {
            List {
                // ForEach now works with Identifiable Documents
                Section(header: Text("Pinned")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(documents) { document in
                                
                                PDFPreview(data: document.versions.first!.fileData)
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                
                Section(header: Text("Categories")) {
                    ForEach(DocumentCategory.allCases, id: \.self) { category in
                        let docsInCategory = documents.filter { $0.category == category }
                        
                        if !docsInCategory.isEmpty {
                            NavigationLink {
                                DocumentListView(title: category.label, documents: docsInCategory)
                            } label: {
                                Label(category.label, systemImage: category.icon)
                                    .foregroundColor(category.color)
                            }
                        }
                    }
                }
                Text("Documents count: \(documents.count)")
            }
        }
    }
}

func generateDummyPDFData() -> Data {
    let format = UIGraphicsPDFRendererFormat()
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 300, height: 300), format: format)
    
    return renderer.pdfData { context in
        context.beginPage()
        let text = "This is a simulated PDF file."
        text.draw(at: CGPoint(x: 50, y: 50))
    }
}

#Preview {
    HomeView(
        documents: [
            Document(
                name: "Meldebescheinigung",
                category: .wohnung,
                versions: [DocumentVersion(fileData: generateDummyPDFData(), dateAdded: Date())]
            ),
            Document(
                name: "Krankenversicherung",
                category: .versicherung,
                versions: [DocumentVersion(fileData: generateDummyPDFData(), dateAdded: Date())]
            ),
            Document(
                name: "Wohnung Vertrag",
                category: .wohnung,
                versions: [DocumentVersion(fileData: generateDummyPDFData(), dateAdded: Date())]
            ),
            Document(
                name: "Lohnabrechnung März",
                category: .arbeit,
                versions: [DocumentVersion(fileData: generateDummyPDFData(), dateAdded: Date())]
            ),
            Document(
                name: "Steuerbescheid 2023",
                category: .steuern,
                versions: [DocumentVersion(fileData: generateDummyPDFData(), dateAdded: Date())]
            )
        ]
    )
    .modelContainer(for: Document.self)
}
