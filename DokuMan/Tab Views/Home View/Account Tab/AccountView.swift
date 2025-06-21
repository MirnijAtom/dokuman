//
//  AccountView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftData
import SwiftUI

struct AccountView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedLanguage = "en"
    
    @State private var showPrivacyPolicy = false
    @State private var showTermsAndConditions = false
    @State private var showStorageInfo = false

    
    var body: some View {
        List {
            Section {
                Toggle("Dark mode", isOn: $isDarkMode)
                    .toggleStyle(.switch)
                
                HStack {
                    Text("Language")
                    
                    Spacer()
                    
                    Button {
                        selectedLanguage = "en"
                    } label: {
                        Image("UKFlag")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selectedLanguage == "en" ? Color.teal.secondary : Color.clear.secondary, lineWidth: 1)
                            )
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)

                    Spacer().frame(width: 16)
                    
                    Button {
                        selectedLanguage = "de"
                    } label: {
                        Image("GermanFlag")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selectedLanguage == "de" ? Color.teal.secondary : Color.clear.secondary, lineWidth: 1)
                            )
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
                
                Button("Storage Info") {
                    showStorageInfo.toggle()
                }
                .foregroundStyle(.primary)

            }
            

            
            Section {
                Text("Upgrade to Pro")
                Text("Manage Subscription")
            }
            
            Section {
                Button("Privacy Policy") {
                    showPrivacyPolicy = true
                }
                .foregroundStyle(.primary)
                Button("Terms & Conditions") {
                    showTermsAndConditions = true
                }
                .foregroundStyle(.primary)
            }
            

            Section {
                
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsAndConditions) {
            TermsAndConditionsView()
        }
        .sheet(isPresented: $showStorageInfo) {
            StorageInfoView()
        }
    }
}

#Preview {
    AccountView()
}
