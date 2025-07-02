//
//  PDFPreview.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import PDFKit
import SwiftUI

// MARK: - PDFPreview

/// A SwiftUI view that displays a PDF from Data using PDFKit.
struct PDFPreview: UIViewRepresentable {
    /// The PDF data to display.
    let data: Data
    
    /// Creates the PDFView and loads the PDF data.
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)
        pdfView.backgroundColor = UIColor.systemBackground
        return pdfView
    }
    
    /// Updates the PDFView when the environment changes (e.g., color scheme).
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update background color when color scheme changes
        uiView.backgroundColor = UIColor.systemBackground
    }
}
