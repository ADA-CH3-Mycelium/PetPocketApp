//
//  WasteView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//

import SwiftUI

struct WasteView: View {
    @Environment(PetDetailStore.self) private var detail

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {

                // Waste
                VStack(alignment: .leading, spacing: 10) {
                    if detail.wasteItems.isEmpty {
                        Text("No waste routine added yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(detail.wasteItems) { item in
                            RoutineCard(item: item, isEmergency: false)
                        }
                    }
                }
                Spacer()

            }.padding(20)
        }

    }
}

#Preview {
    WasteView().environment(PetDetailStore(pet: .sample))
}
