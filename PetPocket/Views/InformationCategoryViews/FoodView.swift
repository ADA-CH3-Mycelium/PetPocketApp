//
//  FoodView.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import SwiftUI

struct FoodView: View {
    @State var isEditing: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 30) {
                
                //                TopBar(
                //                    title: "My Food Routine", // Pass whatever dynamic string category context you need here
                //                    onBackAction: {
                //                        dismiss() // Safely triggers native back pop movement action
                //                    },
                //                    onMenuAction: {
                //                        print("Menu action sheet button pressed")
                //                        // Handle editing options logic here
                //                    }
                //                )
                
                // ALLERGY WARNING
                AlertCardStyle(
                    allergies: ["chocolate"],
                    restricted: ["chicken", "fish", "shellfish"]
                )
                
                // ROUTINE
                VStack(alignment: .center, spacing: 10) {
                    
                    // header
                    HStack {
                        Text("Daily Feeding Routine")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    // cards
                    //                ForEach(mockData, id: \.self) { item in
                    //                    RoutineCard(item: item)
                    //                }
                    RoutineCard(item: mockData[0])
                    RoutineCard(item: mockData[1])
                    RoutineCard(item: mockData[2])
                    
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
                Spacer()
                
            }.padding(20)
        }
        .navigationTitle(Text("My Food Routine"))
        //.navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.primaryG)
        .accentColor(Color.primaryG)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("Edit information", systemImage: "pencil")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundColor(Color.primaryG)
                }
                
            }
        }
    }
}

#Preview {
    FoodView()
}
