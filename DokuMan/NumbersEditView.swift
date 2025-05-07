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
    
    @State private var editingNumber: Number?
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
                
                if let newNumber = editingNumber {
                    HStack {
                        Text(newNumber.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        TextField("Type ID", text: $inputText)
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
                        
                        Text(number.idNumber)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingNumber = number
                        inputText = number.idNumber
                        number.isCompleted = true
                        try? modelContext.save()
                    }
                }
            }
        }
        .onAppear {
            DataManager.loadDefaultNumbersIfNeeded(context: modelContext)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Number.self, configurations: config)
    
    let completed = Number(name: "Steuer-ID", idNumber: "12X 12 12345", isCompleted: true)
    let incomplete = [
        Number(name: "Sozialversicherung", idNumber: ""),
        Number(name: "Rentenversicherung", idNumber: ""),
        Number(name: "Krankenversicherung", idNumber: "")
    ]
    
    for number in incomplete {
        container.mainContext.insert(number)
    }
    container.mainContext.insert(completed)
    
    return NumbersEditView()
        .modelContainer(container)
}
