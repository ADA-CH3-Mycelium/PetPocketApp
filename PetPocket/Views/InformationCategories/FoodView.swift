//
//  FoodView.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import SwiftUI

struct FoodView: View {
    @State private var isEditing: Bool = true
    
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
                
                ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 30) {
                    
                    // ALLERGY WARNING
                    AlertCardStyle(
                        allergies: ["chocolate"],
                        restricted: ["chicken", "fish", "shellfish"]
                    )
                    
                    // ROUTINE
                    VStack(alignment: .center, spacing: 10) {
                        
                        // header
                        CategoryHeader(item: foodCategoryHeaders[0])
                        
                        // cards
                        //                                                ForEach(mockData, id: \.self) { item in
                        //                                                    RoutineCard(item: item)
                        //                                                }
                        RoutineCard(item: mockData[0], isEmergency: false)
                        RoutineCard(item: mockData[1], isEmergency: false)
                        RoutineCard(item: mockData[2], isEmergency: false)
                        
                        //add btn
                        if isEditing {
                            Button(action: {
                                print("add routine card btn pressed")
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                //.foregroundColor(.white)
                                    .padding(10)
                                    .glassEffect()
                            }.padding(.bottom, 20)
                        }
                        
                    }
                    
                    // ADDITIONAL NOTES
                    if mockFoodAdditionalNotes != [] {
                        
                        // header
                        VStack(spacing: 10){
                            //header
                            CategoryHeader(item: foodCategoryHeaders[1])
                            
                            // items
                            ForEach(mockFoodAdditionalNotes) { item in
                                AddNotesStyle(item: item)
                            }
                            
                            //add btn
                            if isEditing {
                                Button(action: {
                                    print("add routine card btn pressed")
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .semibold))
                                    //.foregroundColor(.white)
                                        .padding(10)
                                        .glassEffect()
                                }.padding(.bottom, 20)
                            }
                        }
                        
                    }
                    Spacer()
                    
                }.padding(20)
            }
            .navigationTitle(Text("My Food Routine"))
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
            
        }
        
        

    }
}

#Preview {
    FoodView()
}
