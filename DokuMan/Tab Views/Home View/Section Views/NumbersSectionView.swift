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
        
        @Binding var selectedTab: Int
        
        @State private var isExpanded = false
        @State private var copiedID: UUID? = nil
        var body: some View {
            let visibleNumbers = isExpanded ? numbers : Array(numbers.prefix(3))
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Header
                HStack {
                    Image(systemName: "numbers.rectangle")
                    Text("Numbers")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Edit") {
                        selectedTab = 2
                    }
//                    NavigationLink {
//                        NumbersEditView()
//                    } label: {
//                        Text("Edit")
//                            .padding(.horizontal)
//                            .foregroundStyle(.secondary)
//                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                // Content
                if numbers.isEmpty {
                    NavigationLink {
                        NumbersEditView()
                    } label: {
                        Text("Add your first number")
                            .padding(.horizontal)
                            .foregroundStyle(.blue)
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

                                    Text("Copied!")
                                        .numberTextStyle()
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .opacity(copiedID == number.id ? 1 : 0)
                                        .animation(.easeInOut, value: copiedID)
                                }

                                
                                Divider()
                                
                                Button {
                                    UIPasteboard.general.string = number.idNumber
                                    
                                    let generator = UIImpactFeedbackGenerator()
                                    generator.impactOccurred()
                                    
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
            .background(Color.teal.tertiary)
            .cornerRadius(0)
        }
    }

    #Preview {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Number.self, configurations: config)
        
        
        let numbers = [
            Number(name: "Sozialversicherung", idNumber: "12 123456 A 123", isCompleted: true),
            Number(name: "Krankenversicherung", idNumber: "X123456789", isCompleted: true),
            Number(name: "Insurance", idNumber: "ABVDSA4362346", isCompleted: true),
            Number(name: "Lawyer insurance", idNumber: "436416JBI76a", isCompleted: true),
            Number(name: "Bank insurance", idNumber: "12123123", isCompleted: true),
            Number(name: "Renteversicherung", idNumber: "X123KHG456789", isCompleted: true),
            Number(name: "Passport number", idNumber: "DE6598735", isCompleted: true)
        ]
        
        for number in numbers {
            container.mainContext.insert(number)
        }

        
        return NumbersSectionView(selectedTab: .constant(0))
            .modelContainer(container)
    }
