//
//  DietaryRestrictionBanner.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

struct DietaryRestrictionBanner: View {
    let allergies: [String]
    let restricted: [String]

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 30))
                .foregroundColor(.ppEmergencyRed)


            VStack(alignment: .leading, spacing: 3) {

                Text("CRITICAL DIETARY RESTRICTIONS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.ppEmergencyRed)
                    .kerning(0.3)


                Text("ALLERGIES: \(allergies.map { "No \($0)" }.joined(separator: ", ")).")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.ppEmergencyRed)


                Text("RESTRICTED: \(restricted.joined(separator: ", ")).")
                    .font(.caption)
                    .foregroundColor(.ppEmergencyRed.opacity(0.85))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.ppDietaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.ppEmergencyRed.opacity(0.55), lineWidth: 1.5)
        )
    }
}

// MARK: - Preview
#Preview {
    DietaryRestrictionBanner(
        allergies: ["Chicken"],
        restricted: ["Grapes", "Chocolate", "Onion"]
    )
    .padding()
}
