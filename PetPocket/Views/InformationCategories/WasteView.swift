//
//  WasteView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//  Edited by Samantha Lugay on 04/06/26.
//

import SwiftUI

struct WasteView: View {
    @State private var isEditing: Bool = false
    
    // headers
    private let wasteCategoryHeaders: [CategoryHeaderItem] = [
        CategoryHeaderItem(icon: "clock.arrow.circlepath", label: "Waste Routine"),
        CategoryHeaderItem(icon: "text.pad.header", label: "Behavioural Signs"),
        
    ]
    
    //DB
    var mockWasteAdditionalNotes : [AdditionalNotesCardItem] = [
        AdditionalNotesCardItem(description: "Cooper will sit by the back door and whine when he needs to go")
    ]
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 30) {

                // routne cards
                VStack(alignment: .center, spacing: 10) {
                    // header
                    CategoryHeader(item: wasteCategoryHeaders[0])
                    
                    //items
                    RoutineCard(item: mockData[3], isEmergency: false)
                    RoutineCard(item: mockData[4], isEmergency: false)
                    RoutineCard(item: mockData[5], isEmergency: false)
                    
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
                    //header
                    CategoryHeader(item: wasteCategoryHeaders[1])
                    
                    // items
                    AddNotesStyle(item: mockWasteAdditionalNotes[0])

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
        }

    }
}

#Preview {
    WasteView()
}
