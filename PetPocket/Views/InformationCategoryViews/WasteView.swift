//
//  WasteView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//

import SwiftUI

struct WasteView: View {
    @Environment(PetDetailStore.self) private var detail
    @State private var isEditing = false
    @State private var editingItem: RoutineCardItem? = nil

    private let headers: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "exclamationmark.triangle.fill", label: "Waste Alert"),
        CategoryHeaderItem(icon: "leaf.fill",                     label: "Waste Routine"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Alert section (always placeholder — no waste alerts in DB yet)
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: headers[0])
                        GhostAlertCard()
                    }

                    // MARK: Routine section
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: headers[1])

                        if detail.wasteItems.isEmpty {
                            GhostRoutineCard(
                                icon: "clock.fill",
                                titlePlaceholder: isEditing ? "Tap + to add a routine" : "Every 4 Hours",
                                descriptionPlaceholder: "Your waste routine will appear here."
                            )
                        } else {
                            ForEach(detail.wasteItems) { item in
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
            .navigationTitle("Waste Routine")
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
    WasteView().environment(PetDetailStore(pet: .sample))
}
