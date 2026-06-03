//
//  AuthHeader.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//


import SwiftUI

struct AuthHeader: View {
    
    //    let imageName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
}
