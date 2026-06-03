//
//  PetDashboardView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//  Edited by Samantha Lugay on 01/06/26.
//

import SwiftUI

struct PetDashboardView: View {
    @State private var showingManageAccess = false
    @State private var showingGenerateCode = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                Text("🐾")
                    .font(.system(size: 130, weight: .bold, design: .rounded))
                    .offset(x: 140, y: 350)
                    .opacity(0.3)
                

                //ScrollView {
                // Applying the explicit layout padding here cleanly covers the entire page structure
                VStack(alignment: .leading) {
                    ZStack(alignment: .bottomLeading) {
                        // PROFILE IMG
                        Image("Dog")
                            .resizable()

                            .scaledToFill()
                            .frame(width: 400, height: 500)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .black, location: 0.0),
                                        .init(color: .black, location: 0.75),
                                        .init(color: .clear, location: 1),
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        // TEXT
                        VStack(alignment: .leading) {
                            Text("Hi, I'm")
                                .font(.body)
                                //.fontWeight(.semibold)
                            //.foregroundColor(.gray)
                            Text("Cooper")
                                .font(.largeTitle)
                                .bold()

                            Text("3 years old  • Male  • Golden Retriever")
                                .foregroundColor(.gray)
                        }
                        .padding(20)
                        .offset(y: 30)

                    }
                    .offset(y: -100)

                    // Categories

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Here are my habits and needs 🐾")
                            .font(.body)

                        TwCoColGrid(catItem: catItem)
                    }
                    .padding(20)
                    .offset(y: -65)

                    //                        // Critical Dietary Restrictions Callout Layout Panel
                    //                        VStack(alignment: .leading, spacing: 6) {
                    //                            HStack {
                    //                                Image(systemName: "exclamationmark.triangle.fill")
                    //                                    .foregroundColor(PawPocketTheme.alertRed)
                    //                                Text("CRITICAL DIETARY RESTRICTIONS")
                    //                                    .font(.caption)
                    //                                    .bold()
                    //                                    .foregroundColor(PawPocketTheme.alertRed)
                    //                            }
                    //                            Text("ALLERGIES: No Chicken.")
                    //                                .font(.headline)
                    //                                .foregroundColor(PawPocketTheme.alertRed)
                    //                            Text("RESTRICTED: Grapes, Chocolate, Onion.")
                    //                                .font(.caption)
                    //                                .foregroundColor(PawPocketTheme.textDark)
                    //                        }
                    //                        .padding()
                    //                        .frame(maxWidth: .infinity, alignment: .leading)
                    //                        .background(PawPocketTheme.alertRed.opacity(0.1))
                    //                        .cornerRadius(12)
                    //                        .overlay(
                    //                            RoundedRectangle(cornerRadius: 12)
                    //                                .stroke(PawPocketTheme.alertRed.opacity(0.3), lineWidth: 1)
                    //                        )
                    //
                    //                        // Daily Routine List Header Section
                    //                        HStack {
                    //                            Text("Daily Feeding Routine")
                    //                                .font(.headline)
                    //                            Spacer()
                    //                            Text("3 Meals / Day")
                    //                                .font(.subheadline)
                    //                                .foregroundColor(PawPocketTheme.textSecondary)
                    //                        }
                    //
                    //                        // Breakfast Care Card Component
                    //                        VStack(alignment: .leading, spacing: 8) {
                    //                            HStack {
                    //                                Label("Breakfast", systemImage: "sun.max.fill")
                    //                                    .font(.headline)
                    //                                    .foregroundColor(PawPocketTheme.accentOrange)
                    //                                Spacer()
                    //                                Text("8:00 AM")
                    //                                    .font(.caption)
                    //                                    .bold()
                    //                                    .padding(.horizontal, 8)
                    //                                    .padding(.vertical, 4)
                    //                                    .background(PawPocketTheme.accentOrange.opacity(0.2))
                    //                                    .cornerRadius(6)
                    //                            }
                    //                            Text("1 Cup Dry Kibble")
                    //                                .font(.subheadline)
                    //                                .bold()
                    //                            Text("Mix with warm water to soften the grains. Add probiotic powder.")
                    //                                .font(.callout)
                    //                                .foregroundColor(PawPocketTheme.textSecondary)
                    //                        }
                    //                        .padding()
                    //                        .background(PawPocketTheme.cardBackground)
                    //                        .cornerRadius(16)
                    //                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    //                    }
                    //                    .padding(.horizontal)                     .padding(.bottom, 20)
                    //                }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // clarify chat
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "questionmark.bubble.fill")
                                .imageScale(.large)
                                .foregroundStyle(Color.primaryG)
                        }
                    }
                    
                    // menu
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { showingManageAccess = true }) {
                                Label(
                                    "Manage access",
                                    systemImage: "person.badge.key"
                                )
                            }
                            Button(action: {}) {
                                Label("Edit information", systemImage: "pencil")
                            }
                            Button(action: { showingGenerateCode = true }) {
                                Label(
                                    "Generate new code",
                                    systemImage: "qrcode"
                                )
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .imageScale(.large)
                                .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(Color.primaryG)
                        }
                    }
                    
                }
                .navigationDestination(isPresented: $showingManageAccess) {
                    ManageAccessView()
                }
                .sheet(isPresented: $showingGenerateCode) {
                    GenerateCodeView()
                }
            }
        }
    }
}

#Preview {
    PetDashboardView()
}
