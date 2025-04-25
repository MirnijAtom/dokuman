//
//  PDFFullScreenView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 17.04.25.
//

import SwiftUI

struct PDFFullScreenView: View {
    @Environment(\.dismiss) var dismiss
    var document: Document
    @State private var isSharing = false
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
    func exportTempURL() -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(document.name)
        do {
            try document.versions.first!.fileData.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to write PDF to temp: \(error)")
            return nil
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

#Preview {
    PDFFullScreenView(document: Document(
            name: "Krankenversicherung",
            category: .versicherung,
            versions: [DocumentVersion(fileData: loadPDF(named: "krankenversicherung"), dateAdded: Date())]
        ))
        .modelContainer(for: Document.self)
}
