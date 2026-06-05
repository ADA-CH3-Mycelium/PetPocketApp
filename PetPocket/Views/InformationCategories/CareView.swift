//
//  CareView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//  Edited by Samantha Lugay on 04/06/26.
//

import SwiftUI

struct CareView: View {
    @State private var isEditing: Bool = false
    // headers
    private let careCategoryHeaders: [CategoryHeaderItem] = [
        CategoryHeaderItem(
            icon: "clock.arrow.circlepath",
            label: "Prioirity things to look out for"
        ),
        CategoryHeaderItem(icon: "text.pad.header", label: "Additional Notes"),

    ]

    //DB
    var mockCareAdditionalNotes: [AdditionalNotesCardItem] = [
        AdditionalNotesCardItem(
            description:
                "Oliver will pace at night if his favorite blanket isn't in his crate.Please check the laundry if missing."
        )
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 30) {

                // routine
                VStack(alignment: .center, spacing: 10) {
                    // header
                    CategoryHeader(item: careCategoryHeaders[0])
                    // items
                    RoutineCard(item: mockData[6], isEmergency: false)
                    RoutineCard(item: mockData[7], isEmergency: false)

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
        }
    }
}

#Preview {
    CareView()
}
