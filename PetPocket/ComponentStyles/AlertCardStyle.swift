//
//  AlertCardStyle.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI

struct AlertCardStyle: View {
    let allergies: [String]
    let restricted: [String]

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(gradient: Gradient(colors: [.accentColor.opacity(0.4), .accentColor.opacity(0.1)]), startPoint: .leading, endPoint: .trailing)
                .clipShape(.rect(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 6) {
                //HEADER
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("DIETARY RESTRICTIONS")
                        .font(.subheadline)
                        .bold()
                }.foregroundColor(Color.red)
                
                Text("Allergies: \(allergies.map { "\($0)" }.joined(separator: ", ")).")
                Text("Restricted: \(restricted.map { "\($0)" }.joined(separator: ", ")).")
            }.padding(20)
        }
        
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(/*.regular.tint(Color.accent.opacity(0.25)),*/ in: .rect(cornerRadius: 16))
    }

}

#Preview {
    AlertCardStyle(allergies: ["chocolate"], restricted: ["chicken", "fish", "shellfish"])
        .padding(16)
}
