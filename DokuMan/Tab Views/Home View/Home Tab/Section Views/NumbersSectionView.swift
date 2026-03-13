    //
    //  NumbersSectionView.swift
    //  DokuMan
    //
    //  Created by Aleksandrs Bertulis on 10.05.25.
    //

import SwiftData
import SwiftUI

// MARK: - NumbersSectionView

/// Displays a compact summary of user numbers/IDs with quick copy support.
struct NumbersSectionView: View {
    // MARK: - Query & State
    @Query(sort: \Number.date) var numbers: [Number]
    @State private var copiedID: UUID? = nil

    // MARK: - Body
    var body: some View {
        let visibleNumbers = Array(numbers.prefix(5))

        VStack(alignment: .leading, spacing: 4) {
            if numbers.isEmpty {
                ContentUnavailableView(
                    "No numbers yet",
                    systemImage: "numbers",
                    description: Text("Add your important IDs like tax, health insurance, or social security numbers.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                ForEach(Array(visibleNumbers.enumerated()), id: \.element.id) { index, number in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(number.name)
                                .numberTextStyle()
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ZStack(alignment: .leading) {
                                Text(number.idNumber)
                                    .numberTextStyle()
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(copiedID == number.id ? 0 : 1)
                                    .animation(.easeInOut, value: copiedID)

                                Text(LocalizedStringKey("Copied!"))
                                    .numberTextStyle()
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(copiedID == number.id ? 1 : 0)
                                    .animation(.easeInOut, value: copiedID)
                            }
                        }

                        Spacer()

                        Button {
                            UIPasteboard.general.string = number.idNumber
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()

                            // Force state refresh so repeated taps on the same row always animate.
                            copiedID = nil
                            DispatchQueue.main.async {
                                copiedID = number.id
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                if copiedID == number.id {
                                    copiedID = nil
                                }
                            }
                        } label: {
                            Image(systemName: "document.on.document")
                                .numberTextStyle()
                                .foregroundStyle(.secondary)
                                .padding(8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    Divider()
                        .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Number.self, configurations: config)
    NumbersSectionView()
        .modelContainer(container)
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
