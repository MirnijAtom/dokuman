//
//  NumbersEditView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 05.05.25.
//

import SwiftData
import SwiftUI

struct NumbersEditView: View {
    @Environment(\.modelContext) var modelContext
    @Query var numbers: [Number]
    var completedNumbers: [Number] {
        numbers
            .filter { $0.isCompleted }
            .filter { !$0.idNumber.isEmpty}
            .sorted { $0.name < $1.name }
    }
    var incompleteNumbers: [Number] {
        numbers
            .filter { !$0.isCompleted }
            .sorted { $0.name < $1.name }
    }
    
    @FocusState private var focusedField: UUID?
    @FocusState private var nameFocusedField: UUID?
    @State private var editingNumber: Number?
    @State private var nameInputText: String = ""
    @State private var inputText: String = ""
    
    
    var body: some View {
        List {
            Section(header: Text("filled")) {
                ForEach(completedNumbers) { number in
                    HStack {
                        Text(number.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                        
                        Text(number.idNumber)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .onDelete(perform: deleteCompleted)
                
                if let newNumber = editingNumber {
                    HStack {
                        if newNumber.name.isEmpty {
                            TextField("name", text: $nameInputText)
                                .autocorrectionDisabled(true)
                                .focused($nameFocusedField, equals: newNumber.id)
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(newNumber.name)
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Divider()
                        
                        TextField("Type ID", text: $inputText)
                            .autocorrectionDisabled(true)
                            .focused($focusedField, equals: newNumber.id)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            Section(header: Text("empty")) {
                ForEach(incompleteNumbers) { number in
                    HStack {
                        Text(number.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        Text(numberExample(numberName: number.name))
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                editingNumber = number
                                inputText = number.idNumber
                                nameInputText = number.name
                                number.isCompleted = true
                                focusedField = number.id
                                try? modelContext.save()
                            }
                    }
                }
         }
            Button("New number") {
                    let newNumber = Number(name: "", idNumber: "", isCompleted: true)
                    modelContext.insert(newNumber)
                    editingNumber = newNumber
                    nameFocusedField = newNumber.id
            }
        }
        .onAppear {
            DataManager.loadDefaultNumbersIfNeeded(context: modelContext)
        }
        .toolbar {
            if editingNumber != nil {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !nameInputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

                            if let numberToSave = editingNumber {
                                numberToSave.idNumber = inputText
                                numberToSave.isCompleted = true
                                try? modelContext.save()
                            }
                            editingNumber = nil
                            inputText = ""
                            nameInputText = ""
                            print("Number saved")
                        
                    }
                }
            }
        }
        .overlay(
            Group {
                if let editing = editingNumber {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                let nameTrimmed = nameInputText.trimmingCharacters(in: .whitespaces)
                                let idTrimmed = inputText.trimmingCharacters(in: .whitespaces)

                                if nameTrimmed.isEmpty && idTrimmed.isEmpty {
                                    modelContext.delete(editing)
                                } else {
                                    editing.name = nameTrimmed
                                    editing.idNumber = idTrimmed
                                    editing.isCompleted = idTrimmed.isEmpty ? false : true
                                    try? modelContext.save()
                                }

                                editingNumber = nil
                                inputText = ""
                                nameInputText = ""
                            }
                        }
                }
            }
        )
        
        Text("Numbers count: \(numbers.count)")
    }
    func numberExample(numberName: String) -> String {
        switch numberName {
        case "Sozialversicherung":
            return "12 123456 A 123"
        case "Krankenversicherung":
            return "X123456789"
        case "Steuer-ID":
            return "12X 12 12345"
        case "Rentenversicherung":
            return "12 123456 A 123"
        default:
            return ""
        }
    }
    func deleteCompleted(at offsets: IndexSet) {
        for index in offsets {
            let number = completedNumbers[index]
            modelContext.delete(number)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Number.self, configurations: config)
    
    let completed = Number(name: "Steuer-ID", idNumber: "12X 12 12345", isCompleted: true)
    let incomplete = [
        Number(name: "Sozialversicherung", idNumber: "12 123456 A 123"),
        Number(name: "Krankenversicherung", idNumber: "X123456789")
    ]
    
    for number in incomplete {
        container.mainContext.insert(number)
    }
    container.mainContext.insert(completed)
    
    return NumbersEditView()
        .modelContainer(container)
}
