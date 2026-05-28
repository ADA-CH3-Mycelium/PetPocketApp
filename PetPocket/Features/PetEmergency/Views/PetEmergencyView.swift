//
//  PetEmergencyView.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 29/05/26.
//

import SwiftUI

struct PetEmergencyView: View {
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image("Cooper")
                    .resizable()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .padding()
                    .offset(x: 150)
            }

            Text("Cooper")
                .font(.title)
                .fontWeight(.semibold)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: 12
            ) {
                InfoCard(label: "AGE", value: "3 years")
                InfoCard(label: "GENDER", value: "Male")
                InfoCard(label: "BREED", value: "Golden Retriever")
                InfoCard(label: "SPECIES", value: "Dog")
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    PetEmergencyView()
}

struct InfoCard: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .fontWeight(.semibold)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
