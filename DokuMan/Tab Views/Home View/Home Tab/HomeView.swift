//
//  HomeView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

// MARK: - HomeView

/// The main home screen, showing favorites, categories, and numbers sections.
struct HomeView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var store: StoreKitManager
    @Query(sort: \Number.date) var numbers: [Number]
    @State private var showDocumentsView = false
    @State private var showNumbersView = false
    @State private var showGetPro = false
    let onAddTap: () -> Void
    let onNumbersEditingChange: (Bool) -> Void
    
    // MARK: - Body
    var body: some View {
        List {
            Section("Favorites") {
                FavoritesSectionView()
            }

            Section("Documents") {
                CategoriesSectionView(
                    onAddTap: onAddTap,
                    onSeeAll: { showDocumentsView = true }
                )
            }

            Section("Numbers") {
                NumbersSectionView()
                Button(LocalizedStringKey(numbers.isEmpty ? "Add number" : "See all")) {
                    showNumbersView = true
                }
                .font(.headline)
                .foregroundStyle(.teal)
                .frame(maxWidth: .infinity, minHeight: 56)
                .glassEffect()
                .listRowSeparator(.hidden, edges: .top)
            }
        }
        .safeAreaPadding(.bottom, 92)
        .listStyle(.insetGrouped)
        .toolbar {
            if !store.isPro {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Get Pro") {
                        showGetPro = true
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AccountView()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .navigationDestination(isPresented: $showDocumentsView) {
            FilesView()
        }
        .navigationDestination(isPresented: $showNumbersView) {
            NumbersEditView(onEditingStateChange: onNumbersEditingChange)
        }
        .fullScreenCover(isPresented: $showGetPro) {
            NavigationStack {
                SubscriptionView()
            }
        }
        .onAppear {
            normalizeLegacyNumberCategories()
        }
    }

    private func normalizeLegacyNumberCategories() {
        var changed = false
        for number in numbers where NumberCategory(rawValue: number.categoryRawValue) == nil {
            number.category = .other
            changed = true
        }
        if changed {
            try? modelContext.save()
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    let container = makeHomePreviewContainer()
    HomeView(onAddTap: { }, onNumbersEditingChange: { _ in })
        .modelContainer(container)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environmentObject(StoreKitManager())
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}

@MainActor
private func makeHomePreviewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Document.self, Number.self, configurations: config)

    // Seed preview data
    let previewDocs: [Document] = [
        Document(
            name: "Meldebescheinigung",
            category: .wohnung,
            versions: [DocumentVersion(fileData: loadPDF(named: "meldebescheinigung"), dateAdded: Date())]
        ),
        Document(
            name: "Versicherungspolice",
            category: .versicherung,
            versions: [DocumentVersion(fileData: loadPDF(named: "krankenversicherung"), dateAdded: Date())]
        ),
        Document(
            name: "Arbeitsvertrag",
            category: .arbeit,
            versions: [DocumentVersion(fileData: loadPDF(named: "lebenslauf"), dateAdded: Date())]
        )
    ]
    previewDocs.forEach { container.mainContext.insert($0) }

    let previewNumbers: [Number] = [
        Number(name: "Steuer-ID", idNumber: "12X1212345", isCompleted: true, category: .personalIDs),
        Number(name: "Krankenversicherung", idNumber: "X123456789", category: .healthInsurance),
        Number(name: "IBAN", idNumber: "DE89 3704 0044 0532 0130 00", category: .financeBanking)
    ]
    previewNumbers.forEach { container.mainContext.insert($0) }

    return container
}
