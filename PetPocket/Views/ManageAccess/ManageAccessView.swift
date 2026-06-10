//
//  ManageAccessView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//

import SwiftUI

struct Collaborator: Identifiable {
    var id: String { name }
    let name: String
    let role: String
    let isActive: Bool
    let imageName: String
}

struct ManageAccessView: View {
    @Environment(\.dismiss) var dismiss

    // MOCK DB
    let collaborators = [
        Collaborator(
            name: "Sarah J.",
            role: "Active Sitter",
            isActive: true,
            imageName: ""
        ),
        Collaborator(
            name: "Tom R.",
            role: "Past Sitter",
            isActive: false,
            imageName: "pet sitter"
        ),
        Collaborator(
            name: "John Q.",
            role: "Active Sitter",
            isActive: true,
            imageName: "pet sitter"
        ),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                
                List {
                    // List of Connected Sitters
                    ForEach(collaborators) { person in
                        if person.isActive {
                            Section {
                                HStack {
                                    // img
                                    if person.imageName.isEmpty {
                                        
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFill()
                                            .padding(.top, 20)
                                            .padding(.horizontal, 10)
                                            .frame(width: 80, height: 80)
                                            .background(Color.primaryG)
                                            .foregroundStyle(Color.secondaryG)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                    } else {
                                        Image(person.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(12)
                                    }
                                    
                                    // text & actions
                                    
                                    VStack(alignment: .leading) {
                                        // name
                                        Text(person.name)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        // Contextual Decision Buttons
                                        HStack(spacing: 12) {
                                            Button(action: {}) {
                                                Text(
                                                    person.isActive
                                                    ? "Remove"
                                                    : "Remove Sitter"
                                                )
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 3)
                                                .foregroundStyle(Color.secondary)
                                            }
                                            .buttonStyle(.glass)
                                            
                                            
                                            Button(action: {}) {
                                                Text(
                                                    person.isActive
                                                    ? "New Code"
                                                    : "Invite Again"
                                                )
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 3)
                                                
                                            }
                                            .buttonStyle(.glassProminent)
                                            .tint(Color.primaryG)
                                        }
                                        
                                    }
                                    
                                }.listRowBackground(Color.secondaryG.opacity(0.5))
                            }
                        }
                    }
                    
                    
                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(.compact)
                
                // lookng for past sitter?
                
                // DONT HAVE ACC?
                HStack(spacing: 5) {
                    Text("Looking for a")
                    Button("Past Sitter?") {
                        print("sign up btn pressed")
                    }
                    .foregroundColor(.primaryG)
                    .fontWeight(.semibold)
                    
                }.font(.caption)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            .navigationTitle("Manage Access")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ManageAccessView()
}
