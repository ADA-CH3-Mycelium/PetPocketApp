//
//  GenerateCodeView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//

import SwiftUI

struct GenerateCodeView: View {
    @Environment(\.dismiss) var dismiss

    @State private var vm: GenerateCodeViewModel
    @State private var copyStatusFeedback = "Copy"

    init(petId: UUID) {
        _vm = State(initialValue: GenerateCodeViewModel(petId: petId))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Section {
                        HStack(spacing: 0) {
                            Text(vm.codeString)
                                .font(.system(.title, design: .monospaced))
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            
                            // copy btn
                            Button(action: {
                                UIPasteboard.general.string = vm.codeString
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
                                .padding(8)
                                
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.accent)
                            .buttonBorderShape(.roundedRectangle(radius: 12))
                            .padding(.leading, 8)
                        }
                        
                    } header: {
                        Text("6-digit Invitation Code")
                            .modifier(onBoardingSectionHeaderStyle())
                    } footer: {
                        Text(vm.isGenerating
                             ? "Generating a fresh code…"
                             : "Share the 6-digit code to the pet sitter. Valid for 48 hours.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Button("Generate a new code") {
                        Task { await vm.generate() }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.primaryG)
                    .padding(.top, 30)
                    
                    
                }
                .padding()
                
            }
            .navigationTitle(Text("Invite a New Sitter"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle(Text("Generate a 6-digit code to invite a new pet sitter to your home."))
            .task {
                await vm.generate()
            }
        }
    }
}

#Preview {
    GenerateCodeView(petId: UUID())
}
