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
    
    
    var body: some View {
        List {
            Section(header: Text("filled")) {
                let filledNumbers = numbers.filter { !$0.idNumber.isEmpty }
                ForEach(filledNumbers) { number in
                    HStack {
                        Text(number.name)
                        Text(number.idNumber)
                    }
                }
            }
            
            Section(header: Text("empty")) {
                ForEach(numbers) { number in
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
                }
            }
        }
        .onAppear {
            DataManager.loadDefaultNumbersIfNeeded(context: modelContext)
        }
    }
}

#Preview {
    NumbersEditView()
        .modelContainer(for: Number.self)
}
