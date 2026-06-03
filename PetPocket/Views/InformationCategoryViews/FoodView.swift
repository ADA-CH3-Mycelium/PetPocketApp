//
//  FoodView.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import SwiftUI

struct FoodView: View {
    @Environment(PetDetailStore.self) private var detail
    @State var isEditing: Bool = false

    // headers
    private let foodCategoryHeaders: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "clock.arrow.circlepath", label: "Daily Feeding Routine"),
        CategoryHeaderItem(icon: "text.pad.header", label: "Additional Notes"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {

                    // ALLERGY WARNING — hidden when pet has no dietary restrictions
                    if !detail.allergies.isEmpty || !detail.restricted.isEmpty {
                        AlertCardStyle(
                            allergies: detail.allergies,
                            restricted: detail.restricted
                        )
                    }

                    // DAILY FEEDING ROUTINE
                    VStack(alignment: .center, spacing: 10) {
                        CategoryHeader(item: foodCategoryHeaders[0])

                        if detail.meals.isEmpty {
                            Text("No feeding routine added yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(detail.meals) { meal in
                                RoutineCard(item: meal, isEmergency: false)
                            }
                        }

                        // add btn (editing mode placeholder — Phase 3 write-back)
                        if isEditing {
                            Button(action: {
                                print("add btn pressed")
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .padding(10)
                                    .glassEffect()
                            }
                        }
                    }

                    Spacer()

                }.padding(20)
            }
            .navigationTitle(Text("My Food Routine"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FoodView()
        .environment(PetDetailStore(pet: .sample))
}
