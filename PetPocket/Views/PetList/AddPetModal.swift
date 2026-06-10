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
                ZStack {
                    Color.secondaryG.opacity(0.7).ignoresSafeArea()
                // Cards
                VStack(spacing: 10) {
                    // own
                    PetTypeCard(
                        own: true,
                        title: "Pet Owner",
                        description: "",
                        action: {
                            isPresented = false
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.35
                            ) {
                                onOwnPet()
                            }
                        }
                    )
                    
                    //sit
                    PetTypeCard(
                        own: false,
                        title: "Sit a Pet",
                        description:
                            "Temporarily manage a pet for a friend or client with shared information.",
                        action: {
                            isPresented = false
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.35
                            ) {
                                onSitPet()
                            }
                        }
                    )
                }.padding(16)
                }
        
        .navigationBarTitle("Add a new Pet 🐾")
        .navigationBarTitleDisplayMode(.inline)
            
       
        .ignoresSafeArea()
    }
        
        
        
    }
}

#Preview {

        AddPetModal(isPresented: .constant(true), onOwnPet: {}, onSitPet: {})
               .presentationDetents([.medium])
               .presentationCornerRadius(24)
    
   
}
