//
//  EmergencyViewStyles.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI

var mockContact: [ContactCardItem] = [
    ContactCardItem(
        name: "Naufal",
        relationship: "neighbour",
        note: "Has spare keys",
        phone: "09123456789"
    ),
    ContactCardItem(
        name: "Cheisha",
        relationship: "mum",
        note: "can help, knows everything",
        phone: "09123456789"
    ),
]

struct ContactCard: View {

    let contact: ContactCardItem

    var body: some View {
        HStack(spacing: 12) {
            // initial bubble
            Text(mockContact[0].initial)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .glassEffect()
                .background(Color.orange)
                .clipShape(Circle())

            // text
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(contact.name)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Spacer()

                    Text(contact.relationship.uppercased())
                        .font(.caption)

                        .foregroundStyle(.gray)
                }

                Text(contact.note)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            // call btn
            Image(systemName: "phone.fill")
                .foregroundStyle(Color.white)
                .frame(width: 44, height: 44)
                .glassEffect()
                .background(Color.green)
                .clipShape(Circle())
        }
        .padding()
        .glassEffect(
            .regular.tint(.accent.opacity(0.1)),
            in: .rect(cornerRadius: 16)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        ContactCard(contact: mockContact[0])
        ContactCard(contact: mockContact[1])
    }
    .padding()
    .background(Color.background).ignoresSafeArea()
}
