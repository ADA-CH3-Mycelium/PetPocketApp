//
//  CareView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//

import SwiftUI

struct CareView: View {
    @Environment(PetDetailStore.self) private var detail

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {

                // routine
                VStack(alignment: .leading, spacing: 10) {
                    if detail.careItems.isEmpty {
                        Text("No care notes added yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(detail.careItems) { item in
                            RoutineCard(item: item, isEmergency: false)
                        }
                    }
                }
                Spacer()

            }.padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.primaryG)
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
    CareView().environment(PetDetailStore(pet: .sample))
}
