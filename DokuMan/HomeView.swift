//
//  HomeView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

struct HomeView: View {
    @State private var mockupDocument: Document?
    @State private var mockupDocument2: Document?
    
    var categories = ["Wohnung", "Versicherungen", "Visa"]
    
    var body: some View {
        List {
            Section(header: Text("Pinned")) {
                HStack {
                    GroupBox {
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
                    }
                    GroupBox {
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
                        
                    }
                }
                .padding()
                .onAppear {
                    loadMockupDocument()
                    loadMockupDocument2()
                }
            }
            Section(header: Text("Categories")) {
                ForEach(categories, id: \.self) { Text($0) }
            }
        }
    }
    
    func loadMockupDocument() {
        if let url = Bundle.main.url(forResource: "meldebescheinigung", withExtension: "pdf"),
           let data = try? Data(contentsOf: url) {
            mockupDocument = Document(name: "Meldebescheinigung", category: "Wohnung", versions: [DocumentVersion(fileData: data, dateAdded: Date())])
        }
    }
    
    func loadMockupDocument2() {
        if let url = Bundle.main.url(forResource: "krankenversicherung", withExtension: "pdf"),
           let data = try? Data(contentsOf: url) {
            mockupDocument2 = Document(name: "krankenversicherung", category: "Versicherung", versions: [DocumentVersion(fileData: data, dateAdded: Date())])
        }
    }
}

#Preview {
    HomeView()
}
