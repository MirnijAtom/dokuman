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
            
            HStack {
                Image(systemName: "star.fill")
                Text("Numbers")
            }
            .font(.headline)
            .padding(.horizontal)
            
            if completedNumbers.isEmpty {
                NavigationLink {
                    NumbersEditView()
                } label: {
                    Text("Add your first number")
                }
            } else {
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
            }
        }
        .frame(maxWidth: .infinity, minHeight: 226)
        .padding(.vertical, 12)
        .background(Color.yellow)
        .cornerRadius(0)
        .shadow(radius: 2)
    }
}

#Preview {
    NumbersSectionView()
        .modelContainer(for: Number.self)
}
