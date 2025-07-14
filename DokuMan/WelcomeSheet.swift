//
//  WelcomeSheet.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.07.25.
//

import SwiftUI

struct WelcomeSheet: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("welcome_title")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 4)

                Text("welcome_subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Group {
                    FeatureBlock(
                        icon: "folder.fill.badge.person.crop",
                        titleKey: "feature_allinone_title",
                        descriptionKey: "feature_allinone_desc"
                    )

                    FeatureBlock(
                        icon: "lock.shield",
                        titleKey: "feature_secure_title",
                        descriptionKey: "feature_secure_desc"
                    )

                    FeatureBlock(
                        icon: "plus.rectangle.on.folder.fill",
                        titleKey: "feature_scan_title",
                        descriptionKey: "feature_scan_desc"
                    )

                    FeatureBlock(
                        icon: "star.fill",
                        titleKey: "feature_favorites_title",
                        descriptionKey: "feature_favorites_desc"
                    )

                    FeatureBlock(
                        icon: "sparkles",
                        titleKey: "feature_simple_title",
                        descriptionKey: "feature_simple_desc"
                    )

                    FeatureBlock(
                        icon: "gearshape",
                        titleKey: "feature_personal_title",
                        descriptionKey: "feature_personal_desc"
                    )
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle(Text("welcome_nav_title"))
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Subview
struct FeatureBlock: View {
    let icon: String
    let titleKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.teal)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 6) {
                Text(titleKey)
                    .font(.headline)
                Text(descriptionKey)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeSheet()
        .environment(\.locale, .init(identifier: "de")) // Simulate German
}
