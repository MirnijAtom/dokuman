//
//  addDocumentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct AddDocumentView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var category: DocumentCategory = .wohnung
    @State private var data: Data = Data()
    
    @State private var allCategories = ["Wohnung", "Versicherung", "Visa", "Konto", "Arbeit", "Gesundheit", "Studium", "Fahrzeug", "Interner & Handy", "Mitgliedschaften", "Rechnungen & Quittungen", "Behörden", "Rechtliches", "Familie", "Sonstiges"]
    @State private var filtereSuggestions: [String] = []
    
    @State private var showScanner = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Document name", text: $name)
                    Menu {
                        ForEach(DocumentCategory.allCases, id: \.self) { cat in
                            Button {
                                category = cat
                            } label: {
                                HStack {
                                    Label(cat.label, systemImage: cat.icon)
                                    Text(cat.label)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(category.label)
                                .foregroundColor(.primary)
                            ZStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 30, height: 30)
                                Image(systemName: category.icon)
                                    .foregroundColor(.white)
                            }
                            
                        }
                    }
                }
                Section {
                    Button("Save", action: { saveDocument() })
                }
                Section {
                    if !data.isEmpty {
                        Text("Document scanned and saved")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showScanner.toggle()
                    } label: {
                        Label("Scan", systemImage: "document.viewfinder")
                    }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                DocumentScanner { images in
                    if let image = images.first {
                        data = imageToPDF(image: image)
                    }
                }
            }
        }
    }
    func imageToPDF(image: UIImage) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size), format: format)
        return renderer.pdfData { context in
            context.beginPage()
            image.draw(at: .zero)
        }
    }
    
    func saveDocument() {
        let newDocumentVersion = DocumentVersion(fileData: data, dateAdded: Date())
        let newDocument = Document(name: name, category: category, versions: [newDocumentVersion])
        modelContext.insert(newDocument)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddDocumentView()
}
