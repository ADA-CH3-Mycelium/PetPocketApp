//
//  AddPetModal.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI

struct AddPetModal: View {
    @Binding var isPresented: Bool
    var onOwnPet: () -> Void
    var onSitPet: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Add to PawPocket")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Cards
                VStack(spacing: 12) {
                    PetTypeCard(
                        icon: "OwnAPetIcon",
                        title: "Own a Pet",
                        description: "Register your pet family member to track their health and joy.",
                        action: {
                            isPresented = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                onOwnPet()
                            }
                        }
                    )
                    
                    PetTypeCard(
                        icon: "PetASitIcon",
                        title: "Sit a Pet",
                        description: "Temporarily manage a pet for a friend or client with shared information.",
                        action: {
                            isPresented = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                onSitPet()
                            }
                        }
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

#Preview {
    AddPetModal(isPresented: .constant(true), onOwnPet: {}, onSitPet: {})
        .presentationDetents([.medium])
        .presentationCornerRadius(24)
}
