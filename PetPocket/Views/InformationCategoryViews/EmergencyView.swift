//
//  EmergencyView.swift
//  PetPocket
//
//  Created by Samantha Lugay on 02/06/26.
//

import MapKit
import SwiftUI

struct EmergencyView: View {
    @Environment(PetDetailStore.self) private var detail

    // headers
    private let emergencyCategoryHeaders: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "cross.vial.fill", label: "First Aid Guides"),
        CategoryHeaderItem(icon: "person.circle.fill", label: "Trusted Contacts"),
        CategoryHeaderItem(icon: "cross.case.fill", label: "Trusted Vet Clinics")
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {

                    // First Aid Guide
                    if !detail.firstAid.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            CategoryHeader(item: emergencyCategoryHeaders[0])

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(detail.firstAid) { item in
                                        RoutineCard(item: item, isEmergency: true)
                                            .frame(width: 240)
                                    }
                                }
                            }.scrollClipDisabled()
                        }
                    }

                    // Contacts
                    if !detail.contacts.isEmpty {
                        VStack(alignment: .leading, spacing: 10){
                            CategoryHeader(item: emergencyCategoryHeaders[1])

                            VStack(spacing: 12) {
                                ForEach(detail.contacts, id: \.self) { contact in
                                    ContactCard(contact: contact)
                                }
                            }
                        }
                    }

                    // clinic
                    if !detail.clinics.isEmpty {
                        VStack {
                            CategoryHeader(item: emergencyCategoryHeaders[2])
                            ForEach(detail.clinics) { item in
                                VetClinicCard(item: item)
                            }
                        }
                    }

                }.padding(20)
            }
        }
        .navigationTitle("Emergency Guidelines")
        .navigationBarTitleDisplayMode(.inline)

    }
}

#Preview {
    EmergencyView().environment(PetDetailStore(pet: .sample))
}
