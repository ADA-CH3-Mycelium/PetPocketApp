//
//  SocialButton.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//


import SwiftUI

struct SocialButton: View {

    let imageName: String
    let title: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: 10) {

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.3))
            )
            .cornerRadius(14)
        }
    }
}
