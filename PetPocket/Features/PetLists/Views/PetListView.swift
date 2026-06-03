//
//  PetListView.swift
//  PetPocket
//
//  Data-driven home. Replaces the static EmptyStatePetList / AddedStatePetList
//  mockups: loads the signed-in user's profile + pets from Supabase and shows
//  the empty state or the pet list accordingly.
//

import SwiftUI

struct PetListView: View {
    @State private var store = PetStore()
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false

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
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 50, height: 50)
                .overlay(
                    Image("AlexProfilePicture")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
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
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { showAddModal = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.primaryApp)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                VStack(spacing: 16) {
                    ForEach(store.ownedPets) { pet in
                        NavigationLink(value: pet) {
                            PetListCard(item: PetCardItem(
                                name: pet.name,
                                image: "1PetImage",
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
                                PetListCard(item: PetCardItem(
                                    name: pet.name,
                                    image: "2PetImage",
                                    type: .owning
                                ))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    private var subtitle: String {
        let n = store.ownedPets.count + store.sittingPets.count
        return "\(n) pet friend\(n == 1 ? "" : "s") under your care"
    }

    private func addButton(label: String, wide: Bool) -> some View {
        Button(action: { showAddModal = true }) {
            HStack(spacing: 8) {
                Image(systemName: "plus").font(.system(size: 17, weight: .semibold))
                Text(label).font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: wide ? 220 : nil)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Color.primaryG)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    PetListView()
}
