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
        NavigationStack {
            Group {
                if store.isLoading && !store.hasAnyPet {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.hasAnyPet {
                    petList
                } else {
                    emptyState
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToOwnPet) {
                AddingNewPetForm(store: store)
            }
            .navigationDestination(isPresented: $navigateToSitPet) {
                PetCodeInput(store: store)
            }
            .navigationDestination(for: PetRow.self) { pet in
                PetDashboardView(pet: pet)
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
        .task { await store.load() }
        .refreshable { await store.load() }
    }

    // MARK: Header
    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            // Initials avatar — replaced hardcoded AlexProfilePicture
            // (profiles table has no photo_url yet; swap to AsyncImage when available)
            Circle()
                .fill(Color.primaryG.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(profileInitials)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryG)
                )

            Text(greeting)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primaryApp)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    private var profileInitials: String {
        let name = store.profileName
        guard !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }

    private var greeting: String {
        let name = store.profileName.isEmpty ? "there" : store.profileName
        return "Good morning, \(name)!"
    }

    // MARK: Empty state
    private var emptyState: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            VStack(spacing: 48) {
                RoundedRectangle(cornerRadius: 24)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Image("EmptyStateImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 230)
                    )
                VStack(spacing: 12) {
                    Text("Your pet family starts here")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("Add your own pet or join a friend's pet\nprofile to stay connected")
                        .font(.subheadline)
                        .foregroundColor(.neutral)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                addButton(label: "Add a Pet", wide: true)
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    // MARK: Populated list
    private var petList: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Pets")
                            .font(.title2).fontWeight(.bold)
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
                    } .padding(20)
                }
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
