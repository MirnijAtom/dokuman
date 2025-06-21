//
//  NumbersEditView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 05.05.25.
//

import SwiftData
import SwiftUI

extension View {
    func numberTextStyle() -> some View {
        self
            .font(.subheadline)
            .fontWidth(.compressed)
            .fontWeight(.light)
            .fontDesign(.monospaced)
    }
}

struct NumbersEditView: View {
    @Environment(\.modelContext) var modelContext
    @Query var numbers: [Number]
    
    @FocusState private var focusedField: UUID?
    @FocusState private var nameFocusedField: UUID?
    @State private var editingNumber: Number?
    @State private var nameInputText: String = ""
    @State private var numberInputText: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var copiedID: UUID? = nil
    
    var body: some View {
        NavigationStack {            
            List {
                if numbers.isEmpty && editingNumber == nil {
                    Section {
                        Text("Here you can add your numbers and IDs such as social security number, health insurance number, tax ID etc.")
                    }
                } else {
                    Section(header: Text("Your numbers").numberTextStyle()) {
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
                                    
                                    Text("Copied!")
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
                                
                                TextField("Name", text: $nameInputText)
                                    .autocorrectionDisabled(true)
                                    .focused($nameFocusedField, equals: newNumber.id)
                                    .numberTextStyle()
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                TextField("Type ID", text: $numberInputText)
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
                
                Button("New number") {
                    let newNumber = Number(name: "", idNumber: "", isCompleted: true)
                    editingNumber = newNumber
                    nameFocusedField = newNumber.id
                }
                .font(.subheadline)
                .fontWidth(.compressed)
                .fontWeight(.light)
                .fontDesign(.monospaced)
            }
            
            //        .navigationBarBackButtonHidden(editingNumber != nil)
            //        .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if editingNumber != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", role: .destructive) {
                            editingNumber = nil
                            nameInputText = ""
                            numberInputText = ""
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let trimmedName = nameInputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedNumber = numberInputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if trimmedName.isEmpty {
                                alertMessage = "Name is missing"
                                showAlert = true
                                return
                            }
                            if trimmedNumber.isEmpty {
                                alertMessage = "Number is missing"
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
                            Button("OK", role: .cancel) { }
                        }
                    }
                }
            }
        }

        
        Text("Numbers count: \(numbers.count)")
    }
    
    func deleteNumber(at offsets: IndexSet) {
        for index in offsets {
            let number = numbers[index]
            modelContext.delete(number)
        }
    }
}

#Preview {
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
}
