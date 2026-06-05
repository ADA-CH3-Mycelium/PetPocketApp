//
//  EmergencyView.swift
//  PetPocket
//
//  Created by Samantha Lugay on 02/06/26.
//

import MapKit
import SwiftUI

struct EmergencyView: View {
    @State private var isEditing: Bool = false
    // mock data
    // first aid data
    private var mockFirstAidData: [RoutineCardItem] = [
        RoutineCardItem(
            title: "Choking",
            time: "",
            description:
                "Look out for pawing at mouth, pale gums, inability to breathe.",
            icon: "lungs.fill"
        ),
        RoutineCardItem(
            title: "Poisoning",
            time: "",
            description: "Vomiting, drooling, unusual behavior.",
            icon: "pills.fill"
        ),
    ]

    //  additional notes
    private var mockEmergencyAdditionalNotes: [AdditionalNotesCardItem] = []

    // headers
    private let emergencyCategoryHeaders: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "cross.vial.fill", label: "Home Remedies"),
        CategoryHeaderItem(
            icon: "person.circle.fill",
            label: "Trusted Contacts"
        ),
        CategoryHeaderItem(
            icon: "cross.case.fill",
            label: "Trusted Vet Clinics"
        ),
        CategoryHeaderItem(icon: "text.pad.header", label: "Additional Notes"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {

                    // First Aid Guide
                    VStack(alignment: .leading, spacing: 10) {
                        // header
                        CategoryHeader(item: emergencyCategoryHeaders[0])

                        // items
                        RoutineCard(
                            item: mockFirstAidData[0],
                            isEmergency: true
                        )

                        RoutineCard(
                            item: mockFirstAidData[1],
                            isEmergency: true
                        )
                        
                        //add btn
                        if isEditing {
                            Button(action: {
                                print("add new routine card btn pressed")
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .padding(10)
                                    .glassEffect()
                            }.padding(.bottom, 20)
                        }

                    }

                    // Contacts
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: emergencyCategoryHeaders[1])

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

                    // ADDITIONAL NOTES
                    if mockEmergencyAdditionalNotes != [] {

                        // header
                        VStack(spacing: 10) {
                            CategoryHeader(item: emergencyCategoryHeaders[1])

                            ForEach(mockEmergencyAdditionalNotes) { item in
                                AddNotesStyle(item: item)
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
    EmergencyView()
}
