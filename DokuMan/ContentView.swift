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
    
    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                FavouritesView()
                    .tabItem {
                        Label("Favourites", systemImage: "star")
                    }
                Text("nothing")
                    .tabItem {
                        Label("", systemImage: "nothing")
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
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue, Color.purple]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .edgesIgnoringSafeArea(.bottom)
//            )
            
            VStack {
                Spacer()
                Button(action: {
                    print("add document tapped")
                }) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                        .shadow(radius: 10)
                }
//                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
