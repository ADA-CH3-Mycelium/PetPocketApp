//
//  LoginView 2.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {

    @Binding var navigateToLogin: Bool
    @Binding var navigateToPetList: Bool
    @Binding var navigateToRegister: Bool
    @State private var email = ""
        @State private var password = ""

    private var isLoginValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")

        return emailValid
            && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 30) {
                VStack(spacing: 30) {
                    VStack(alignment: .trailing, spacing: 5) {
                        Form {
                            // email
                            Section {
                                HStack {
                                    Image(systemName: "envelope")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)

                                    TextField("email@example.com", text: $email)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .disableAutocorrection(true)
                                        .textContentType(.emailAddress)
                                        .foregroundColor(.secondary)
                                }
                            } header: {
                                Text("Email address")
                                    .modifier(onBoardingSectionHeaderStyle())
                            }

                            // password
                            Section {
                                HStack {
                                    Image(systemName: "lock")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)

                                    TextField("Enter password", text: $password)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .disableAutocorrection(true)
                                        .textContentType(.emailAddress)
                                        .foregroundColor(.secondary)
                                }
                            } header: {
                                Text("Password")
                                    .textCase(.uppercase)
                                    .font(.caption)
                            }

                        }
                        .listSectionSpacing(.compact)
                        .frame(height: 185)
                        .scrollContentBackground(.hidden)

                        // forgot password
                        Button("Forgot Password?") {
                            print("forgot password btn pressed")
                        }
                        .padding(.horizontal, 20)
                        .foregroundColor(.secondary)
                        .font(.caption)

                    }

                    // login
                    PrimaryButton(
                        title: "Login",
                        isEnabled: isLoginValid
                    ) {
                        navigateToLogin = false
                        navigateToPetList = true

                    }

                }.padding(.top, 16)

                VStack(spacing: 10) {
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {

                        // sign in with apple button
                        SignInWithAppleButton(
                            .signIn,  // Options: .signIn, .continue, .signUp
                            onRequest: { request in
                                // Request specific user scopes
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authorization):
                                    // Handle successful token exchange
                                    print("Auth success: \(authorization)")
                                case .failure(let error):
                                    // Handle authentication errors
                                    print(
                                        "Auth failed: \(error.localizedDescription)"
                                    )
                                }
                            }
                        )
                        //.frame(width: 140, height: 30)
                        //.frame(height: 50)
                        .padding(.horizontal, 16)

                        // sign in with google button
//                        Button {
//                            print("sign in w google btn pressed")
//                        } label: {
//                            HStack(spacing: 3) {
//                                Image("google")
//                                    .resizable()
//                                    .frame(width: 10, height: 10)
//
//                                Text("Sign in with Google")
//                                    .font(.caption)
//                                    .foregroundColor(.primary)
//
//                            }
//
//                        }
//                        .background(
//                            RoundedRectangle(cornerRadius: 6).stroke(
//                                Color.black,
//                                lineWidth: 1
//                            )
//                        )
//                        .frame(height: 29)
//                        .buttonStyle(.borderedProminent)
//                        .tint(.white)
//                        .buttonBorderShape(.roundedRectangle(radius: 6))

                    }
                }

                // DONT HAVE ACC?
                HStack(spacing: 5) {
                    Text("Dont have an account?")
                    Button("Sign up") {
                        print("sign up btn pressed")
                        navigateToRegister = true
                        navigateToLogin = false
                    }
                    .foregroundColor(.primaryG)
                    .fontWeight(.semibold)

                }.font(.caption)
                
                Spacer()

            }
        }

    }
}

//
//#Preview {
//    LoginView()
//}
