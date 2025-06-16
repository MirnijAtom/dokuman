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
    @Binding var selectedTab: Int
    
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var category: DocumentCategory = .wohnung
    @State private var data: Data = Data()
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    
    @State private var allCategories = ["Wohnung", "Versicherung", "Visa", "Konto", "Arbeit", "Gesundheit", "Studium", "Fahrzeug", "Interner & Handy", "Mitgliedschaften", "Rechnungen & Quittungen", "Behörden", "Rechtliches", "Familie", "Sonstiges"]
    @State private var filtereSuggestions: [String] = []
    
    @State private var showScanner = false
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    showFileImporter.toggle()
                } label: {
                    Label("Import PDF from files", systemImage: "doc.fill")
                }
                Button {
                    showScanner.toggle()
                } label: {
                    Label("Scan document", systemImage: "document.viewfinder")
                }
                Button {
                    showPhotoPicker.toggle()
                } label: {
                    Label("Upload from Photos", systemImage: "photo.on.rectangle")
                }
            }
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
                    Button("Save") {
                        saveDocument()
                    }
                }
                Section {
                    if !data.isEmpty {
                        Text("Document scanned and saved")
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showScanner.toggle()
                    } label: {
                        Label("Scan", systemImage: "document.viewfinder")
                    }
                    
                    Button {
                        showPhotoPicker.toggle()
                    } label: {
                        Label("Photos", systemImage: "photo.on.rectangle")
                    }

                    Button {
                        showFileImporter.toggle()
                    } label: {
                        Label("Import PDF", systemImage: "doc.fill")
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
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker { images in
                    if let first = images.first {
                        data = imageToPDF(image: first)
                    }
                }
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource() else {
                        print("No permission to access file")
                        return
                    }

                    defer { url.stopAccessingSecurityScopedResource() }

                    do {
                        let fileData = try Data(contentsOf: url)
                        data = fileData
                    } catch {
                        print("Error reading file: \(error)")
                    }

                case .failure(let error):
                    print("Failed to import PDF: \(error)")
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
        print("Saved: \(newDocument.name)")
        data = Data()
        name = ""
        selectedTab = 0
        dismiss()
    }
}



#Preview {
    AddDocumentView(selectedTab: .constant(1))
        .modelContainer(for: Document.self)
}
