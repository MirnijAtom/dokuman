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
    @State private var selectedTab: Int = 0
    @State private var showAddDoc = false
    @Query(sort: \Document.name, animation: .default) var documents: [Document]
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(documents: documents)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                FavouritesView()
                    .tabItem {
                        Label("Favourites", systemImage: "star")
                    }
                    .tag(1)
                AddDocumentView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Scanner", systemImage: "document.viewfinder")
                    }
                    .tag(3)
                Text("Item 3")
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tag(4)
                Text("Item 4")
                    .tabItem {
                        Label("search", systemImage: "magnifyingglass")
                    }
                    .tag(5)
            }
            .accentColor(.cyan)
        }
    }
}

#Preview {
    ContentView()
}
