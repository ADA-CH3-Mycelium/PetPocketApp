//
//  PetTypeCard.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI

struct PetTypeCard: View {
    var own: Bool
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: own ? "pawprint.fill" : "heart.fill")
                    .resizable()
                    .foregroundStyle(.accent)
                    .padding(16)
                    .frame(width: 52, height: 52)
                    .background(Color.background)
                    .cornerRadius(16)
                    .glassEffect(in: .rect(cornerRadius: 16))



                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.system(.headline).weight(.bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.secondary)
            } .padding(16)
                .glassEffect(.regular.tint(.white.opacity(1)), in: .rect(cornerRadius: 16))

        }
    }
}

#Preview {
    PetTypeCard(
        own: true,
        title: "Own a Pet",
        description: "Register your pet family member to track their health and joy.",
        action: {}
    )
}
