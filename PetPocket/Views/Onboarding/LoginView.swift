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
    @State private var vm = AuthViewModel()
    @State private var showPassword = false

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

                                    TextField("", text: $vm.email, prompt:
                                    Text("email@example.com")
                                        .foregroundColor(Color(uiColor: .placeholderText))
                                    )
                                        .opacity(0.3)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.primary)
                                        .tint(.primary)
                                        
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

                                    if showPassword {
                                        TextField("Enter password", text: $vm.password)
                                            .textContentType(.password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .foregroundColor(.primary)
                                    } else {
                                        SecureField("Enter password", text: $vm.password)
                                            .textContentType(.password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .foregroundColor(.primary)
                                    }

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } header: {
                                Text("Password")
                                    .textCase(.uppercase)
                                    .font(.caption)
                            }

                        }
                        .listSectionSpacing(.compact)
                        .frame(height: 200)
                        .scrollDisabled(true)
                        .scrollContentBackground(.hidden)

                    }

                    // login
                    PrimaryButton(
                        title: "Log in",
                        isEnabled: vm.isLoginValid
                    ) {
                        Task {
                            if await vm.login() {
                                navigateToLogin = false
                            }
                        }
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.alertRed)
                    }

                }.padding(.top, 16)
                
                //alternative log in

//                VStack(spacing: 10) {
//                    Text("OR")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//
//                    HStack {
//
//                        // sign in with apple button
//                        SignInWithAppleButton(
//                            .signIn,  // Options: .signIn, .continue, .signUp
//                            onRequest: { request in
//                                // Request specific user scopes
//                                request.requestedScopes = [.fullName, .email]
//                            },
//                            onCompletion: { result in
//                                switch result {
//                                case .success(let authorization):
//                                    // Handle successful token exchange
//                                    print("Auth success: \(authorization)")
//                                case .failure(let error):
//                                    // Handle authentication errors
//                                    print(
//                                        "Auth failed: \(error.localizedDescription)"
//                                    )
//                                }
//                            }
//                        )
//                        //.frame(width: 140, height: 30)
//                        .frame(height: 50)
//                        .padding(.horizontal, 16)
//
//                        // sign in with google button
////                        Button {
////                            print("sign in w google btn pressed")
////                        } label: {
////                            HStack(spacing: 3) {
////                                Image("google")
////                                    .resizable()
////                                    .frame(width: 10, height: 10)
////
////                                Text("Sign in with Google")
////                                    .font(.caption)
////                                    .foregroundColor(.primary)
////
////                            }
////
////                        }
////                        .background(
////                            RoundedRectangle(cornerRadius: 6).stroke(
////                                Color.black,
////                                lineWidth: 1
////                            )
////                        )
////                        .frame(height: 29)
////                        .buttonStyle(.borderedProminent)
////                        .tint(.white)
////                        .buttonBorderShape(.roundedRectangle(radius: 6))
//
//                    }
//                }

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
            .padding(.vertical, 16)
        }

    }
}

//
//#Preview {
//    LoginView()
//}
