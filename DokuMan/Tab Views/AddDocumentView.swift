//
//  addDocumentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import PhotosUI
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
                    if let fileData = try? Data(contentsOf: url) {
                        data = fileData
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

struct PhotoPicker: UIViewControllerRepresentable {
    var onComplete: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onComplete: ([UIImage]) -> Void
        
        init(onComplete: @escaping ([UIImage]) -> Void) {
            self.onComplete = onComplete // Capturing the closure explicitly
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            let group = DispatchGroup()
            var images: [UIImage] = []
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, _ in
                    if let image = reading as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.onComplete(images) // Ensure it's self.onComplete to capture correctly
            }
        }
    }
}

#Preview {
    AddDocumentView(selectedTab: .constant(1))
        .modelContainer(for: Document.self)
}
