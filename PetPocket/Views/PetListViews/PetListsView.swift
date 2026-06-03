//
//  PetListsView.swift
//  PetPocket
//
//  Created by Michel Pierce on 03/06/26.
//

import SwiftUI

struct PetListsView: View {
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false
    
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
                            .foregroundColor(.primaryG)
                        
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
                    
                    // Pet cards
                    VStack(spacing: 16) {
                        if (mockData.isEmpty){
                            Spacer()
                            
                            // Center empty state
                            VStack(spacing: 8) {
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
                                    .background(Color.primaryG)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .padding(.top, 60)
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 66)
                        }
                        else {
                            
                            // Your Pet header row
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Pets")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text("\(mockData.count) pet friends under your care")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: { showAddModal = true }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.primaryG)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.bottom, 16)
                            ForEach(mockData){item in
                                NavigationLink(value: item){
                                    PetListCard(item: item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationTitle("Pet Lists")
            .navigationDestination(for: PetItem.self) { tappedItem in
                            PetDashboardView(PetData: tappedItem)
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

#Preview {
    PetListsView()
}
