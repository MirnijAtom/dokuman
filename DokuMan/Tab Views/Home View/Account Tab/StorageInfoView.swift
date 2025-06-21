//
//  StorageInfoView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftData
import SwiftUI


struct StorageInfoView: View {
    @Query var documents: [Document]
    @Query var numbers: [Number]
    var body: some View {
        List {
                Text("Documents saved: \(documents.count)")
                Text("Numbers saved: \(numbers.count)")
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    StorageInfoView()
}
