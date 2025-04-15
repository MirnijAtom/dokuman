//
//  FavouritesView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

struct FavouritesView: View {
    @State private var mockupDocument: Document?
    @State private var mockupDocument2: Document?
    
    var categories = ["Wohnung", "Versicherungen", "Visa"]
    
    var body: some View {
        
        
        VStack {
            HStack {
                GroupBox {
                    ZStack {
                        if let document = mockupDocument {
                            VStack {
                                PDFPreview(data: document.versions.first!.fileData)
                                    .frame(height: 100)
                                    .cornerRadius(8)
                                Text(document.name)
                            }
                        } else {
                            Text("No document loaded")
                                .foregroundColor(.gray)
                        }
                        StarView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                    .frame(width: 150, height: 150)
                }
                GroupBox {
                    ZStack {
                        if let document = mockupDocument2 {
                            VStack {
                                PDFPreview(data: document.versions.first!.fileData)
                                    .frame(height: 100)
                                    .cornerRadius(8)
                                Text(document.name)
                            }
                        } else {
                            Text("No document loaded")
                                .foregroundColor(.gray)
                        }
                        StarView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                    .frame(width: 150, height: 150)

                }
            }
            .padding(.top, 70)
            .padding(.horizontal)
            .onAppear {
                loadMockupDocument()
                loadMockupDocument2()
            }
            Spacer()
        }
    }
    
    
    
    
    func loadMockupDocument() {
        if let url = Bundle.main.url(forResource: "meldebescheinigung", withExtension: "pdf"),
           let data = try? Data(contentsOf: url) {
            let category: DocumentCategory = .wohnung
            mockupDocument = Document(name: "Meldebescheinigung", category: category, versions: [DocumentVersion(fileData: data, dateAdded: Date())])
        }
    }
    
    func loadMockupDocument2() {
        if let url = Bundle.main.url(forResource: "krankenversicherung", withExtension: "pdf"),
           let data = try? Data(contentsOf: url) {
            let category: DocumentCategory = .versicherung
            mockupDocument2 = Document(name: "krankenversicherung", category: category, versions: [DocumentVersion(fileData: data, dateAdded: Date())])
        }
    }
}

#Preview {
    FavouritesView()
}
