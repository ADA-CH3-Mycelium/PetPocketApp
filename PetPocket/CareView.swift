//
//  CareView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//

import SwiftUI

struct CareView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {

                // routine
                VStack(alignment: .leading, spacing: 10) {
                    RoutineCard(item: mockData[6])
                    RoutineCard(item: mockData[7])
                    
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
    CareView()
}
