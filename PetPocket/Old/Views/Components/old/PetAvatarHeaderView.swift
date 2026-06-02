//
//  PetAvatarHeaderView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

struct PetAvatarHeaderView: View {
    let name: String
    let imageName: String

    var body: some View {
        VStack(spacing: 10) {

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)


            Text(name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    PetAvatarHeaderView(name: "Cooper", imageName: "cooper_avatar")
        .padding()
}
