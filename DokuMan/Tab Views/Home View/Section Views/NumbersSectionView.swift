//
//  NumbersSectionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.05.25.
//

import SwiftData
import SwiftUI

struct NumbersSectionView: View {
    
    @Query var numbers: [Number]
    var completedNumbers: [Number] {
        numbers
            .filter { $0.isCompleted }
            .filter { !$0.idNumber.isEmpty}
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Header
            HStack {
                Image(systemName: "numbers.rectangle")
                Text("Numbers")
            }
            .font(.headline)
            .padding(.horizontal)
            
            // Content
            if completedNumbers.isEmpty {
                NavigationLink {
                    NumbersEditView()
                } label: {
                    Text("Add your first number")
                        .padding(.horizontal)
                        .foregroundStyle(.blue)
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(completedNumbers) { number in
                        VStack(spacing: 4) {
                            HStack {
                                Text(number.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(4)
                                
                                Divider()
                                
                                Text(number.idNumber)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(4)
                            }
                            .padding(.horizontal)
                            .background(Color("AppTeal").opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                            
                            
                            Divider()
                        }
                    }
                    NavigationLink {
                        NumbersEditView()
                    } label: {
                        Text("Add more")
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 86, maxHeight: 186)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(0)
        .shadow(radius: 2)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Number.self, configurations: config)
    
    let completed = Number(name: "Steuer-ID", idNumber: "12X 12 12345", isCompleted: true)
    
    let incomplete = [
        Number(name: "Sozialversicherung", idNumber: "12 123456 A 123", isCompleted: true),
        Number(name: "Krankenversicherung", idNumber: "X123456789", isCompleted: true)
    ]
    
    for number in incomplete {
        container.mainContext.insert(number)
    }
    container.mainContext.insert(completed)
    
    return NumbersSectionView()
        .modelContainer(container)
}
