//
//  PDFPreview.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import PDFKit
import SwiftUI

struct PDFPreview: UIViewRepresentable {
    let data: Data
    
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
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update background color when color scheme changes
        uiView.backgroundColor = UIColor.systemBackground
    }
}
