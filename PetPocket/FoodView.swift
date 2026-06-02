//
//  FoodView.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import SwiftUI

struct FoodView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {

                // allergy warning

                DietaryRestrictionBanner(
                    allergies: ["chocolate"],
                    restricted: ["chicken"]
                )

                // routine
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily Feeding Routine")
                        .font(.headline)
                    //                ForEach(mockData, id: \.self) { item in
                    //                    RoutineCard(item: item)
                    //                }
                    RoutineCard(item: mockData[0])
                    RoutineCard(item: mockData[1])
                    RoutineCard(item: mockData[2])
                    
                    //add btn
                    Button(action: {
                        print("add btn pressed")
                    }) {Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            //.foregroundColor(.white)
                            .padding(10)
                            .glassEffect()
                    }
                    
                    //AddInformationCard()
                }
                Spacer()

            }.padding(20)
        }

    }
}

#Preview {
    FoodView()
}
