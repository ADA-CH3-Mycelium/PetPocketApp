//
//  GenerateCodeView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//

import SwiftUI

struct GenerateCodeView: View {
    @Environment(\.dismiss) var dismiss

    @State private var codeString = "------"
    @State private var copyStatusFeedback = "Copy"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Connect with Pet Sitter")
                            .font(.title2)
                            .bold()
                        Text("Start sharing your pet's information with the sitter.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 1)
                    
                    // Code card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Collaboration Code")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 0) {
                            Text(codeString)
                                .font(.system(.title, design: .monospaced))
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            
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
                                .background(.accent)
                                .cornerRadius(10)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Text("Share the 6-digit code to the pet sitter. Valid for 48 hours.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.accent.opacity(0.1))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 10)

                    Spacer()
                }
                .padding()
            }
            .onAppear { generateLocalCode() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .bold(true)
                            .foregroundColor(Color.primaryG.opacity(0.8))
                            .frame(width: 36, height: 36)
                    }
                }
            }
        }
    }

    /// Generate dummy 6-digit code locally.
    /// Real implementation akan call Supabase generate access code endpoint.
    private func generateLocalCode() {
        guard codeString == "------" else { return }
        let code = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
        codeString = code
    }
}

#Preview {
    GenerateCodeView()
}
