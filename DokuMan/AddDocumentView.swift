//
//  addDocumentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct AddDocumentView: View {
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var category: String = ""
    @State private var data: Data = Data()
    
    @State private var allCategories = ["Wohnung", "Versicherung", "Visa", "Konto", "Arbeit", "Gesundheit", "Studium", "Fahrzeug", "Interner & Handy", "Mitgliedschaften", "Rechnungen & Quittungen", "Behörden", "Rechtliches", "Familie", "Sonstiges"]
    @State private var filtereSuggestions: [String] = []
    
    @State private var showScanner = true
    var body: some View {
        NavigationStack {
            Form {
                TextField("Document name", text: $name)
                TextField("Category", text: $category)
                    .onChange(of: category) { oldValue, newValue in
                        filtereSuggestions = allCategories.filter {
                            $0.lowercased().hasPrefix(newValue.lowercased()) && !newValue.isEmpty
                        }
                    }
                ForEach(filtereSuggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .onTapGesture {
                            category = suggestion
                            filtereSuggestions = []
                        }
                }
                if !data.isEmpty {
                    Text("Document scanned and saved")
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
}

#Preview {
    AddDocumentView()
}
