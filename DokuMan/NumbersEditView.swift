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
        List(numbers) { number in
            HStack {
                Text(number.name)
                Text(number.number)
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
