//
//  PDFFullScreenView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 17.04.25.
//

import SwiftUI

struct PDFFullScreenView: View {
    var document: Document
    var body: some View {
        PDFPreview(data: document.versions.first!.fileData)
            .frame(maxWidth: .infinity)
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
