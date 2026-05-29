import SwiftUI

struct ManageAccessView: View {
    @Environment(\.dismiss) var dismiss
    
    let collaborators = [
        Collaborator(name: "Sarah J.", role: "Active Sitter", isActive: true, imageName: "person.crop.circle.fill"),
        Collaborator(name: "Tom R.", role: "Past Sitter", isActive: false, imageName: "person.crop.circle.fill")
    ]
    
    var body: some View {
        ZStack {
            PawPocketTheme.backgroundCream.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Explanatory Intro Card Panel
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Collaborator Network")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PawPocketTheme.textDark)
                        Text("Manage who has access to your pet's health logs, walking schedules, and medical reminders. Collaborators can view and update records in real-time.")
                            .font(.callout)
                            .foregroundColor(PawPocketTheme.textSecondary)
                    }
                    .padding()
                    .background(PawPocketTheme.cardBackground)
                    .cornerRadius(16)
                    
                    Text("CONNECTIONS")
                        .font(.caption)
                        .bold()
                        .foregroundColor(PawPocketTheme.textSecondary)
                    
                    // List of Connected Sitters
                    ForEach(collaborators) { person in
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: person.imageName)
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading) {
                                    Text(person.name)
                                        .font(.body)
                                        .bold()
                                    Text(person.role)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(person.isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.2))
                                        .foregroundColor(person.isActive ? .green : .gray)
                                        .cornerRadius(4)
                                }
                                Spacer()
                            }
                            
                            // Contextual Decision Buttons
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Text(person.isActive ? "Remove Access" : "Remove Sitter")
                                        .font(.subheadline)
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.gray.opacity(0.1))
                                        .foregroundColor(PawPocketTheme.textDark)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {}) {
                                    Text(person.isActive ? "Regenerate Code" : "Invite Again")
                                        .font(.subheadline)
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(person.isActive ? PawPocketTheme.accentOrange.opacity(0.2) : PawPocketTheme.primaryGreen)
                                        .foregroundColor(person.isActive ? PawPocketTheme.accentOrange : .white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(PawPocketTheme.cardBackground)
                        .cornerRadius(16)
                    }
                    
                    // Call to Action Help Block
                    VStack(spacing: 12) {
                        Text("Need more help?")
                            .font(.headline)
                        Text("Generate a secure temporary code to allow a new sitter or family member to sync with your pet's profile.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(PawPocketTheme.textSecondary)
                        
                        Button(action: {}) {
                            Text("Generate New Code")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PawPocketTheme.primaryGreen)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .foregroundColor(Color.gray.opacity(0.4))
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Manage Access")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ManageAccessView()
    }
}