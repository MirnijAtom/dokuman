//
//  StarView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI

struct StarView: View {
    @State private var isFavourite: Bool = false
    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundColor(isFavourite ? .yellow : Color(.systemBackground))
            Button(action: { isFavourite.toggle() }) {
                Image(systemName: "star")
                    .font(.title)
                    .foregroundColor(.secondary)

            }
        }
    }
}

#Preview {
    StarView()
}
