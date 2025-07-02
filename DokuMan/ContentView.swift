//
//  ContentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import LocalAuthentication
import PDFKit
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showAddDoc = false
    @Query(sort: \Document.name, animation: .default) var documents: [Document]
    
    @State private var isUnlocked = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            FilesView()
                .tabItem {
                    Label("Files", systemImage: selectedTab == 1 ? "folder.fill" : "folder")
                }
                .tag(1)

            NumbersEditView()
                .tabItem {
                    Label("Numbers", systemImage: selectedTab == 2 ? "numbers.rectangle.fill" : "numbers.rectangle")
                }
                .tag(2)

            AccountView()
                .tabItem {
                    Label("Account", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(.teal)

        .sheet(isPresented: $showAddDoc) {
            AddDocumentView()
                .presentationDetents([.large])
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAddDoc = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 35))
                    .foregroundStyle(.teal)
                    .frame(width: 60, height: 60)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 7)
            }
            .padding(.bottom, 80)
            .padding(.trailing, 24)
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    ContentView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
