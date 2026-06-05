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
    @State private var selectedScreen: ScreenViews? = nil
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            //                Text("🐾")
            Image(systemName: "bubbles.and.sparkles.fill")
                .font(.system(size: 130, weight: .bold, design: .rounded))
                .foregroundColor(Color.secondaryG)
                .offset(x: 130, y: 370)
            
            
            
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
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .offset(y: 30)
                    
                }
                .offset(y: -100)
                
                // Categories
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Here are my habits and needs 🐾")
                        .font(.headline)
                    
                    TwCoColGrid(catItem: catItem) { screen in
                        selectedScreen = screen
                    }
                }
                .padding(20)
                .offset(y: -65)
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
                .navigationDestination(for: ScreenViews.self) { screen in
                    switch screen {
                    case .food:
                        FoodView().environment(detail)
                    case .waste:
                        WasteView().environment(detail)
                    case .care:
                        CareView().environment(detail)
                    case .emergency:
                        EmergencyView().environment(detail)
                    }
                }
                .sheet(isPresented: $showingGenerateCode) {
                    GenerateCodeView(petId: pet.id)
                }
        }
        .environment(detail)
        .task { await detail.loadIfNeeded() }
    }
    
    private var subtitle: String {
        [pet.ageDescription, pet.gender, pet.breed]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "  •  ")
    }

    private var petPhotoPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.primaryG.opacity(0.3), Color.primaryG.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.primaryG.opacity(0.4))
            )
    }
    
}
