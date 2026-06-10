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
                .textCase(.uppercase)
                .padding(.vertical, 10)
                .padding(.horizontal, 40)
                .cornerRadius(50)
        }
        .buttonStyle(.glassProminent)
        .disabled(!isEnabled)
        .tint(isEnabled
              ? Color.accent
              : Color.gray.opacity(0.5))
        
    }
}

#Preview {
    PrimaryButton(title: "Login", isEnabled: true) {
        print("yay")
    }
}
