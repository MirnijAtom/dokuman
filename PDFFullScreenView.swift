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
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    PDFFullScreenView(document: Document(
            name: "Meldebescheinigung",
            category: .wohnung,
            versions: [DocumentVersion(fileData: loadPDF(named: "krankenversicherung"), dateAdded: Date())]
        ))
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
