//
//  ConectPastePetCode.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI

struct PetCodeInput: View {
    @Environment(\.dismiss) private var dismiss

    let store: PetStore

    @State private var code = ""
    @State private var isJoining = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 40) {

                Section {
                    HStack(spacing: 0) {
                        // code
                        TextField("000 000", text: $code)
                            .font(.system(.title, design: .monospaced))
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)

                        // copy btn
                        Button(action: {
                            if let clipboard = UIPasteboard.general.string {
                                code = clipboard
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "doc.on.clipboard")
                                Text("Paste")
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
                    Text("Enter 6-Digit Code from Owner")
                        .modifier(onBoardingSectionHeaderStyle())
                }

                // error msg
                if let error = store.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Spacer()
                
                // Help card
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.primaryG)
                        Text("Where do I find the code?")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryG)
                    }

                    Text(
                        "The pet owner can generate this code in their Pet Settings -> Invitation code. Codes are valid for 24 hours."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
                
                //Spacer()
            }
            .padding()
            // title
            .navigationTitle(Text("Connect with Pet"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle(Text("Get to know your pet friend!"))
            // toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { Task { await join() } }) {

                        Image(systemName: "checkmark")
                    }
                    .disabled(
                        isJoining
                            || code.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                }
            }
        }
    }

    private func join() async {
        isJoining = true
        let ok = await store.redeem(code: code)
        isJoining = false
        if ok { dismiss() }
    }
}
