//
//  CustomTextField.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//


import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)

                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}
