//
//  WasteView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//

import SwiftUI

struct WasteView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {

                // Waste
                VStack(alignment: .leading, spacing: 10) {
                    RoutineCard(item: mockData[3])
                    RoutineCard(item: mockData[4])
                    RoutineCard(item: mockData[5])
                    
                    //add btn
                    Button(action: {
                        print("add btn pressed")
                    }) {Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(10)
                            .glassEffect()
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
