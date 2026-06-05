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
                    firstAidSection
                    contactsSection
                    clinicsSection
                }.padding(20)
            }
        }
        .navigationTitle("Emergency Guidelines")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.primaryG)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditMenuButton(isEditing: $isEditing)
            }
        }
        // First aid sheets
        .sheet(isPresented: $showAddFirstAid) {
            CareItemSheet(detail: detail, category: "emergency")
                .presentationDetents([.large]).presentationCornerRadius(24)
        }
        .sheet(item: $editingFirstAid) { item in
            CareItemSheet(detail: detail, category: "emergency", editing: item)
                .presentationDetents([.large]).presentationCornerRadius(24)
        }
        // Contact sheets
        .sheet(isPresented: $showAddContact) {
            ContactSheet(detail: detail)
                .presentationDetents([.large]).presentationCornerRadius(24)
        }
        .sheet(item: $editingContact) { item in
            ContactSheet(detail: detail, editing: item)
                .presentationDetents([.large]).presentationCornerRadius(24)
        }
        // Clinic sheets
        .sheet(isPresented: $showAddClinic) {
            ClinicSheet(detail: detail)
                .presentationDetents([.large]).presentationCornerRadius(24)
        }
        .sheet(item: $editingClinic) { item in
            ClinicSheet(detail: detail, editing: item)
                .presentationDetents([.large]).presentationCornerRadius(24)
        }
    }

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
                            .frame(width: 240)
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
                }
            }

            if isEditing {
                AddCardButton { showAddContact = true }
            }
        }
        .navigationTitle("Emergency Guidelines")
        .navigationBarTitleDisplayMode(.inline)

    }

    // MARK: Clinics
    private var clinicsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            CategoryHeader(item: headers[2])

            ForEach(detail.clinics) { item in
                if isEditing {
                    Button { editingClinic = item } label: {
                        VetClinicCard(item: item)
                            .overlay(alignment: .topTrailing) { editBadge }
                    }.buttonStyle(.plain)
                } else {
                    VetClinicCard(item: item)
                }
            }

            if isEditing {
                AddCardButton { showAddClinic = true }
            }
        }
    }

    private var editBadge: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: 22))
            .foregroundStyle(.white, Color.primaryG)
            .padding(6)
    }
}

#Preview {
    EmergencyView()
}
