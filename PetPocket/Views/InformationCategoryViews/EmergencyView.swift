//
//  EmergencyView.swift
//  PetPocket
//
//  Created by Samantha Lugay on 02/06/26.
//

import MapKit
import SwiftUI

struct EmergencyView: View {
    // mock data
    // first aid data
    private var mockFirstAidData: [RoutineCardItem] = [
        RoutineCardItem(
            title: "Choking",
            time: "",
            description:
                "Signs: Pawing at mouth, pale gums, inability to breathe.",
            icon: "lungs.fill"
        ),
        RoutineCardItem(
            title: "Poisoning",
            time: "",
            description: "Signs: Vomiting, drooling, unusual behavior.",
            icon: "pills.fill"
        ),
    ]
    
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
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: emergencyCategoryHeaders[0])

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                RoutineCard(item: mockFirstAidData[0], isEmergency: true)
                                    .frame(width: 240)

                                RoutineCard(item: mockFirstAidData[1], isEmergency: true)
                                    .frame(width: 240)

                            }

                        }.scrollClipDisabled()
                    }

                    // Contacts
                    VStack(alignment: .leading, spacing: 10){
                        CategoryHeader(item: emergencyCategoryHeaders[2])
                        
                        VStack(spacing: 12) {
                            ForEach(mockContact, id: \.self) { contact in
                                ContactCard(contact: contact)
                            }
                        }
                    } 
                    
                    // clinic
                    VStack {
                        CategoryHeader(item: emergencyCategoryHeaders[2])
                        ForEach(mockVetClinicItem) { item in
                            VetClinicCard(item: item)
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
    EmergencyView()
}
