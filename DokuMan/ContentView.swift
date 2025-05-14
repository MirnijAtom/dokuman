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
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                
                FavoritesView()
                    .tabItem {
                        Label("Files", systemImage: "folder")
                    }
                    .tag(1)
                
                AddDocumentView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Scanner", systemImage: "document.viewfinder")
                    }
                    .tag(3)
                
                ArchiveView()
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tag(4)
                
                Text("Item 4")
                    .tabItem {
                        Label("Account", systemImage: "person")
                    }
                    .tag(5)
            }
            .accentColor(Color("AppTeal"))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Document.self)
}
