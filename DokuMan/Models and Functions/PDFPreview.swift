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
        pdfView.displayMode = .singlePage
        pdfView.backgroundColor = .white
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
