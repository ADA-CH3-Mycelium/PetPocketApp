//
//  PetListsView.swift
//  PetPocket
//
//  Created by Michel Pierce on 03/06/26.
//

import SwiftUI

struct PetListView: View {
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false
    @State private var navigateToDashboard = false
    @State private var searchPet: String = ""
    
    var mockData : [PetItem] = [
        PetItem(
            id: UUID(),
            name: "Cooper",
            gender: "Male",
            age: "3",
            breed: "Golden Retriever",
            image: "1PetImage",
            type: .owning
        ),
        PetItem(
            id: UUID(),
            name: "Luna",
            gender: "Male",
            age: "4",
            breed: "Orange Cat",
            image: "2PetImage",
            type: .sitting(
                sitter: "Sarah",
                sitterImage: "SarahPic",
                dateRange: "Nov 5th - Nov 10th"
            )
        )
    ]
    
    
    var body: some View {
        
        ZStack {
            Color.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // Your Pet header row
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Here Are Your Pets 🐾")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("2 friends are under your care")
                            .font(.caption)
                            .foregroundColor(.primaryG)
                    }
                    
                    // Pet cards
                    VStack(spacing: 16) {
                        ForEach(mockData){ pet in
                            PetListCard(item: PetItem(
                                id: pet.id,
                                name: pet.name,
                                gender: pet.gender ?? "",
                                age: pet.ageDescription,
                                breed: pet.breed ?? "",
                                photoUrl: pet.photoUrl,
                                type: .owning
                            ))
                        }
                        .buttonStyle(.plain)
                    }

                    if !store.sittingPets.isEmpty {
                        Text("Pets you're caring for")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        ForEach(store.sittingPets) { pet in
                            NavigationLink(value: pet) {
                                PetListCard(item: PetItem(
                                    id: pet.id,
                                    name: pet.name,
                                    gender: pet.gender ?? "",
                                    age: pet.ageDescription,
                                    breed: pet.breed ?? "",
                                    photoUrl: pet.photoUrl,
                                    // Sitter owner info — will be replaced in Phase 5
                                    // when ManageAccess fetches real owner profiles
                                    type: .sitting(
                                        sitter: "Owner",
                                        sitterImage: "",
                                        dateRange: ""
                                    )
                                ))
                            }
                        }
                        
                        // add new pet
                        Button(action: { showAddModal = true }) {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                                .frame(width: 36, height: 36)
                                .glassEffect()
                        }
                    }
                }.padding(20)
                .navigationBarHidden(true)
                .searchable(text: $searchPet)
                .searchToolbarBehavior(.minimize)
                .navigationDestination(isPresented: $navigateToDashboard) {
                    PetDashboardView()
                }
                .navigationDestination(isPresented: $navigateToOwnPet) {
                    AddingNewPetForm()
                }
                .navigationDestination(isPresented: $navigateToSitPet) {
                    PetCodeInput()
                }
                .sheet(isPresented: $showAddModal) {
                    AddPetModal(
                        isPresented: $showAddModal,
                        onOwnPet: { navigateToOwnPet = true },
                        onSitPet: { navigateToSitPet = true }
                    )
                    .presentationDetents([.height(400)])
                    .presentationCornerRadius(24)
                }
            }
        }
    }
}

#Preview {
    PetListView()
}
