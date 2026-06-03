//
//  EmergencyView.swift
//  PetPocket
//
//  Created by Samantha Lugay on 02/06/26.
//

import MapKit
import SwiftUI

struct EmergencyView: View {

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    Text("No emergency info added yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(20)
            }
        }
        .navigationTitle("Emergency Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EmergencyView()
}
