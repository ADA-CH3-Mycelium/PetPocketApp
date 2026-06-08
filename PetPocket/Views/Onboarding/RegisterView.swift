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
                        }
                        
                    }

                    .listSectionSpacing(.compact)
                    //.frame(height: 185)
                    .scrollContentBackground(.hidden)

                    PrimaryButton(
                        title: "Sign up",
                        isEnabled: vm.isRegisterValid
                    ) {
                        Task {
                            if await vm.register() {
                                navigateToRegister = false   // dismiss; root gate swaps to PetListView
                            }
                        }
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.alertRed)
                    }

                    // already have acc?
                    HStack(spacing: 5) {
                        Text("Already have an account?")
                        Button("Log in") {
                            print("have acc log in btn pressed")
                            navigateToLogin = true
                            navigateToRegister = false
                        }
                            .foregroundColor(.primaryG)
                            .fontWeight(.semibold)
                    }.font(.caption)
                }

            
            .padding()
        }

    }
}

//#Preview {
//    RegisterView()
//}
