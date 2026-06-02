//
//  EmptyStatePetList.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//
import SwiftUI

struct EmptyStatePetList: View {
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top header
                HStack(alignment: .center, spacing: 12) {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image("AlexProfilePicture")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .foregroundColor(.white)
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
                .padding(.bottom, 20)

                Spacer()

                // Center empty state
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

                    Button(action: {
                        showAddModal = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Add a Pet")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: 220)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color(.primary))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationDestination(isPresented: $navigateToOwnPet) {
                AddingNewPetForm()
            }
            .navigationDestination(isPresented: $navigateToSitPet) {
                PetCodeInput()
            }
            .sheet(isPresented: $showAddModal) {
                AddPetModal(isPresented: $showAddModal,
                            onOwnPet: { navigateToOwnPet = true },
                            onSitPet: { navigateToSitPet = true })
                    .presentationDetents([.height(400)])
                    .presentationCornerRadius(24)
            }
        }
    }
}

#Preview {
    EmptyStatePetList()
}
