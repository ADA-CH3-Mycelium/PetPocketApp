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
        NavigationStack {
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
                                        .modifier(onBoardingSectionHeaderStyle())
                                }
                                
                            }
                            .listSectionSpacing(.compact)
                            .frame(height: 250)
                            .scrollDisabled(true)
                            .scrollContentBackground(.hidden)
                            
                        }
                        
                        Spacer()
                        
                        // login
                        //                        PrimaryButton(
                        //                            title: "Login",
                        //                            isEnabled: isLoginValid
                        //                        ) {
                        //                            Task {
                        //                                await AuthManager.shared.signIn(email: email, password: password)
                        //                                if AuthManager.shared.isAuthenticated {
                        //                                    navigateToLogin = false   // dismiss; root gate swaps to PetListView
                        //                                }
                        //                            }
                        //                        }
                        //
                        //                        if let err = AuthManager.shared.errorMessage {
                        //                            Text(err)
                        //                                .font(.caption)
                        //                                .foregroundColor(.red)
                        //                        }
                        //
                        //                    }.padding(.top, 16)
                        
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
                            .padding(.top, 30)
                        
                        
                    }
                    .padding(.vertical, 16)
                }
                .navigationTitle("Login")
                .navigationBarTitleDisplayMode(.inline)
                // log in btn
                .toolbar {
                    ToolbarItem (placement: .navigationBarTrailing) {
                        Button {
                            print ("login pressed")
                            Task {
                                if await vm.login() {
                                    navigateToLogin = false
                                }
                            }
                            
                        } label: {
                            Image(systemName: "checkmark")
                                .disabled(!vm.isLoginValid)
                                .foregroundStyle(vm.isLoginValid
                                                 ? Color.accent
                                                 : Color.secondary.opacity(0.7))
                        }
                    }
                }
            }
            
        }
    }
    
    //
    //#Preview {
    //    LoginView()
    //}
}
