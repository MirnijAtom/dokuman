//
//  PDFFullScreenView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 17.04.25.
//

import SwiftUI

// MARK: - PDFFullScreenView

/// Displays a PDF document in full screen, with sharing and dismiss options.
struct PDFFullScreenView: View {
    // MARK: - Environment & State
    @Environment(\.dismiss) var dismiss
    /// The document to display in full screen.
    var document: Document
    @State private var isSharing = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                PDFPreview(data: document.versions.first!.fileData)
                    .frame(maxWidth: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSharing = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "arrow.backward")
                    }
                }
            }
            .sheet(isPresented: $isSharing) {
                if let url = exportTempURL() {
                    ShareSheet(activityItems: [url])
                } else {
                    Text("Error sharing PDF.")
                }
            }
        }
    }

    // MARK: - Helpers
    /// Exports the current document as a temporary PDF URL for sharing.
    func exportTempURL() -> URL? {
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
    PDFFullScreenView(document: Document(
            name: "Krankenversicherung",
            category: .versicherung,
            versions: [DocumentVersion(fileData: loadPDF(named: "krankenversicherung"), dateAdded: Date())]
        ))
        .modelContainer(for: Document.self)
}
