//
//  DocumentUtils.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

// MARK: - Document Utilities

/// Adds mockup PDF files to the model context for preview or demo purposes.
/// - Parameter modelContext: The SwiftData model context to insert documents into.
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

// MARK: - Preview Helpers

/// Loads a PDF file from the app bundle for use in previews.
/// - Parameter name: The name of the PDF file (without extension).
/// - Returns: The PDF file data, or empty Data if not found.
func loadPDF(named name: String) -> Data {
    guard let url = Bundle.main.url(forResource: name, withExtension: "pdf"),
          let data = try? Data(contentsOf: url) else {
        return Data()
    }
    return data
}

// MARK: - Document Actions

/// Archives or unarchives a document, and removes it from favorites.
/// - Parameters:
///   - document: The document to archive/unarchive.
///   - modelContext: The SwiftData model context.
func archiveDocument(_ document: Document, modelContext: ModelContext) {
    document.isFavorite = false
    document.isArchived.toggle()
    try? modelContext.save()
}

/// Deletes a document from the model context.
/// - Parameters:
///   - document: The document to delete.
///   - modelContext: The SwiftData model context.
func deleteDocument(_ document: Document, modelContext: ModelContext) {
    modelContext.delete(document)
    try? modelContext.save()
}

/// Toggles the favorite status of a document.
/// - Parameters:
///   - document: The document to toggle favorite status.
///   - modelContext: The SwiftData model context.
func toggleFavorites(_ document: Document, modelContext: ModelContext) {
    document.isFavorite.toggle()
    try? modelContext.save()
}
