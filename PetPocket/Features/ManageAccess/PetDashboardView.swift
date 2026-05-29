//
//  PetDashboardView.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//

import SwiftUI

struct PetDashboardView: View {
    @State private var showingManageAccess = false
    @State private var showingGenerateCode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                PawPocketTheme.backgroundCream.ignoresSafeArea()
                
                ScrollView {
                    // Applying the explicit layout padding here cleanly covers the entire page structure
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Pet Profile Banner Block
                        
                        VStack(alignment: .center, spacing: 12) {
                            Image("Dog")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            
                            Text("Cooper")
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // Aligns profile center cleanly without breaking constraints
                        .padding(.vertical, 10)
                        
                        // Pet Quick Stats Grid Layout Panels
                        HStack(spacing: 12) {
                            StatCard(title: "AGE", value: "3 years")
                            StatCard(title: "GENDER", value: "Male")
                        }
                        HStack(spacing: 12) {
                            StatCard(title: "BREED", value: "Golden Retriever")
                            StatCard(title: "SPECIES", value: "Dog")
                        }
                        
                        // Categories Carousel Section Headers
                        Text("Pet's Informations")
                            .font(.headline)
                            .foregroundColor(PawPocketTheme.textDark)
                        
                        HStack(spacing: 5) {
                            Spacer(minLength: 0)
                            CategoryItem2(icon: "fork.knife", label: "Food", isActive: true)
                            Spacer(minLength: 0)
                            CategoryItem2(icon: "leaf.fill", label: "Waste", isActive: false)
                            Spacer(minLength: 0)
                            CategoryItem2(icon: "list.bullet.clipboard.fill", label: "Care Notes", isActive: false)
                            Spacer(minLength: 0)
                            CategoryItem2(icon: "exclamationmark.shield.fill", label: "Emergency", isActive: false, isAlert: true)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Critical Dietary Restrictions Callout Layout Panel
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(PawPocketTheme.alertRed)
                                Text("CRITICAL DIETARY RESTRICTIONS")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(PawPocketTheme.alertRed)
                            }
                            Text("ALLERGIES: No Chicken.")
                                .font(.headline)
                                .foregroundColor(PawPocketTheme.alertRed)
                            Text("RESTRICTED: Grapes, Chocolate, Onion.")
                                .font(.caption)
                                .foregroundColor(PawPocketTheme.textDark)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(PawPocketTheme.alertRed.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PawPocketTheme.alertRed.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Daily Routine List Header Section
                        HStack {
                            Text("Daily Feeding Routine")
                                .font(.headline)
                            Spacer()
                            Text("3 Meals / Day")
                                .font(.subheadline)
                                .foregroundColor(PawPocketTheme.textSecondary)
                        }
                        
                        // Breakfast Care Card Component
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Breakfast", systemImage: "sun.max.fill")
                                    .font(.headline)
                                    .foregroundColor(PawPocketTheme.accentOrange)
                                Spacer()
                                Text("8:00 AM")
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(PawPocketTheme.accentOrange.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            Text("1 Cup Dry Kibble")
                                .font(.subheadline)
                                .bold()
                            Text("Mix with warm water to soften the grains. Add probiotic powder.")
                                .font(.callout)
                                .foregroundColor(PawPocketTheme.textSecondary)
                        }
                        .padding()
                        .background(PawPocketTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)                     .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingManageAccess = true }) {
                            Label("Manage access", systemImage: "person.badge.key")
                        }
                        Button(action: {}) {
                            Label("Edit information", systemImage: "pencil")
                        }
                        Button(action: { showingGenerateCode = true }) {
                            Label("Generate new code", systemImage: "qrcode")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(PawPocketTheme.primaryGreen)
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

// MARK: - Local Reusable UI Components
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .bold()
                .foregroundColor(PawPocketTheme.textSecondary)
            Text(value)
                .font(.body)
                .bold()
                .foregroundColor(PawPocketTheme.textDark)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PawPocketTheme.cardBackground)
        .cornerRadius(12)
    }
}

struct CategoryItem2: View {
    let icon: String
    let label: String
    let isActive: Bool
    var isAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isActive ? PawPocketTheme.primaryGreen : (isAlert ? PawPocketTheme.alertRed.opacity(0.1) : PawPocketTheme.cardBackground))
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.02), radius: 4)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isActive ? .white : (isAlert ? PawPocketTheme.alertRed : PawPocketTheme.primaryGreen))
            }
            Text(label)
                .font(.caption)
                .bold()
                .foregroundColor(isAlert ? PawPocketTheme.alertRed : PawPocketTheme.textDark)
        }
    }
}

#Preview {
    PetDashboardView()
}
