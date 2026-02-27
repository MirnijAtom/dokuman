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
    @EnvironmentObject var store: StoreKitManager

    @State private var selectedTab: Int = 0
    @State private var showAddOptions = false
    @State private var addEntryPoint: AddDocumentView.EntryPoint?
    @State private var isAppLocked = true
        
    @State private var showWelcomeSheet = false
    @AppStorage("welcomeSheetNotShownYet") private var welcomeSheetNotShownYet = true

    @Query(sort: \Document.name, animation: .default) var documents: [Document]

    // MARK: - Body
    var body: some View {
              
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab) {
                        showAddOptions = true
                    }
                        .ignoresSafeArea()
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
                .sheet(isPresented: $showAddOptions) {
                    AddOptionsSheet { entryPoint in
                        showAddOptions = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            addEntryPoint = entryPoint
                        }
                    }
                    .presentationDetents([.height(330)])
                }
                .sheet(item: $addEntryPoint) { entryPoint in
                    AddDocumentView(entryPoint: entryPoint)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showAddOptions = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 35))
                            .foregroundStyle(.teal)
                            .padding()
                            .glassEffect()
                    }
                    .padding(.bottom, 65)
                    .padding(.trailing, 30)
                }
                .overlay {
                    if isAppLocked {
                        Color.white.opacity(0.95)
                            .ignoresSafeArea()
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.black)
                                    Text("Authenticating...")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                }
                            )
                    }
                }
            
        
        .onAppear {
                authenticate()
        }
        .onChange(of: isAppLocked) {
            welcomeSheet()
        }
        .sheet(isPresented: $showWelcomeSheet) {
            WelcomeSheet()
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
    
    private func welcomeSheet() {
        if welcomeSheetNotShownYet {
            showWelcomeSheet = true
            welcomeSheetNotShownYet = false
        }
    }
}

private struct AddOptionsSheet: View {
    let onSelect: (AddDocumentView.EntryPoint) -> Void

    var body: some View {
        VStack(spacing: 12) {
            addOptionRow(title: "Import from Files", systemImage: "doc", color: .blue, entryPoint: .files)
            addOptionRow(title: "Scan document", systemImage: "document.viewfinder", color: .teal, entryPoint: .scanner)
            addOptionRow(title: "Upload from Photos", systemImage: "photo.on.rectangle", color: .orange, entryPoint: .photos)
            addOptionRow(title: "Add number", systemImage: "numbers", color: .purple, entryPoint: .number)
        }
        .padding()
    }

    @ViewBuilder
    private func addOptionRow(
        title: LocalizedStringKey,
        systemImage: String,
        color: Color,
        entryPoint: AddDocumentView.EntryPoint
    ) -> some View {
        Button {
            onSelect(entryPoint)
        } label: {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(.black)
                    .font(.subheadline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56)
            .glassEffect()
        }
    }
}

// MARK: - Preview
#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    let store = StoreKitManager()
    ContentView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(store)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
