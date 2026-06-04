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
    VetClinicCardItem(name: "Oakwood Veterinary Clinic", address: "1240 Oakwood Ave, Brookside, NY 10012", phone: "(555) 012-3456", note: "their 24/7 emergency line, see dr. michel")
]

// MARK: - CONTACT CARD
struct ContactCard: View {
    //read colour mode
    @Environment(\.colorScheme) var colorScheme

    let contact: ContactCardItem

    var body: some View {
        HStack(spacing: 12) {
            // initial bubble
//            Text(mockContact[0].initial)
//                .font(.title2)
//                .fontWeight(.semibold)
//                .foregroundStyle(Color.primaryG)
//                .frame(width: 44, height: 44)
//                .glassEffect()

            // text
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 2) {
                    Image(systemName: "sparkle")
                        .font(.subheadline)
                        .foregroundColor(Color.primaryG)
                    Text(contact.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryG)

                    Spacer()

                    Text(contact.relationship.uppercased())
                        .font(.caption)
                        .foregroundStyle(.accent)
                }
                
                HStack(spacing: 2) {

                    Text(contact.phone)
                        .font(.caption)
                    
                    Button {
                        print("copy phone num pressed")
                    } label: {
                        Image(systemName: "square.on.square")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                                        
                }
                
                Text(contact.note)
                    .font(.body)
                    .padding(.top, 5)
                    .foregroundStyle(.gray)
            }

            // call btn
//            Image(systemName: "phone.fill")
//                .foregroundColor(Color.green)
//                .frame(width: 44, height: 44)
//                .glassEffect()
            

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
                //name
                HStack(spacing: 2) {
                    Image(systemName: "cross.case.fill")
                        .font(.subheadline)
                    Text(item.name)
                        .font(.headline)
                    
                }
                .fontWeight(.bold)
                .foregroundColor(Color.primaryG)

                //address
                Text(item.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // phone number
                HStack(spacing: 2) {
                    Text(item.phone)
                        
                    Button {
                        print("copy vet phone num pressed")
                    } label: {
                        Image(systemName: "square.on.square")
                    }
                    
                }
                .font(.caption)
                    .foregroundStyle(.secondary)
                
                
                    // call btn
//                    Button(action: {}) {
//                        HStack(spacing: 6) {
//                            Image(systemName: "phone.fill")
//                            Text("Call Vet")
//                        }
//                        .font(.caption)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 7)
//                        .glassEffect(in: .rect(cornerRadius: 12))
//                    }

                // map — only when real coordinates are set
                if let lat = item.latitude, let lon = item.longitude {
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                    Map(initialPosition: .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )) {
                        Marker(item.name, coordinate: coord)
                            .tint(Color.primaryG)
                    }
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)

                    // hyperlink — opens Apple Maps at the clinic coordinate
                    HStack {
                        Spacer()
                        if let url = mapsURL(lat: lat, lon: lon, name: item.name) {
                            Link("Open in Maps \(Image(systemName: "arrow.up.forward.app"))", destination: url)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.slash")
                        Text("No location set")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(greenEdgeCard())

    }

    private func mapsURL(lat: Double, lon: Double, name: String) -> URL? {
        let q = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Vet+Clinic"
        return URL(string: "http://maps.apple.com/?ll=\(lat),\(lon)&q=\(q)")
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
