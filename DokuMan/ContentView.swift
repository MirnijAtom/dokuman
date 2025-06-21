//
//  ContentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import LocalAuthentication
import PDFKit
import SwiftData
import SwiftUI

struct ContentView: View {    
    @State private var selectedTab: Int = 0
    @State private var showAddDoc = false
    @Query(sort: \Document.name, animation: .default) var documents: [Document]
    
    @State private var isUnlocked = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
//        if isUnlocked {
            ZStack {
                VStack(spacing: 0) {
                    // Pages
                    TabView(selection: $selectedTab) {
                        HomeView(selectedTab: $selectedTab).tag(0)
                        FilesView().tag(1)
                        NumbersEditView().tag(2)
                        AccountView().tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Custom Tab Bar
                    HStack(spacing: 8) {
                        tabButton(icon: "house", iconFill: "house.fill", title: "Home", index: 0).frame(maxWidth: .infinity)
                        tabButton(icon: "folder", iconFill: "folder.fill",  title: "Files", index: 1).frame(maxWidth: .infinity)
                        tabButton(icon: "numbers.rectangle", iconFill: "numbers.rectangle.fill",  title: "Numbers", index: 2).frame(maxWidth: .infinity)
                        tabButton(icon: "person", iconFill: "person.fill",  title: "Account", index: 3).frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 35)
                    .padding(.top, 12)
                    .background(.ultraThinMaterial)
                }
                
                // Add New Document Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showAddDoc = true
                        } label: {
                            Image(systemName: "document.viewfinder")
                                .font(.system(size: 30))
                                .foregroundStyle(.teal)
                                .frame(width: 60, height: 60)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding(.bottom, 120)
                        .padding(.trailing, 30)
                    }
                }
            }
            .ignoresSafeArea()
            .sheet(isPresented: $showAddDoc) {
                AddDocumentView()
                    .presentationDetents([.large])
            }
            .background(Color(uiColor: .systemBackground))
            .environment(\.colorScheme, isDarkMode ? .dark : .light)


//        } else {
//            Text("Unlock your device")
//                .onAppear {
//                    authenticate()
//                }
//        }
    }
    
    @ViewBuilder
    func tabButton(icon: String, iconFill: String, title: String, index: Int) -> some View {
        Button {
            withAnimation(nil) {
                selectedTab = index
            }
        } label: {
            VStack {
                Image(systemName: selectedTab == index ? iconFill : icon)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(selectedTab == index ? Color.teal : Color.clear)
                    )
                    .foregroundColor(selectedTab == index ? .white : .primary)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Color.primary)
            }
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
    }
    
    func authenticate() {
        print("Authenticating...")  // Debug log
        let context = LAContext()
        var error: NSError?

        // Use passcode fallback to make testing easier
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock to access your documents."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                if success {
                    DispatchQueue.main.async {
                        print("✅ Auth succeeded")
                        isUnlocked = true
                    }
                } else {
                    print("❌ Auth failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("❌ Can't evaluate policy: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Document.self)
}
