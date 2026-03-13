//
//  NumbersEditView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 05.05.25.
//

import SwiftData
import SwiftUI

// MARK: - View Extension

/// Adds a consistent style to number-related text fields and labels.
extension View {
    func numberTextStyle() -> some View {
        self
            .font(.subheadline)
            .fontWidth(.compressed)
            .fontWeight(.light)
            .fontDesign(.monospaced)
    }
}

// MARK: - NumbersEditView

/// A view for adding, editing, and deleting user numbers and IDs (e.g., social security, health insurance).
struct NumbersEditView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Number.date) var numbers: [Number]
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var store: StoreKitManager
    @EnvironmentObject var languageSettings: LanguageSettings
    @State private var showSubscription = false
    @State private var showGetPro = false
    @State private var showAddNumberSheet = false
    @State private var numberToEdit: Number?
    @State private var copiedID: UUID? = nil
    let onEditingStateChange: (Bool) -> Void

    init(onEditingStateChange: @escaping (Bool) -> Void = { _ in }) {
        self.onEditingStateChange = onEditingStateChange
    }

    private var categoriesWithNumbers: [NumberCategory] {
        NumberCategory.allCases.filter { category in
            numbers.contains(where: { $0.category == category })
        }
    }

    private func numbers(in category: NumberCategory) -> [Number] {
        numbers.filter { $0.category == category }
    }

    // MARK: - Body
    var body: some View {
        List {
            if numbers.isEmpty {
                Section {
                    VStack {
                        Image("emptyNumbersIconLong")
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 15)
                            .padding(.horizontal)
                            .frame(height: 100)
                        Text("Here you can add your numbers and IDs such as social security number, health insurance number, tax ID etc.")
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .padding()
                            .padding(.trailing, 30)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(categoriesWithNumbers, id: \.self) { category in
                    Section(header: Text(category.label)) {
                        ForEach(numbers(in: category)) { number in
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(number.name)
                                        .numberTextStyle()
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    ZStack(alignment: .leading) {
                                        Text(number.idNumber)
                                            .numberTextStyle()
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                            .opacity(copiedID == number.id ? 0 : 1)
                                            .animation(.easeInOut, value: copiedID)

                                        Text(LocalizedStringKey("Copied!"))
                                            .numberTextStyle()
                                            .foregroundStyle(.secondary)
                                            .opacity(copiedID == number.id ? 1 : 0)
                                            .animation(.easeInOut, value: copiedID)
                                    }
                                }

                                Spacer()

                                Button {
                                    UIPasteboard.general.string = number.idNumber
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()

                                    copiedID = number.id
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        copiedID = nil
                                    }
                                } label: {
                                    Image(systemName: "document.on.document")
                                        .numberTextStyle()
                                        .foregroundStyle(.primary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    modelContext.delete(number)
                                } label: {
                                    Label(LocalizedStringKey("Delete"), systemImage: "trash")
                                }

                                Button {
                                    numberToEdit = number
                                } label: {
                                    Label(LocalizedStringKey("Edit"), systemImage: "pencil")
                                }
                                .tint(.yellow)
                            }
                        }
                    }
                }
            }

            Button {
                if numbers.count < 5 || store.isPro {
                    showAddNumberSheet = true
                } else {
                    showSubscription = true
                }
            } label: {
                HStack {
                    Spacer()
                    Text(LocalizedStringKey("New number"))
                        .font(.headline)
                    Spacer()
                }
            }
            .font(.headline)
            .foregroundStyle(.teal)
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
        }
        .safeAreaPadding(.bottom, 92)
        .toolbar {
            if !store.isPro {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Get Pro") {
                        showGetPro = true
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
        }
        .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)
        .navigationTitle(LocalizedStringKey("Numbers"))
        .fullScreenCover(isPresented: $showGetPro) {
            NavigationStack {
                SubscriptionView()
            }
        }
        .sheet(isPresented: $showAddNumberSheet) {
            AddNumberSheet { name, idNumber, category in
                let newNumber = Number(name: name, idNumber: idNumber, isCompleted: true, category: category)
                modelContext.insert(newNumber)
            }
        }
        .sheet(item: $numberToEdit) { number in
            EditNumberSheet(number: number)
        }
        .id(languageSettings.locale.identifier)
        .onChange(of: showAddNumberSheet) { _, isEditing in
            onEditingStateChange(isEditing)
        }
        .onChange(of: numberToEdit) { _, editingNumber in
            onEditingStateChange(editingNumber != nil)
        }
        .onAppear {
            normalizeLegacyCategories()
        }
        .onDisappear {
            onEditingStateChange(false)
        }
    }

    // MARK: - Helpers
    /// Deletes numbers in a specific category section.
    func deleteNumber(at offsets: IndexSet, in category: NumberCategory) {
        let categoryNumbers = numbers(in: category)
        for index in offsets {
            let number = categoryNumbers[index]
            modelContext.delete(number)
        }
    }

    /// Ensures pre-category records get the default `.other` category persisted.
    func normalizeLegacyCategories() {
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

private struct EditNumberSheet: View {
    @Environment(\.dismiss) private var dismiss

    let number: Number

    @State private var category: NumberCategory
    @State private var name: String
    @State private var idNumber: String

    init(number: Number) {
        self.number = number
        _category = State(initialValue: number.category)
        _name = State(initialValue: number.name)
        _idNumber = State(initialValue: number.idNumber)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !idNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker(LocalizedStringKey("Category"), selection: $category) {
                    ForEach(NumberCategory.allCases, id: \.self) { category in
                        Label(category.label, systemImage: category.icon).tag(category)
                    }
                }

                TextField(LocalizedStringKey("Name"), text: $name)
                    .autocorrectionDisabled(true)

                TextField(LocalizedStringKey("Type ID"), text: $idNumber)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.allCharacters)
            }
            .navigationTitle(LocalizedStringKey("Edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedStringKey("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        number.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        number.idNumber = idNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                        number.category = category
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

private struct AddNumberSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var category: NumberCategory = .other
    @State private var name: String = ""
    @State private var idNumber: String = ""

    let onSave: (String, String, NumberCategory) -> Void

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !idNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker(LocalizedStringKey("Category"), selection: $category) {
                    ForEach(NumberCategory.allCases, id: \.self) { category in
                        Label(category.label, systemImage: category.icon).tag(category)
                    }
                }

                TextField(LocalizedStringKey("Name"), text: $name)
                    .autocorrectionDisabled(true)

                TextField(LocalizedStringKey("Type ID"), text: $idNumber)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.allCharacters)
            }
            .navigationTitle(LocalizedStringKey("Add number"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedStringKey("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave(
                            name.trimmingCharacters(in: .whitespacesAndNewlines),
                            idNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                            category
                        )
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let store = StoreKitManager()
    let languageSettings = LanguageSettings()
    NavigationStack {
        NumbersEditView(onEditingStateChange: { _ in })
            .modelContainer(makeNumbersPreviewContainer())
            .environmentObject(themeSettings)
            .environmentObject(store)
            .environmentObject(languageSettings)
            .environment(\.locale, languageSettings.locale)
            .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
    }
}

@MainActor
private func makeNumbersPreviewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Number.self, configurations: config)
    let completed = Number(name: "Steuer-ID", idNumber: "12X1212345", isCompleted: true, category: .personalIDs)
    let incomplete = [
        Number(name: "Sozialversicherung", idNumber: "12123456A123", category: .healthInsurance),
        Number(name: "Krankenversicherung", idNumber: "X123456789", category: .healthInsurance)
    ]

    incomplete.forEach { container.mainContext.insert($0) }
    container.mainContext.insert(completed)
    return container
}
