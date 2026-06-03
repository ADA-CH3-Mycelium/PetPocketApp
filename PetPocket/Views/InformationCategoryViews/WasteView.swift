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
                    Text("No waste routine added yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()

            }.padding(20)
        }
    }
}

#Preview {
    WasteView()
}
