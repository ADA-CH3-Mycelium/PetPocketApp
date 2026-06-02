//
//  PetTypeCard.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI

struct PetTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(Color.accentColor)
                    )

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PetTypeCard(
        icon: "PetASitIcon",
        title: "Own a Pet",
        description: "Register your pet family member to track their health and joy.",
        action: {}
    )
}
