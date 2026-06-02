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
                        // Card 1 — Owning
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                Image("1PetImage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Cooper")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)

                        // Card 2 — Sitting
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                Image("2PetImage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
                            }

                            VStack(spacing: 8) {
                                HStack {
                                    Text("Luna")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    HStack(spacing: 6) {
                                        Image("SarahPic")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 22, height: 22)
                                            .clipShape(Circle())

                                        Text("Sarah")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                HStack {
                                    Text("Calico Cat")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        Text("2 days left")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
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
