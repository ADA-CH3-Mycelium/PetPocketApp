//
//  CareView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//

import SwiftUI

struct CareView: View {
    @Environment(PetDetailStore.self) private var detail
    @State private var isEditing = false
    @State private var editingItem: RoutineCardItem? = nil

    private let headers: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "exclamationmark.triangle.fill", label: "Care Alert"),
        CategoryHeaderItem(icon: "heart.text.square.fill",        label: "Care Routine"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Alert section (always placeholder — no care alerts in DB yet)
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: headers[0])
                        GhostAlertCard()
                    }

                    // MARK: Routine section
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: headers[1])

                        if detail.careItems.isEmpty {
                            GhostRoutineCard(
                                icon: "heart.text.square",
                                titlePlaceholder: isEditing ? "Tap + to add a care note" : "Critical Medication • July 1st",
                                descriptionPlaceholder: "Your care notes will appear here."
                            )
                        } else {
                            ForEach(detail.careItems) { item in
                                TappableRoutineCard(
                                    item: item,
                                    isEditing: isEditing,
                                    onEditTap: { editingItem = $0 }
                                )
                            }
                        }

                        if isEditing {
                            AddCardButton { }   // wire add sheet in Phase 4
                        }
                    }

                    Spacer()
                }.padding(20)
            }
            .navigationTitle("Care Notes")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.primaryG)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditMenuButton(isEditing: $isEditing)
                }
            }
        }
    }
}

#Preview {
    CareView().environment(PetDetailStore(pet: .sample))
}
