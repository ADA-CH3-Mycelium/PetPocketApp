//
//  EmergencyViewStyles.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI
import MapKit

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
        note: "can help, knows everything wallahi",
        phone: "09123456789"
    ),
]

var mockVetClinicItem: [VetClinicCardItem] = [
    VetClinicCardItem(name: "Oakwood Veterinary Clinic", address: "1240 Oakwood Ave, Brookside, NY 10012", phone: "(555) 012-3456", note: "24/7 Emergency Line")
]

// MARK: - CONTACT CARD
struct ContactCard: View {
    //read colour mode
    @Environment(\.colorScheme) var colorScheme

    let contact: ContactCardItem

    var body: some View {
        HStack(spacing: 12) {
            // initial bubble
            Text(contact.initial)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .glassEffect()
                .background(Color.primaryG)
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
                .foregroundStyle(Color.green)
                .frame(width: 44, height: 44)
                .glassEffect()
//                .background(Color.green)
//                .clipShape(Circle())
        }
        .padding()
        .glassEffect(
            .regular.tint(colorScheme == .dark ? .clear :.accent.opacity(0.02)),
            in: .rect(cornerRadius: 16)
        )
    }
}

// MARK: - VET CARD
struct VetClinicCard: View {
    let item: VetClinicCardItem
    var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                // text
                Text(item.name)
                    .font(.headline)

                Text(item.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(item.note.isEmpty ? item.phone : item.phone + " • \(item.note)")
                    .font(.caption)
                    .foregroundStyle(.secondary)


                    // call btn
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("Call Vet")
                        }
                        .font(.caption)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .glassEffect(in: .rect(cornerRadius: 12))
                    }

                // map
                Map(
                    initialPosition: .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: 40.7128,
                                longitude: -74.0060
                            ),
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.05,
                                longitudeDelta: 0.05
                            )
                        )
                    )
                )
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
                
                // hyperlink
                HStack {
                    Spacer()
                    
                    Link("Open in Maps \(Image(systemName: "arrow.up.forward.app"))", destination: URL(string: "https://www.google.com/maps/place/Oakwood+Veterinary+Clinic/@42.7555251,-73.6713186,17z/data=!3m2!4b1!5s0x89de0fef7133a4cd:0x57986344fe15209d!4m6!3m5!1s0x89de0fef7985b2e1:0x9bc46f9d77e6bcde!8m2!3d42.7555212!4d-73.6687437!16s%2Fg%2F1w4vky7d?entry=ttu&g_ep=EgoyMDI2MDUyNy4wIKXMDSoASAFQAw%3D%3D")!)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(greenEdgeCard())

    }
}

#Preview {
    VStack(spacing: 12) {
        ContactCard(contact: mockContact[0])
        ContactCard(contact: mockContact[1])
        VetClinicCard(item: mockVetClinicItem[0])
    }
    .padding()
    .background(Color.background).ignoresSafeArea()
}
