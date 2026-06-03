//
//  AuthView.swift
//  PetPocket
//
//  Simple debug login/register form — no styling, just functionality.
//

import SwiftUI

struct AuthView: View {
    @Environment(AuthManager.self) var auth

    @State private var isSignUp = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isSignUp {
                        TextField("Name", text: $name)
                            .autocorrectionDisabled()
                    }
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                }

                Section {
                    Button {
                        Task {
                            if isSignUp {
                                await auth.signUp(email: email, password: password, name: name)
                            } else {
                                await auth.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        if auth.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isSignUp ? "Sign Up" : "Log In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(
                        email.isEmpty || password.isEmpty ||
                        (isSignUp && name.isEmpty) ||
                        auth.isLoading
                    )
                }

                if let error = auth.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(isSignUp ? "Create Account" : "Log In")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSignUp ? "Log In Instead" : "Sign Up Instead") {
                        isSignUp.toggle()
                        auth.errorMessage = nil
                    }
                    .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(AuthManager.shared)
}
