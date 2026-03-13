//
//  AddDocumentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftData
import SwiftUI

// MARK: - View Extension

/// Adds a consistent style to document-related buttons.
extension View {
    func addDocumentButtonStyle() -> some View {
        self
            .frame(width: 30)
            .padding(.trailing, 5)
    }
}

// MARK: - AddDocumentView

/// A view for adding a new document, including import, scan, photo, and manual entry.
struct AddDocumentView: View {
    enum EntryPoint: String, Identifiable {
        case files
        case scanner
        case photos
        case number

        var id: String { rawValue }
    }

    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var store: StoreKitManager
    @Query var documents: [Document]
    @Query var numbers: [Number]
    @FocusState private var nameFieldIsFocused: Bool
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var category: DocumentCategory = .wohnung
    @State private var data: Data = Data()
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var showScanner = false
    @State private var showNumbersEdit = false
    @State private var showSubscription = false
    @State private var didHandleEntryPoint = false
    @State private var allCategories = [
        "Wohnung", "Versicherung", "Visa", "Konto", "Arbeit", "Gesundheit", "Studium", "Fahrzeug", "Interner & Handy", "Mitgliedschaften", "Rechnungen & Quittungen", "Behörden", "Rechtliches", "Familie", "Sonstiges"
    ]
    let entryPoint: EntryPoint?

    init(entryPoint: EntryPoint? = nil) {
        self.entryPoint = entryPoint
    }
    
    private var isQuickEntry: Bool {
        entryPoint != nil
    }
    
    private func dismissQuickEntryIfNeeded() {
        if isQuickEntry, data.isEmpty {
            dismiss()
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            if data.isEmpty {
                if isQuickEntry {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Opening...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Button {
                            if documents.count < 5 || store.isPro {
                                showFileImporter.toggle()
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            } else {
                                showSubscription = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc")
                                    .addDocumentButtonStyle()
                                    .foregroundColor(.blue)
                                Text(LocalizedStringKey("Import from Files"))
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        Button {
                            if documents.count < 5 || store.isPro {
                            showScanner.toggle()
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            } else {
                                showSubscription = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "document.viewfinder")
                                    .addDocumentButtonStyle()
                                    .foregroundColor(.teal)
                                Text(LocalizedStringKey("Scan document"))
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        Button {
                            if documents.count < 5 || store.isPro {
                            showPhotoPicker.toggle()
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            } else {
                                showSubscription = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .addDocumentButtonStyle()
                                    .foregroundColor(.orange)
                                Text(LocalizedStringKey("Upload from Photos"))
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        Button {
                            if numbers.count < 5 || store.isPro {
                            showNumbersEdit.toggle()
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            } else {
                                showSubscription = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "numbers")
                                    .addDocumentButtonStyle()
                                    .foregroundColor(.purple)
                                Text(LocalizedStringKey("Add number"))
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                // Edit name, category and save
                Form {
                    Section {
                        TextField(LocalizedStringKey("Document name"), text: $name)
                            .focused($nameFieldIsFocused)
                        Menu {
                            ForEach(DocumentCategory.allCases, id: \.self) { cat in
                                Button {
                                    category = cat
                                } label: {
                                    HStack {
                                        Label(cat.label, systemImage: cat.icon)
                                        Text(cat.label)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(category.label)
                                    .foregroundColor(.primary)
                                ZStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 30, height: 30)
                                    Image(systemName: category.icon)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    Section {
                        HStack {
                            Spacer()
                            Button(LocalizedStringKey("Save")) {
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                saveDocument()
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .id(languageSettings.locale.identifier)
        .fullScreenCover(isPresented: $showScanner, onDismiss: {
            if isQuickEntry, data.isEmpty {
                dismiss()
            }
        }) {
            DocumentScanner { images in
                if images.isEmpty, isQuickEntry {
                    dismiss()
                    return
                }
                print("[Scanner] Number of images received: \(images.count)")
                let pdfData = imagesToPDF(images: images)
                print("[Scanner] PDF data size: \(pdfData.count) bytes")
                data = pdfData
                nameFieldIsFocused = true
            }
        }
        .sheet(isPresented: $showPhotoPicker, onDismiss: {
            if isQuickEntry, data.isEmpty {
                dismiss()
            }
        }) {
            PhotoPicker { images in
                if let first = images.first {
                    data = imageToPDF(image: first)
                    nameFieldIsFocused = true
                } else if isQuickEntry {
                    dismiss()
                }
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    print("No permission to access file")
                    dismissQuickEntryIfNeeded()
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let fileData = try Data(contentsOf: url)
                    data = fileData
                    nameFieldIsFocused = true
                } catch {
                    print("Error reading file: \(error)")
                    let errorGenerator = UINotificationFeedbackGenerator()
                    errorGenerator.notificationOccurred(.error)
                    dismissQuickEntryIfNeeded()
                }
            case .failure(let error):
                print("Failed to import PDF: \(error)")
                let errorGenerator = UINotificationFeedbackGenerator()
                errorGenerator.notificationOccurred(.error)
                dismissQuickEntryIfNeeded()
            }
        }
        .sheet(isPresented: $showNumbersEdit) {
            NumbersEditView()
        }
        .onAppear {
            guard let entryPoint, !didHandleEntryPoint else { return }
            didHandleEntryPoint = true
            switch entryPoint {
            case .files:
                if documents.count < 5 || store.isPro { showFileImporter = true } else { showSubscription = true }
            case .scanner:
                if documents.count < 5 || store.isPro { showScanner = true } else { showSubscription = true }
            case .photos:
                if documents.count < 5 || store.isPro { showPhotoPicker = true } else { showSubscription = true }
            case .number:
                if numbers.count < 5 || store.isPro { showNumbersEdit = true } else { showSubscription = true }
            }
        }
        .onChange(of: showNumbersEdit) { _, isShown in
            if isQuickEntry, entryPoint == .number, !isShown {
                dismiss()
            }
        }
        .onChange(of: showFileImporter) { _, isShown in
            if !isShown {
                dismissQuickEntryIfNeeded()
            }
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }

    // MARK: - PDF Helpers
    /// Converts a single UIImage to PDF data.
    func imageToPDF(image: UIImage) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size), format: format)
        return renderer.pdfData { context in
            context.beginPage()
            image.draw(at: .zero)
        }
    }
    /// Converts an array of UIImages to a single PDF data.
    func imagesToPDF(images: [UIImage]) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: images[0].size), format: format)
        return renderer.pdfData { context in
            for (index, image) in images.enumerated() {
                print("[PDF] Adding page \(index + 1) with size: \(image.size)")
                context.beginPage()
                image.draw(at: .zero)
            }
        }
    }
    /// Saves the current document to the model context.
    func saveDocument() {
        let newDocumentVersion = DocumentVersion(fileData: data, dateAdded: Date())
        let newDocument = Document(name: name, category: category, versions: [newDocumentVersion])
        modelContext.insert(newDocument)
        try? modelContext.save()
        ReviewRequester.recordDocumentSaved()
        print("Saved: \(newDocument.name)")
        data = Data()
        name = ""
        dismiss()
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    AddDocumentView()
        .modelContainer(for: Document.self)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
