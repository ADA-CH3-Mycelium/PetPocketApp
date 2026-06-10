//
//  RegisterView 2.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 03/06/26.
//

import SwiftUI

struct RegisterView: View {

    @Binding var navigateToLogin: Bool
    @Binding var navigateToPetList: Bool
    @Binding var navigateToRegister: Bool
    @State private var vm = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Form {
                        //name
                        Section {
                            HStack {
                                Image(systemName: "person")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                TextField("Name", text: $vm.name)

                            }
                        } header: {
                            Text("Enter Your Name")
                                .modifier(onBoardingSectionHeaderStyle())
                        }
                        
                        // email
                        Section {
                            HStack {
                                Image(systemName: "envelope")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                TextField("email@example.com", text: $vm.email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disableAutocorrection(true)
                                    .textContentType(.emailAddress)
                                    .foregroundColor(.secondary)
                            }
                        } header: {
                            Text("Email")
                                .modifier(onBoardingSectionHeaderStyle())
                        }
                        
                        // password
                        Section {
                            HStack {
                                Image(systemName: "lock")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                SecureField("Password", text: $vm.password)
                                    .textContentType(.newPassword)
                                    .foregroundColor(.secondary)
                            }
                        } header: {
                            Text("create a password")
                                .modifier(onBoardingSectionHeaderStyle())
                        } footer: {
                            Text("Minimum 8 characters")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        // confirm password
                        Section {
                            HStack {
                                Image(systemName: "lock")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                SecureField("Repeat Password", text: $vm.confirmPassword)
                                    .textContentType(.newPassword)
                                    .foregroundColor(.secondary)
                            }
                        } header: {
                            Text("Confirm password")
                                .modifier(onBoardingSectionHeaderStyle())
                        } footer: {
                            if vm.password == vm.confirmPassword {
                                
                                Text("Passwords do not match")
                                    .foregroundColor(.red)
                            }
                            
                        }
                        
                    }
                    
                    .listSectionSpacing(.compact)
                    //.frame(height: 185)
                    .scrollDisabled(true)
                    .padding(.top, 16)
                    .scrollContentBackground(.hidden)
                    
//                    PrimaryButton(
//                        title: "Sign up",
//                        isEnabled: isRegisterValid
//                    ) {
//                        Task {
//                            await AuthManager.shared.signUp(
//                                email: email,
//                                password: password,
//                                name: name
//                            )
//                            if AuthManager.shared.isAuthenticated {
//                                navigateToRegister = false  // dismiss; root gate swaps to PetListView
//                            }
//                        }
//                    }
                    
                    if let err = AuthManager.shared.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // already have acc?
                    HStack(spacing: 5) {
                        Text("Already have an account?")
                        Button("Login") {
                            print("have acc log in btn pressed")
                            navigateToLogin = true
                            navigateToRegister = false
                        }
                        .foregroundColor(.primaryG)
                        .fontWeight(.semibold)
                    }.font(.caption)
                        .padding(.top, 30)
                }
                
                .padding(.vertical, 16)
            }
            .navigationTitle("Create a New Account")
            .navigationBarTitleDisplayMode(.inline)
            // sign up
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button {
                        print ("sign up pressed")
                        Task {
                            if await vm.register() {
                                navigateToRegister = false   
                            }
                        }
                        
                    } label: {
                        Image(systemName: "checkmark")
                            .disabled(!vm.isRegisterValid)
                            .foregroundStyle(vm.isRegisterValid
                                  ? Color.accent
                                             : Color.secondary.opacity(0.7))
                    }
                }
            }
        }

    }
}

//#Preview {
//    RegisterView()
//}
