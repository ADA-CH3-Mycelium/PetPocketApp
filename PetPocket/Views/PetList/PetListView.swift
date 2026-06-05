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

    var mockData: [PetItem] = [
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
        ),
    ]

    var body: some View {

        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // Pet cards
                    VStack(spacing: 16) {
                        ForEach(mockData) { pet in
                            PetListCard(
                                item: PetItem(
                                    id: pet.id,
                                    name: pet.name,
                                    gender: pet.gender,
                                    age: pet.age,
                                    breed: pet.breed,
                                    image: pet.image,
                                    type: pet.type,
                                )
                            )
                            .onTapGesture {
                                navigateToDashboard = true
                            }
                        }

//                        // add new pet
//                        Button(action: { showAddModal = true }) {
//                            Image(systemName: "plus")
//                                .fontWeight(.bold)
//                                .frame(width: 36, height: 36)
//                                .glassEffect()
//                        }
                    }
                }.padding(20)
                    // header
                    .navigationTitle(Text("Here Are Your Pets 🐾"))
                    .navigationSubtitle(Text("2 friends are under your care"))
                    .navigationBarTitleDisplayMode(.large)
                // toolbar
                    .searchable(text: $searchPet)
                    //.searchToolbarBehavior(.minimize)
                    .toolbar {
                        
                        // search btn
                        DefaultToolbarItem(kind: .search, placement: .bottomBar)
                        ToolbarSpacer(placement: .bottomBar)
                        
                        // add btn
                        ToolbarItem(placement: .bottomBar) {
                            
                            Button(action: {
                                showAddModal.toggle()
                            }) {
                                
                                Image(systemName: "plus")
                            }
                        }
                        

                    }
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
