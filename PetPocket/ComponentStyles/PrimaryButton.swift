//
//  PrimaryButton.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//


import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    isEnabled
                    ? Color.primaryG
                    : Color.gray.opacity(0.5)
                )
                .cornerRadius(18)
        }
        .disabled(!isEnabled)
    }
}
