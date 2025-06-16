//
//  ContentView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import PDFKit
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showAddDoc = false
    @Query(sort: \Document.name, animation: .default) var documents: [Document]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $selectedTab) {
                    HomeView().tag(0)
                    FilesView().tag(1)
                    AddDocumentView(selectedTab: $selectedTab).tag(3)
                    ArchiveView().tag(4)
                    Text("Item 4").tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Tab Bar
                HStack(spacing: 8) {
                    tabButton(icon: "house", iconFill: "house.fill", title: "Home", index: 0)
                    tabButton(icon: "folder", iconFill: "folder.fill",  title: "Files", index: 1)
                    tabButton(icon: "document.viewfinder", iconFill: "document.viewfinder.fill",  title: "Scanner", index: 3)
                    tabButton(icon: "archivebox", iconFill: "archivebox.fill",  title: "Archive", index: 4)
                    tabButton(icon: "person", iconFill: "person.fill",  title: "Account", index: 5)
                }
                .padding(.horizontal)
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
                            .foregroundStyle(.appTeal)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)

                    }
                    .padding(.bottom, 120)
                    .padding(.trailing, 30)
                }
            }
        }
        .ignoresSafeArea()
//        .sheet(isPresented: $showAddDoc, content: AddDocumentView()
    }
    
    @ViewBuilder
    func tabButton(icon: String, iconFill: String, title: String, index: Int) -> some View {
        Button {
            withAnimation(nil) {
                selectedTab = index
            }
        } label: {
            VStack {
                Image( systemName: selectedTab == index ? iconFill : icon)
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
}

#Preview {
    ContentView()
        .modelContainer(for: Document.self)
}
