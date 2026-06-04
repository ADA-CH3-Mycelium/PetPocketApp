//
//  RegisterView 2.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//

import SwiftUI

struct RegisterView: View {

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var navigateToLogin = false
    @State private var isRegistering = false
    @State private var registerError: String?

    private var isRegisterValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword
    }

    var body: some View {

        ScrollView {
            ZStack {
                
                VStack(spacing: 20) {

                    AuthHeader(
                        title: "Create Account",
                        subtitle: "Join our community of pet lovers today."
                    )

                    CustomTextField(
                        title: "Name",
                        placeholder: "Your full name",
                        icon: "person",
                        text: $name
                    )

                    CustomTextField(
                        title: "Email",
                        placeholder: "email@example.com",
                        icon: "envelope",
                        text: $email
                    )

                    CustomSecureField(
                        title: "Password",
                        placeholder: "Min. 8 characters",
                        text: $password
                    )

                    CustomSecureField(
                        title: "Confirm Password",
                        placeholder: "Repeat password",
                        text: $confirmPassword
                    )

                    PrimaryButton(
                        title: isRegistering ? "Creating…" : "Sign up",
                        isEnabled: isRegisterValid && !isRegistering
                    ) {
                        Task { await register() }
                    }

                    if let registerError {
                        Text(registerError)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    HStack {
                        Text("Already have an account?")
                        Button("Log in") {}
                            .foregroundColor(.primaryG)
                            .fontWeight(.semibold)
                    }
                }

            }
            .padding(20)
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
        }
    }

    private func register() async {
        isRegistering = true
        registerError = nil
        await AuthManager.shared.signUp(email: email, password: password, name: name)
        isRegistering = false
        // On success the app root swaps to PetListView automatically.
        if !AuthManager.shared.isAuthenticated {
            registerError = AuthManager.shared.errorMessage ?? "Sign up failed."
        }
    }
}

#Preview {
    RegisterView()
}
