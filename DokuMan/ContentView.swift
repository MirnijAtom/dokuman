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

// MARK: - ContentView

/// The main tab view for the DokuMan app, containing Home, Files, Numbers, and Account tabs, plus a floating add button.
struct ContentView: View {
    // MARK: - State & Queries
    @EnvironmentObject var purchaseManager: PurchaseManager

    @State private var selectedTab: Int = 0
    @State private var showAddDoc = false
    @State private var isAppLocked = true

    @Query(sort: \Document.name, animation: .default) var documents: [Document]

    // MARK: - Body
    var body: some View {
        ZStack {
            if isAppLocked {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            Text("Authenticating...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    )
            } else {
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
                .id(purchaseManager.hasProAccess)
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
        .onAppear {
            authenticate()
        }
    }

    // MARK: - Face ID / Touch ID
    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock DokuMan"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    self.isAppLocked = !success
                }
            }
        } else {
            // If no biometrics available, unlock by default (or you can add passcode fallback)
            isAppLocked = false
        }
    }
}

// MARK: - Preview
#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    let purchaseManager = PurchaseManager()
    ContentView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(purchaseManager)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
