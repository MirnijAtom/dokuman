//
//  HomeView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    
    // A4 size in points (595 x 842)
    let a4Size = CGSize(width: 132, height: 187)
    
    @State private var selectedDocument: Document? = nil
    @State private var fullScreenIsPresented = false
    
    
    @Query var numbers: [Number]
    var completedNumbers: [Number] {
        numbers
            .filter { $0.isCompleted }
            .filter { !$0.idNumber.isEmpty}
            .sorted { $0.name < $1.name }
    }
    
    @Query(filter: #Predicate<Document> { !$0.isArchived }, sort: \.name) var documents: [Document]
    
    var body: some View {
        let favorites = documents.filter { $0.isFavorite }
        
        NavigationStack {
            
            // Pinned Section
            HStack { Text("Favourites")
                Spacer()
                NavigationLink(destination: FavouritesView()) {
                    Text("See all")
                }
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(favorites) { document in
                        Button(action: {
                            selectedDocument = document
                            fullScreenIsPresented = true
                        }) {
                            PDFPreview(data: document.versions.first!.fileData)
                                .scaleEffect(1.03)
                                .frame(width: a4Size.width, height: a4Size.height)
                                .clipped()
                                .mask(RoundedRectangle(cornerRadius: 5))
                                .shadow(radius: 3)
                            
                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                                .contextMenu {
                                    Button("Favorites toggle") {
                                        toggleFavorites(document, modelContext: modelContext)
                                    }
                                    Button("Archive toggle") {
                                        archiveDocument(document, modelContext: modelContext)
                                    }
                                    Button("Delete", role: .destructive) {
                                        deleteDocument(document, modelContext: modelContext)
                                    }
                                }
                        }
                    }
                    .padding(5)
                }
                .padding(10)
            }
            
            List {
                // Button to add mockup files
                Button("Add mockup files") {
                    addMockupFiles(using: modelContext)
                }
                
                // Categories Section
                Section(header: Text("Categories")) {
                    ForEach(DocumentCategory.allCases, id: \.self) { category in
                        let docsInCategory = documents.filter { $0.category == category }
                        
                        if !docsInCategory.isEmpty {
                            NavigationLink {
                                DocumentListView(title: category.label, documents: docsInCategory)
                            } label: {
                                Label(category.label, systemImage: category.icon)
                                    .foregroundColor(category.color)
                            }
                        }
                    }
                }
                
                Section(header: Text("Numbers")) {
                    if completedNumbers.isEmpty {
                        NavigationLink {
                            NumbersEditView()
                        } label: {
                            Text("Add your first number")
                        }
                    } else {
                        ForEach(completedNumbers) { number in
                            HStack {
                                Text(number.name)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Divider()
                                
                                Text(number.idNumber)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                
                // Debug Count
                Text("Documents count: \(documents.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Home")
            .fullScreenCover(item: $selectedDocument) { document in
                PDFFullScreenView(document: document)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Document.self)
}
