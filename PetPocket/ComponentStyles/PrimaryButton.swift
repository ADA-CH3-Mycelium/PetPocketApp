//
//  PrimaryButton.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//


import SwiftUI

struct PrimaryButton: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color(
                        red: 69/255,
                        green: 109/255,
                        blue: 82/255
                    )
                )
                .cornerRadius(18)
        }
    }
}