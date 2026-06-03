//
//  GenerateCodeView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//

import SwiftUI

struct GenerateCodeView: View {
    @Environment(\.dismiss) var dismiss

//    let petId: UUID

    @State private var codeString = "------"
    @State private var copyStatusFeedback = "Copy"
    @State private var isGenerating = false
    @State private var errorMessage: String?

    var body: some View {
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
                    
                    // Central Numeric Key Area Card
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
                                .background(.accent)
                                .cornerRadius(10)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Text(isGenerating
                             ? "Generating a fresh code…"
                             : "Share the 6-digit code to the pet sitter. Valid for 48 hours.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(.accent.opacity(0.1))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 10)

                    Spacer()
                }
                .padding()
            }
            .task {
//                await generate()
            }
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
//                            .background(
//                                ZStack {
//                                    Circle()
//                                        .fill(.ultraThinMaterial)
//                                    
//                                    Circle()
//                                        .fill(
//                                            LinearGradient(
//                                                colors: [Color.white.opacity(0.6), Color.white.opacity(0.05)],
//                                                startPoint: .topLeading,
//                                                endPoint: .bottomTrailing
//                                            )
//                                        )
//                                    
//                                    Circle()
//                                        .stroke(
//                                            LinearGradient(
//                                                colors: [Color.white.opacity(0.7), Color.white.opacity(0.2), Color.black.opacity(0.05)],
//                                                startPoint: .topLeading,
//                                                endPoint: .bottomTrailing
//                                            ),
//                                            lineWidth: 1
//                                        )
//                                }
//                            )
//                            .clipShape(Circle()) 
//                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
//                    .buttonStyle(.plain)                    .frame(width: 44, height: 44)
                }
            }
        
    }

//    private func generate() async {
//        guard codeString == "------" else { return }   // only once
//        isGenerating = true
//        errorMessage = nil
//        do {
//            codeString = try await PetRepository.shared.generateAccessCode(petId: petId)
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        isGenerating = false
//    }
}

#Preview {
    GenerateCodeView()
}
