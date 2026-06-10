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

    @State private var isEditing = false

    // First aid (care_items, category = "emergency")
    @State private var showAddFirstAid = false
    @State private var editingFirstAid: RoutineCardItem? = nil
    // Contacts
    @State private var showAddContact = false
    @State private var editingContact: ContactCardItem? = nil
    // Clinics
    @State private var showAddClinic = false
    @State private var editingClinic: VetClinicCardItem? = nil

    private let headers: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "cross.vial.fill",    label: "First Aid Guides"),
        CategoryHeaderItem(icon: "person.circle.fill", label: "Trusted Contacts"),
        CategoryHeaderItem(icon: "cross.case.fill",    label: "Trusted Vet Clinics"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    if isEditing { EditHintBanner() }
                    firstAidSection
                    contactsSection
                    clinicsSection
                }.padding()
            }
        }
        .navigationTitle("My Emergency Guidelines")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.primaryG)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditMenuButton(isEditing: $isEditing)
                    .tint(.black)
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

    // MARK: First aid
    private var firstAidSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            CategoryHeader(item: headers[0])

            if detail.firstAid.isEmpty {
                if !isEditing {
                    GhostRoutineCard(icon: "cross.vial.fill",
                                     titlePlaceholder: "Choking",
                                     descriptionPlaceholder: "First-aid guides will appear here.")
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(detail.firstAid) { item in
                        RoutineCard(item: item, isEmergency: true)
                            .overlay {
                                if isEditing {
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture { editingFirstAid = item }
                                }
                            }
                    }
                }
            }

            if isEditing {
                AddCardButton { showAddFirstAid = true }
            }
        }
    }

    // MARK: - Contacts
    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            CategoryHeader(item: headers[1])

            VStack(spacing: 12) {
                ForEach(detail.contacts, id: \.self) { contact in
                    ContactCard(contact: contact)
                        .overlay {
                            if isEditing {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingContact = contact }
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

    // MARK: - Clinics
    private var clinicsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            CategoryHeader(item: headers[2])

            ForEach(detail.clinics) { item in
                VetClinicCard(item: item)
                    .overlay {
                        if isEditing {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { editingClinic = item }
                        }
                    }
            }

            if isEditing {
                AddCardButton { showAddClinic = true }
            }
        }
    }}

#Preview {
    EmergencyView()
}
