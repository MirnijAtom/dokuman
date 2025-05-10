//
//  DocumentUtils.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

func addMockupFiles(using modelContext: ModelContext) {
    let fileNames = [
        ("krankenversicherung", DocumentCategory.versicherung),
        ("lebenslauf", DocumentCategory.arbeit),
        ("meldebescheinigung", DocumentCategory.wohnung),
        ("portfolio", DocumentCategory.studium),
        ("versicherung", DocumentCategory.versicherung)
    ]
    
    for (name, category) in fileNames {
        if let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
           let data = try? Data(contentsOf: url) {
            let version = DocumentVersion(fileData: data, dateAdded: Date())
            let document = Document(name: name.capitalized, category: category,  versions: [version])
            document.isFavorite = true
            modelContext.insert(document)
        } else {
            print("missing file \(name).pdf")
        }
    }
    
    try? modelContext.save()
}

// Helper function for preview
func loadPDF(named name: String) -> Data {
    guard let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
          let data = try? Data(contentsOf: url) else {
        return Data()
    }
    return data
}

func archiveDocument(_ document: Document, modelContext: ModelContext) {
    document.isFavorite = false
    document.isArchived.toggle()
    try? modelContext.save()
}

func deleteDocument(_ document: Document, modelContext: ModelContext) {
    modelContext.delete(document)
    try? modelContext.save()
}

func toggleFavorites(_ document: Document, modelContext: ModelContext) {
    document.isFavorite.toggle()
    try? modelContext.save()
}
