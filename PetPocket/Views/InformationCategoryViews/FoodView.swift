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
    
    //DB
    var mockFoodAdditionalNotes : [AdditionalNotesCardItem] = [
        AdditionalNotesCardItem(description: "gotta do a trick with him before he eats.")
    ]

    var body: some View {

            ZStack {
                        Color.background.ignoresSafeArea()
                        VStack(alignment: .leading, spacing: 30) {

                            // ALLERGY WARNING
                            if !detail.allergies.isEmpty || !detail.restricted.isEmpty {
                                AlertCardStyle(
                                    allergies: detail.allergies,
                                    restricted: detail.restricted
                                )
                            }

                            // ROUTINE
                            VStack(alignment: .center, spacing: 10) {

                                // header
                                CategoryHeader(item: foodCategoryHeaders[0])

                                // cards
                                if detail.meals.isEmpty {
                                    Text("No feeding routine added yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ForEach(detail.meals) { item in
                                        RoutineCard(item: item, isEmergency: false)
                                    }
                                }

                                //add btn
                                if isEditing {
                                    Button(action: {
                                                            print("add btn pressed")
                                                        }) {
                                                            Image(systemName: "plus")
                                                                .font(.system(size: 24, weight: .semibold))
                                                                //.foregroundColor(.white)
                                                                .padding(10)
                                                                .glassEffect()
                                                        }
                                }
                                

                                //AddInformationCard()
                            }
                        }
                        
                    }
                    
                    // ADDITIONAL NOTES
                    if mockFoodAdditionalNotes != [] {
                        
                        // header
                        CategoryHeader(item: foodCategoryHeaders[1])
                        
                        ForEach(mockFoodAdditionalNotes) { item in
                            AddNotesStyle(item: item)
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
    FoodView().environment(PetDetailStore(pet: .sample))
}
