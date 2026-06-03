//
//  PetPocketTopBar.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 02/06/26.
//


import SwiftUI

struct TopBar: View {
    let title: String
    let onBackAction: () -> Void
    let onMenuAction: () -> Void
    
    var body: some View {
        HStack {
            // 1. Custom Left Back Button
            Button(action: onBackAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.primaryG)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
            
            // 2. Centered Page Title
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 3. Custom Right Menu Options Button
            Button(action: onMenuAction) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90)) // Turns standard dots into vertical layout match
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.primaryG) // Uses your custom green tone
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear) // Translucent backdrops inherit layout contexts nicely
    }
}
