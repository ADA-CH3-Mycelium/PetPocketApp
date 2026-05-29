//
//  GenerateCodeView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//


import SwiftUI

struct GenerateCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var codeString = "618 882"
    @State private var copyStatusFeedback = "Copy"
    
    var body: some View {
        NavigationStack {
            ZStack {
                PawPocketTheme.backgroundCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Connect with Pet Sitter")
                            .font(.title2)
                            .bold()
                            .foregroundColor(PawPocketTheme.textDark)
                        Text("Start sharing your pet's information with the sitter.")
                            .font(.subheadline)
                            .foregroundColor(PawPocketTheme.textSecondary)
                    }
                    .padding(.top, 40)
                    
                    // Central Numeric Key Area Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Collaboration Code")
                            .font(.caption)
                            .bold()
                            .foregroundColor(PawPocketTheme.textSecondary)
                        
                        HStack(spacing: 0) {
                            Text(codeString)
                                .font(.system(.title, design: .monospaced))
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            
                            // High-Accessibility Sized Action Button
                            Button(action: {
                                UIPasteboard.general.string = codeString
                                copyStatusFeedback = "Copied!"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    copyStatusFeedback = "Copy"
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc.fill")
                                    Text(copyStatusFeedback)
                                        .font(.caption2)
                                        .bold()
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 80, height: 68)
                                .background(PawPocketTheme.accentOrange)
                                .cornerRadius(10)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Text("Share the 6-digit code to the pet sitter.")
                            .font(.caption)
                            .foregroundColor(PawPocketTheme.textSecondary)
                    }
                    .padding()
                    .background(PawPocketTheme.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 10)
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(PawPocketTheme.primaryGreen)
                }
            }
        }
    }
}

#Preview {
    GenerateCodeView()
}