//
//  PetListsView.swift
//  PetPocket
//
//  Created by Michel Pierce on 03/06/26.
//

import SwiftUI

struct PetListView: View {
    @Environment(AuthManager.self) private var auth
    @State private var store = PetStore()
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false
    @State private var searchPet: String = ""

    private var filteredOwned: [PetRow] {
        let q = searchPet.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return store.ownedPets }
        return store.ownedPets.filter { $0.name.lowercased().contains(q) }
    }

    private var filteredSitting: [PetRow] {
        let q = searchPet.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return store.sittingPets }
        return store.sittingPets.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {

                        // Your Pets header row
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Here Are Your Pets 🐾")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundColor(.primaryG)
                            }
                            Spacer()
                            Button {
                                Task { await auth.signOut() }
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primaryG)
                                    .padding(8)
                                    .glassEffect()
                            }
                        }

                        // Pet cards
                        VStack(spacing: 16) {
                            if store.isLoading && !store.hasAnyPet {
                                ProgressView().padding(.top, 40)
                            }

                            ForEach(filteredOwned) { pet in
                                NavigationLink(value: pet) {
                                    PetListCard(item: petItem(from: pet, type: .owning))
                                }
                                .buttonStyle(.plain)
                            }

                            ForEach(filteredSitting) { pet in
                                NavigationLink(value: pet) {
                                    PetListCard(item: petItem(
                                        from: pet,
                                        type: .sitting(sitter: "Owner", sitterImage: "", dateRange: "")
                                    ))
                                }
                                .buttonStyle(.plain)
                            }

                            // add new pet
                            Button(action: { showAddModal = true }) {
                                Image(systemName: "plus")
                                    .fontWeight(.bold)
                                    .frame(width: 36, height: 36)
                                    .glassEffect()
                            }
                        }
                        .padding(20)
                    }
                    .padding(.top, 16)
                }
                .navigationBarHidden(true)
                .searchable(text: $searchPet)
                .searchToolbarBehavior(.minimize)
                .navigationDestination(for: PetRow.self) { pet in
                    PetDashboardView(pet: pet)
                }
                .navigationDestination(isPresented: $navigateToOwnPet) {
                    AddingNewPetForm(store: store)
                }
                .navigationDestination(isPresented: $navigateToSitPet) {
                    PetCodeInput(store: store)
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
        .task { await store.load() }
        .refreshable { await store.load() }
    }

    private var subtitle: String {
        let n = store.ownedPets.count + store.sittingPets.count
        return "\(n) friend\(n == 1 ? "" : "s") under your care"
    }

    private func petItem(from pet: PetRow, type: PetCardType) -> PetItem {
        PetItem(
            id: pet.id,
            name: pet.name,
            gender: pet.gender ?? "",
            age: pet.ageDescription,
            breed: pet.breed ?? "",
            photoUrl: pet.photoUrl,
            type: type
        )
    }
}

#Preview {
    PetListView()
}
