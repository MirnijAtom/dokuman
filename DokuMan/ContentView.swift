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

/// The main root view for the DokuMan app, with Home as entry point and a floating add button.
struct ContentView: View {
    // MARK: - State & Queries
    @State private var showAddOptions = false
    @State private var addEntryPoint: AddDocumentView.EntryPoint?
    @State private var showNumbersFromAddSheet = false
    @State private var hideFloatingAddButton = false
    @State private var isAppLocked = true
        
    @State private var showWelcomeSheet = false
    @AppStorage("welcomeSheetNotShownYet") private var welcomeSheetNotShownYet = true

    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationStack {
                HomeView {
                    showAddOptions = true
                } onNumbersEditingChange: { isEditing in
                    hideFloatingAddButton = isEditing
                }
                .navigationDestination(isPresented: $showNumbersFromAddSheet) {
                    NumbersEditView { isEditing in
                        hideFloatingAddButton = isEditing
                    }
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !hideFloatingAddButton {
                        Button(action: {
                            showAddOptions = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .glassEffect(.regular.tint(.cyan))
//                                .background(
//                                    Circle()
//                                        .fill(Color.cyan)
//                                )
                        }
                        .padding(.trailing, 32)
                        .padding(.bottom, 2)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddOptions) {
            AddOptionsSheet { entryPoint in
                showAddOptions = false
                if entryPoint == .number {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showNumbersFromAddSheet = true
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        addEntryPoint = entryPoint
                    }
                }
            }
            .presentationDetents([.height(330)])
        }
        .sheet(item: $addEntryPoint) { entryPoint in
            AddDocumentView(entryPoint: entryPoint)
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
                    .foregroundStyle(.primary)
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
        .modelContainer(for: [Document.self, Number.self])
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(store)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
