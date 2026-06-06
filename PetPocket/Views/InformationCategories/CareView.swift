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
    @State private var showAddItem = false
    @State private var editingItem: RoutineCardItem? = nil

    private let headers: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "heart.text.square.fill", label: "Care Routine"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    if isEditing { EditHintBanner() }

                    // MARK: Routine section
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: headers[0])

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
                            AddCardButton { showAddItem = true }
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
<<<<<<< HEAD
            }
            .sheet(isPresented: $showAddItem) {
                CareItemSheet(detail: detail, category: "care")
                    .presentationDetents([.large])
                    .presentationCornerRadius(24)
            }
            .sheet(item: $editingItem) { item in
                CareItemSheet(detail: detail, category: "care", editing: item)
                    .presentationDetents([.large])
                    .presentationCornerRadius(24)
            }
=======

                VStack(alignment: .center, spacing: 10) {
                    // header
                    CategoryHeader(item: careCategoryHeaders[1])

                    // items
                    AddNotesStyle(item: mockCareAdditionalNotes[0])

                    //add btn
                    if isEditing {
                        Button(action: {
                            print("add additional notes btn pressed")
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .padding(10)
                                .glassEffect()
                        }.padding(.bottom, 20)
                    }
                }

                Spacer()

            }.padding(20)
                .navigationTitle("My Additional Care Notes")
            .navigationBarTitleDisplayMode(.inline)
                // edit btn
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Image(systemName: "pencil")

                        }
                    }
                }
>>>>>>> ec7ca579bc04693ee540ef2bbcd2a101c549c504
        }
    }
}

#Preview {
    CareView()
}
