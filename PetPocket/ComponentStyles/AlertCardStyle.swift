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
        VStack(alignment: .leading, spacing: 6) {
            //HEADER
            HStack(spacing: 2) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("CRITICAL DIETARY RESTRICTIONS")
                    .font(.caption)
                    .bold()
            }.foregroundColor(Color.alertRed)
            
            Text("ALLERGIES: \(allergies.map { "No \($0)" }.joined(separator: ", ")).")
                .font(.caption)
            Text("RESTRICTED: \(restricted.map { "\($0)" }.joined(separator: ", ")).")
                .font(.caption)
        }
        
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(Color.alertRed.opacity(0.1)), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.alertRed.opacity(0.3), lineWidth: 1)
        )
    }

}

#Preview {
    AlertCardStyle(allergies: ["chocolate"], restricted: ["chicken", "fish", "shellfish"])
}
