//
//  WelcomeView.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import SwiftUI

struct OnboardingView: View {
    @State var navigateToLogin: Bool = false
    @State var navigateToRegister = false
    @State var navigateToPetList = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                Image("PPEnvelope")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.5)
                    .frame(width: 1000)
                    .rotationEffect(.degrees(180))
                    .offset(x: -20, y: -120)

                VStack(alignment: .center, spacing: 7) {
                    Image("PPLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100, alignment: .center)

                    Text("Pocket the details, not the doubt.")
                        .font(.body)
                        .foregroundColor(Color.primaryG)

                    Spacer()

                    // login
                    Button {
                        print("button pressed")
                        navigateToLogin.toggle()

                    } label: {
                        Text("Login")
                            .font(.headline)
                            .textCase(.uppercase)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 40)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.accent)
                       
                    // log in sheet
                    .sheet(isPresented: $navigateToLogin) {
                        LoginView(
                            navigateToLogin: $navigateToLogin,
                            navigateToPetList: $navigateToPetList,
                            navigateToRegister: $navigateToRegister
                        )
                        .presentationDetents([.height(700)])
                        .presentationDragIndicator(.visible)
                    }

                    // register sheet
                    .sheet(isPresented: $navigateToRegister) {
                        RegisterView(navigateToLogin: $navigateToLogin,
                                     navigateToPetList: $navigateToPetList,
                                     navigateToRegister: $navigateToRegister)
                            .presentationDetents([.height(700)])
                            .presentationDragIndicator(.visible)
                    }
                    //navigate to pet list view
                    .navigationDestination(isPresented: $navigateToPetList) {
                        PetListView()
                    }

                    HStack {
                        Text("New to PetPocket?")
                            .foregroundStyle(Color.secondary)
                        Button("Create an account") {
                            navigateToRegister = true
                        }
                        .foregroundColor(.primaryG)
                        .fontWeight(.semibold)
                    }
                        .padding(.top, 35)

                }.padding(40)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
