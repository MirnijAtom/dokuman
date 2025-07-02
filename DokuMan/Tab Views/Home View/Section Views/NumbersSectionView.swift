    //
    //  NumbersSectionView.swift
    //  DokuMan
    //
    //  Created by Aleksandrs Bertulis on 10.05.25.
    //

    import SwiftData
    import SwiftUI

    // MARK: - NumbersSectionView

    /// Displays a summary of user numbers/IDs, with quick copy and expand/collapse functionality.
    struct NumbersSectionView: View {
        // MARK: - Query & State
        /// All numbers/IDs in the database.
        @Query var numbers: [Number]
        /// The selected tab index (bound to parent TabView).
        @Binding var selectedTab: Int
        @State private var isExpanded = false
        @State private var copiedID: UUID? = nil

        // MARK: - Body
        var body: some View {
            let visibleNumbers = isExpanded ? numbers : Array(numbers.prefix(3))
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Header
                HStack {
                    Image(systemName: "numbers.rectangle")
                    Text(LocalizedStringKey("Numbers"))
                        .font(.headline)
                    
                    Spacer()
                    if !numbers.isEmpty {
                        Button(LocalizedStringKey("Edit")) {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            selectedTab = 2
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                // Content
                if numbers.isEmpty {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        selectedTab = 2
                    } label: {
                        HStack {
                            Text(LocalizedStringKey("Add your first number"))
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .padding()
                                .padding(.trailing, 15)
                                .padding(.leading, 10)
                            Image("emptyNumbersIcon")
                                .resizable()
                                .scaledToFit()
                                .padding(.trailing, 30)
                                .frame(height: 100)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                    }
                } else {
                    VStack {
                        ForEach(visibleNumbers) { number in
                            HStack {
                                Text(number.name)
                                    .numberTextStyle()
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                
                                ZStack {
                                    Text(number.idNumber)
                                        .numberTextStyle()
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .opacity(copiedID == number.id ? 0 : 1)
                                        .animation(.easeInOut, value: copiedID)
                                        .onTapGesture {
                                            UIPasteboard.general.string = number.idNumber
                                            let generator = UIImpactFeedbackGenerator()
                                            generator.impactOccurred()
                                            copiedID = number.id
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                copiedID = nil
                                            }
                                        }
                                    Text(LocalizedStringKey("Copied!"))
                                        .numberTextStyle()
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .opacity(copiedID == number.id ? 1 : 0)
                                        .animation(.easeInOut, value: copiedID)
                                }

                                
                                Divider()
                                
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    UIPasteboard.general.string = number.idNumber
                                    
                                    copiedID = number.id
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        copiedID = nil
                                    }
                                } label: {
                                    Image(systemName: "document.on.document")
                                        .numberTextStyle()
                                        .foregroundStyle(Color.secondary)
                                        .padding(.leading, 4)
                                }
                            }
                            .frame(height: 30)
                            .padding(.horizontal)
                            .padding(.top, number == numbers.first ? 8 : 0)
                            .padding(.bottom, number == numbers.last ? 8 : 0)
                            if number != numbers.last {
                                Divider()
                            }
                        }
                    }
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Spacer ()
                        VStack {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .padding(.top, 6)
                        }
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                }

                
            }
            .frame(maxWidth: .infinity, minHeight: 86)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(0)
        }
    }

    #Preview {
        let themeSettings = ThemeSettings()
        let languageSettings = LanguageSettings()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Number.self, configurations: config)
//        let numbers = [
//            Number(name: "Sozialversicherung", idNumber: "12 123456 A 123", isCompleted: true),
//            Number(name: "Krankenversicherung", idNumber: "X123456789", isCompleted: true),
//            Number(name: "Insurance", idNumber: "ABVDSA4362346", isCompleted: true),
//            Number(name: "Lawyer insurance", idNumber: "436416JBI76a", isCompleted: true),
//            Number(name: "Bank insurance", idNumber: "12123123", isCompleted: true),
//            Number(name: "Renteversicherung", idNumber: "X123KHG456789", isCompleted: true),
//            Number(name: "Passport number", idNumber: "DE6598735", isCompleted: true)
//        ]
//        for number in numbers {
//            container.mainContext.insert(number)
//        }
        return NumbersSectionView(selectedTab: .constant(0))
            .modelContainer(container)
            .environmentObject(themeSettings)
            .environmentObject(languageSettings)
            .environment(\.locale, languageSettings.locale)
            .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
    }
