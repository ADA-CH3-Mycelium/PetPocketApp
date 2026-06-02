//
//  LoginView.swift
//  PetPocket
//
//  Login and Registration screen with Email and Password.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthManager.self) var authManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.ppPrimaryG)
                    .padding(.top, 50)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.largeTitle)
                        .bold()
                    Text(isSignUp ? "Join PetPocket to start managing your pets." : "Log in to manage your pet's needs.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Full Name", text: $name)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button {
                        Task {
                            if isSignUp {
                                await authManager.signUp(email: email, password: password, name: name)
                            } else {
                                await authManager.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isSignUp ? "Sign Up" : "Log In")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ppPrimaryG)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty) || authManager.isLoading)
                    
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.ppPrimaryG)
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 20) {
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        // Apple Sign-In completion handler placeholder
                    }
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                if let error = authManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .background(Color.ppBackground.ignoresSafeArea())
    }
}

#Preview {
    LoginView()
        .environment(AuthManager.shared)
}
