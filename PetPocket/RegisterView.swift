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

                    PrimaryButton(title: "Sign up") {}
                    
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
    }
}

#Preview {
    RegisterView()
}
