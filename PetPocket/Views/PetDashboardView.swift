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
            Image(systemName: "pawprint.fill")
                .font(.system(size: 130, weight: .bold, design: .rounded))
                .foregroundColor(Color.secondaryG)
                .offset(x: 140, y: 350)
            
            
            
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
                        .font(.body)
                    
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
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedScreen != nil },
            set: { if !$0 { selectedScreen = nil } }
        )) {
            switch selectedScreen {
            case .food:      FoodView()
            case .waste:     WasteView()
            case .care:      CareView()
            case .emergency: EmergencyView()
            case nil:        EmptyView()
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

#Preview {
    PetDashboardView()
}
