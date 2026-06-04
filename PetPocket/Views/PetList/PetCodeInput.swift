//
//  ConectPastePetCode.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI

struct PetCodeInput: View {
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header text
                VStack(spacing: 6) {
                    Text("Connect with Pet Owner")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Start caring for their pet friend together")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Code input card
                VStack(alignment: .leading, spacing: 12) {
                    Text("PawPocket Code")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    HStack(spacing: 10) {
                        TextField("000 000", text: $code)
                            .font(.system(size: 22, weight: .semibold, design: .monospaced))
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button(action: {
                            if let clipboard = UIPasteboard.general.string {
                                code = clipboard
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 15, weight: .medium))
                                Text("Paste")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(.primaryApp)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    Text("Enter the 6-digit code shared by the pet owner.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)

                // Join button
                Button(action: {
                    // Join action
                }) {
                    Text("Join Pet Profile")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: 220)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.primaryApp)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 40)

                // Help card
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.primaryApp)
                        Text("Where do I find the code?")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryApp)
                    }

                    Text("The pet owner can generate this code in their Pet Settings > Share Access. Codes are valid for 24 hours.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
            }
            .padding(20)
        }
        .background(Color(.background))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primaryApp)
                        Text("Back")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.primaryApp)
                        
                    }
                    .foregroundColor(.accentColor)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("PawPocket")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryApp)
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        PetCodeInput()
    }
}
