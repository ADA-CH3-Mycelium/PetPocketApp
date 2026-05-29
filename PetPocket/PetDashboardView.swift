import SwiftUI

struct PetDashboardView: View {
    @State private var showingManageAccess = false
    @State private var showingGenerateCode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                PawPocketTheme.backgroundCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Pet Quick Stats Grid
                        HStack(spacing: 12) {
                            StatCard(title: "AGE", value: "3 years")
                            StatCard(title: "GENDER", value: "Male")
                        }
                        HStack(spacing: 12) {
                            StatCard(title: "BREED", value: "Golden Retriever")
                            StatCard(title: "SPECIES", value: "Dog")
                        }
                        
                        // Categories Carousel Section
                        Text("Pet's Informations")
                            .font(.headline)
                            .foregroundColor(PawPocketTheme.textDark)
                        
                        HStack(spacing: 16) {
                            CategoryItem(icon: "fork.knife", label: "Food", isActive: true)
                            CategoryItem(icon: "leaf.fill", label: "Waste", isActive: false)
                            CategoryItem(icon: "doc.text.with.clipboard", label: "Care Notes", isActive: false)
                            CategoryItem(icon: "exclamationmark.shield.fill", label: "Emergency", isActive: false, isAlert: true)
                        }
                        
                        // Critical Dietary Restrictions Callout
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
                        
                        // Daily Routine List Section
                        HStack {
                            Text("Daily Feeding Routine")
                                .font(.headline)
                            Spacer()
                            Text("3 Meals / Day")
                                .font(.subheadline)
                                .foregroundColor(PawPocketTheme.textSecondary)
                        }
                        
                        // Breakfast Card Block
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Breakfast", systemName: "sun.max.fill")
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
                    .padding()
                }
            }
            .navigationTitle("Buddy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingManageAccess = true }) {
                            Label("Manage access", systemName: "person.badge.key")
                        }
                        Button(action: {}) {
                            Label("Edit information", systemName: "pencil")
                        }
                        Button(action: { showingGenerateCode = true }) {
                            Label("Generate new code", systemName: "qrcode")
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

struct CategoryItem: View {
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