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

    var body: some View {
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

                        HStack {
                            Spacer()

                            Button("Forgot Password?") {}
                                .foregroundColor(.primaryG)
                                .fontWeight(.medium)
                        }

                        PrimaryButton(title: "Login") {
                        }

                        HStack {
                            Divider()
                            Text("OR CONTINUE WITH")
                                .foregroundColor(.secondary)
                            Divider()
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
                        Button("Create an account") {}
                            .foregroundColor(.primaryG)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
            }


        }
                .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    LoginView()
}
