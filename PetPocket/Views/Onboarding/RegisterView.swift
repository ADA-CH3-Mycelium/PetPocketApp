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
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var isRegisterValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty && !confirmPassword.isEmpty
            && password == confirmPassword
    }

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
                                TextField("Name", text: $name)

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
                                TextField("email@example.com", text: $email)
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
                                SecureField("Password", text: $password)
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
                                SecureField("Repeat Password", text: $confirmPassword)
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
                        isEnabled: isRegisterValid
                    ) {
                        navigateToLogin = true
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
