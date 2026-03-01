//
//  WelcomeSheet.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.07.25.
//

import SwiftUI

struct WelcomeSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.teal)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color.teal.opacity(0.14))
                            )

                        Text("welcome_title")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("welcome_subtitle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    VStack(spacing: 0) {
                        FeatureRow(
                            icon: "folder.fill.badge.person.crop",
                            titleKey: "feature_allinone_title",
                            descriptionKey: "feature_allinone_desc"
                        )
                        Divider().padding(.leading, 52)
                        FeatureRow(
                            icon: "lock.shield",
                            titleKey: "feature_secure_title",
                            descriptionKey: "feature_secure_desc"
                        )
                        Divider().padding(.leading, 52)
                        FeatureRow(
                            icon: "plus.rectangle.on.folder.fill",
                            titleKey: "feature_scan_title",
                            descriptionKey: "feature_scan_desc"
                        )
                        Divider().padding(.leading, 52)
                        FeatureRow(
                            icon: "star.fill",
                            titleKey: "feature_favorites_title",
                            descriptionKey: "feature_favorites_desc"
                        )
                    }
                    .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Text("welcome_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(LocalizedStringKey("OK")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subview
struct FeatureRow: View {
    let icon: String
    let titleKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.teal)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(titleKey)
                    .font(.headline)
                Text(descriptionKey)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview
#Preview {
    WelcomeSheet()
        .environment(\.locale, .init(identifier: "de")) // Simulate German
}
