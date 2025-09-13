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
    @FocusState private var focusedField: UUID?
    @FocusState private var nameFocusedField: UUID?
    @State private var editingNumber: Number?
    @State private var nameInputText: String = ""
    @State private var numberInputText: String = ""
    @State private var showAlert = false
    @State private var showSubscription = false
    @State private var alertMessage = ""
    @State private var copiedID: UUID? = nil
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
        List {
            if numbers.isEmpty && editingNumber == nil {
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
                Section(header: Text(LocalizedStringKey("Your numbers")).numberTextStyle()) {
                    ForEach(numbers) { number in
                        HStack {
                            Text(number.name)
                                .numberTextStyle()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            ZStack {
                                Text(number.idNumber)
                                    .numberTextStyle()
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(copiedID == number.id ? 0 : 1)
                                    .animation(.easeInOut, value: copiedID)
                                Text(LocalizedStringKey("Copied!"))
                                    .numberTextStyle()
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(copiedID == number.id ? 1 : 0)
                                    .animation(.easeInOut, value: copiedID)
                            }
                            Divider()
                            Button {
                                UIPasteboard.general.string = number.idNumber
                                let generator = UIImpactFeedbackGenerator()
                                generator.impactOccurred()
                                copiedID = number.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    copiedID = nil
                                }
                            } label: {
                                Image(systemName: "document.on.document")
                                    .numberTextStyle()
                                    .foregroundStyle(Color.secondary)
                                    .padding(.leading, 4)
                            }
                        }
                    }
                    .onDelete(perform: deleteNumber)
                    if let newNumber = editingNumber {
                        HStack {
                            TextField(LocalizedStringKey("Name"), text: $nameInputText)
                                .autocorrectionDisabled(true)
                                .focused($nameFocusedField, equals: newNumber.id)
                                .numberTextStyle()
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            TextField(LocalizedStringKey("Type ID"), text: $numberInputText)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.allCharacters)
                                .focused($focusedField, equals: newNumber.id)
                                .numberTextStyle()
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            Image(systemName: "document.on.document")
                                .font(.subheadline)
                                .foregroundStyle(Color.clear)
                                .padding(.leading, 4)
                        }
                    }
                }
            }
            Button {
                if numbers.count < 5 || store.isPro {
                    let newNumber = Number(name: "", idNumber: "", isCompleted: true)
                    editingNumber = newNumber
                    nameFocusedField = newNumber.id
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
            .font(.subheadline)
            .fontWidth(.compressed)
            .fontWeight(.light)
            .fontDesign(.monospaced)
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
        }
        .toolbar {
            if editingNumber != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedStringKey("Cancel"), role: .destructive) {
                        editingNumber = nil
                        nameInputText = ""
                        numberInputText = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("Save")) {
                        let trimmedName = nameInputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedNumber = numberInputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedName.isEmpty {
                            alertMessage = NSLocalizedString("Name is missing", comment: "")
                            showAlert = true
                            return
                        }
                        if trimmedNumber.isEmpty {
                            alertMessage = NSLocalizedString("Number is missing", comment: "")
                            showAlert = true
                            return
                        }
                        if let numberToAdd = editingNumber {
                            numberToAdd.name = nameInputText.trimmingCharacters(in: .whitespaces)
                            numberToAdd.idNumber = numberInputText.trimmingCharacters(in: .whitespaces)
                            numberToAdd.isCompleted = true
                            modelContext.insert(numberToAdd)
                            editingNumber = nil
                            nameInputText = ""
                            numberInputText = ""
                        }
                    }
                    .alert(alertMessage, isPresented: $showAlert) {
                        Button(LocalizedStringKey("OK"), role: .cancel) { }
                    }
                }
            }
        }
        .toolbarColorScheme(themeSettings.isDarkMode ? .dark : .light)
        .navigationTitle(LocalizedStringKey("Numbers"))
        .id(languageSettings.locale.identifier)
    }
}
    // MARK: - Helpers
    /// Deletes a number at the specified offsets from the model context.
    func deleteNumber(at offsets: IndexSet) {
        for index in offsets {
            let number = numbers[index]
            modelContext.delete(number)
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let store = StoreKitManager()
    let languageSettings = LanguageSettings()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Number.self, configurations: config)
    let completed = Number(name: "Steuer-ID", idNumber: "12X1212345", isCompleted: true)
    let incomplete = [
        Number(name: "Sozialversicherung", idNumber: "12123456A123"),
        Number(name: "Krankenversicherung", idNumber: "X123456789")
    ]
    for number in incomplete {
        container.mainContext.insert(number)
    }
    container.mainContext.insert(completed)
    return NumbersEditView()
        .modelContainer(container)
        .environmentObject(themeSettings)
        .environmentObject(store)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
