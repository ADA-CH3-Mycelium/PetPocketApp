//
//  LoginView 2.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//


import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var navigateToRegister = false
    @State private var isLoggingIn = false
    @State private var loginError: String?

    private var isLoginValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        
        return emailValid &&
               !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {

                    VStack(spacing: 25) {
                        
                        Spacer()

                        AuthHeader(
                            title: "PetPocket",
                            subtitle: "Log in to keep track of your pet's health and happiness."
                        )

                        VStack(spacing: 18) {

                            CustomTextField(
                                title: "Email Address",
                                placeholder: "hello@pawpocket.com",
                                icon: "envelope",
                                text: $email
                            )

                            CustomSecureField(
                                title: "Password",
                                placeholder: "Password",
                                text: $password
                            )

//                            HStack {
//                                Spacer()
//
//                                Button("Forgot Password?") {}
//                                    .foregroundColor(.primaryG)
//                                    .font(.caption)
//                            }

                            PrimaryButton(
                                title: isLoggingIn ? "Logging in…" : "Login",
                                isEnabled: isLoginValid && !isLoggingIn
                            ) {
                                Task { await login() }
                            }

                            if let loginError {
                                Text(loginError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            HStack {
//                                Divider()
                                Text("OR CONTINUE WITH")
                                    .foregroundColor(.secondary)
//                                Divider()
                            }

                            HStack {
                                SocialButton(
                                    imageName: "appleLogo",
                                    title: "Apple"
                                ) {}

                                SocialButton(
                                    imageName: "googleLogo",
                                    title: "Google"
                                ) {}
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(radius: 3)

                        HStack {
                            Text("New to PetPocket?")
                            Button("Create an account") {
                                navigateToRegister = true
                            }
                                .foregroundColor(.primaryG)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                }


            }
                    .background(Color(.systemGroupedBackground))
            
                    .navigationDestination(isPresented: $navigateToRegister) {
                        RegisterView()
                    }
        }
    }

    private func login() async {
        isLoggingIn = true
        loginError = nil
        await AuthManager.shared.signIn(email: email, password: password)
        isLoggingIn = false
        // On success, AuthManager.isAuthenticated flips and the app root
        // (PetPocketApp) swaps to PetListView automatically — no push needed.
        if !AuthManager.shared.isAuthenticated {
            loginError = AuthManager.shared.errorMessage ?? "Login failed."
        }
    }
}

#Preview {
    LoginView()
}
