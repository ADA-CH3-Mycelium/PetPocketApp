//
//  AddedStatePetList.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//
import SwiftUI

struct AddedStatePetList: View {
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Top header
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

                        Text("Good morning, Alex!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryApp)

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // Your Pet header row
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Pets")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("2 pet friends under your care")
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

                    // Pet cards
                    VStack(spacing: 16) {
                        PetListCard(item: PetCardItem(
                            name: "Cooper",
                            image: "1PetImage",
                            type: .owning
                        ))

                        PetListCard(item: PetCardItem(
                            name: "Luna",
                            image: "2PetImage",
                            type: .sitting(
                                sitter: "Sarah",
                                sitterImage: "SarahPic",
                                dateRange: "Nov 5th - Nov 10th"
                            )
                        ))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
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

#Preview {
    AddedStatePetList()
}
