//
//  ContentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import PDFKit
import SwiftData
import SwiftUI

struct ContentView: View {
    
    @State private var showAddDoc = false
    @Query var documents: [Document]
    
    var body: some View {
        ZStack {
            TabView {
                HomeView(documents: documents)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                FavouritesView()
                    .tabItem {
                        Label("Favourites", systemImage: "star")
                    }
                AddDocumentView()
                    .tabItem {
                        Label("Scanner", systemImage: "document.viewfinder")
                    }
                Text("Item 3")
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
                Text("Item 4")
                    .tabItem {
                        Label("search", systemImage: "magnifyingglass")
                    }
            }
            .accentColor(.cyan)
        }
    }
}

#Preview {
    ContentView()
}
