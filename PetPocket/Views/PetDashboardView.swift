//
//  PetDashboardView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//  Edited by Samantha Lugay on 01/06/26.
//

import SwiftUI

struct PetDashboardView: View {
    let PetData: PetItem
    @State private var showingManageAccess = false
    @State private var showingGenerateCode = false
    @State private var showingChatPage = false
    
    let pet: PetRow
    @State private var detail: PetDetailStore
    
    init(pet: PetRow) {
        self.pet = pet
        _detail = State(initialValue: PetDetailStore(pet: pet))
    }
    
    // DB
    @State var catItem: [CategoryItem2] = [
        // FOOD
        CategoryItem2(
            icon: "fork.knife",
            label: "Food",
            isActive: false,
            isAlert: false,
            targetScreen: .food
        ),
        // WASTE
        CategoryItem2(
            icon: "leaf.fill",
            label: "Waste",
            isActive: false,
            isAlert: false,
            targetScreen: .waste
        ),
        // CARE
        CategoryItem2(
            icon: "heart.text.square.fill",
            label: "Care Notes",
            isActive: false,
            isAlert: false,
            targetScreen: .care
        ),
        // EMERGENCY
        CategoryItem2(
            icon: "exclamationmark.shield.fill",
            label: "Emergency",
            isActive: false,
            isAlert: true,
            targetScreen: .emergency
        ),
    ]
    
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
                        Image(PetData.image)
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
                            Text(pet.name)
                                .font(.largeTitle)
                                .bold()
                            
                            Text(subtitle)
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
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // clarify chat
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingChatPage = true
                        }) {
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
                .navigationDestination(isPresented: $showingChatPage) {
                    ClarifySheetView()
                }
                .sheet(isPresented: $showingGenerateCode) {
                    GenerateCodeView(petId: pet.id)
                }
            }
            .environment(detail)
            .task { await detail.loadIfNeeded() }
        }
    }
    
    private var subtitle: String {
        [pet.ageDescription, pet.gender, pet.breed]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "  •  ")
    }
    
}
