//
//  FoodView.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import SwiftUI

struct FoodView: View {
    @Environment(PetDetailStore.self) private var detail
    @State private var isEditing = false
    @State private var showAddMeal = false
    @State private var editingMeal: RoutineCardItem? = nil
    @State private var showDietaryEdit = false
    
    // headers
    private let headers: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "clock.arrow.circlepath", label: "Daily Feeding Routine"),
        CategoryHeaderItem(icon: "text.pad.header", label: "Additional Notes"),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    if isEditing { EditHintBanner() }

                    // MARK: Alert section
                    VStack(alignment: .leading, spacing: 10) {
                        CategoryHeader(item: headers[0])

                        let dietaryCard = Group {
                            if detail.allergies.isEmpty && detail.restricted.isEmpty {
                                GhostAlertCard()
                            } else {
                                AlertCardStyle(
                                    allergies: detail.allergies,
                                    restricted: detail.restricted
                                )
                            }
                        }

                        if isEditing {
                            Button { showDietaryEdit = true } label: {
                                dietaryCard
                            }
                            .buttonStyle(.plain)
                        } else {
                            dietaryCard
                        }
                    }

                    // MARK: Routine section
                    VStack(alignment: .center, spacing: 10) {
                        CategoryHeader(item: headers[1])

                        if detail.meals.isEmpty {
                            GhostRoutineCard(
                                icon: "fork.knife",
                                titlePlaceholder: isEditing ? "Tap + to add a meal" : "Breakfast • 8:00",
                                descriptionPlaceholder: "Your feeding routine will appear here."
                            )
                        } else {
                            ForEach(detail.meals) { meal in
                                TappableRoutineCard(
                                    item: meal,
                                    isEditing: isEditing,
                                    onEditTap: { editingMeal = $0 }
                                )
                            }
                        }

                        if isEditing {
                            AddCardButton { showAddMeal = true }
                        }
                    }

                    Spacer()
                }.padding(20)
            }
            .navigationTitle("My Food Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditMenuButton(isEditing: $isEditing)
                }
            }
            // Add new meal
            .sheet(isPresented: $showAddMeal) {
                AddMealSheet(detail: detail)
                    .presentationDetents([.large])
                    .presentationCornerRadius(24)
            }
            // Edit existing meal — sheet opens when editingMeal is set
            .sheet(item: $editingMeal) { meal in
                AddMealSheet(detail: detail, editing: meal)
                    .presentationDetents([.large])
                    .presentationCornerRadius(24)
            }
            // Edit dietary restrictions
            .sheet(isPresented: $showDietaryEdit) {
                DietaryEditSheet(detail: detail)
                    .presentationDetents([.large])
                    .presentationCornerRadius(24)
            }
        }
    }
}

#Preview {
    FoodView()
        .environment(PetDetailStore(pet: .sample))
}
