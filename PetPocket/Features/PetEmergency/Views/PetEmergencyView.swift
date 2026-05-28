//
//  PetEmergencyView.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 29/05/26.
//

import SwiftUI

struct PetEmergencyView: View {
    var body: some View {
        ScrollView{
            VStack {
                ZStack(alignment: .topTrailing) {
                    Image("Cooper")
                        .resizable()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .padding()
                        .offset(x: 150)
                }
                
                Text("Cooper")
                    .font(.title)
                    .fontWeight(.semibold)
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: 12
                ) {
                    InfoCard(label: "AGE", value: "3 years")
                    InfoCard(label: "GENDER", value: "Male")
                    InfoCard(label: "BREED", value: "Golden Retriever")
                    InfoCard(label: "SPECIES", value: "Dog")
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Pet's Informations")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                HStack(spacing: 16) {
                    CategoryTab(icon: "fork.knife", label: "Food", isActive: false)
                    CategoryTab(icon: "leaf", label: "Waste", isActive: false)
                    CategoryTab(icon: "list.clipboard", label: "Care Notes", isActive: false)
                    CategoryTab(icon: "light.beacon.max", label: "Emergency", isActive: true)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                HStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                        .foregroundStyle(.black)
                    Text("First Aid Guides")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FirstAidCard(
                            icon: "lungs.fill",
                            iconColor: .red,
                            title: "Choking",
                            signs: "Signs: Pawing at mouth, pale gums, inability to breathe."
                        )
                        
                        FirstAidCard(
                            icon: "pills.fill",
                            iconColor: .red,
                            title: "Poisoning",
                            signs: "Signs: Vomiting, drooling, unusual behavior."
                        )
                    }
                    .padding(.horizontal)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "person.circle")
                        .foregroundStyle(.black)
                    Text("Trusted Contacts")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                VStack(spacing: 12) {
                    ForEach([
                        Contact(initial: "S", name: "Sarah (Neighbor)", role: "Has spare key"),
                        Contact(initial: "M", name: "Mike (Dad)", role: "Emergency transport")
                    ], id: \.name) { contact in
                        ContactCard(contact: contact)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    PetEmergencyView()
}

struct InfoCard: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .fontWeight(.semibold)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryTab: View {
    var icon: String
    var label: String
    var isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isActive ? .white : .black)
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(isActive ? Color.red : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(label)
                .font(.caption)
                .foregroundStyle(isActive ? .red : .black)
        }
    }
}

struct FirstAidCard: View {
    var icon: String
    var iconColor: Color
    var title: String
    var signs: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(signs)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 240, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct Contact {
    var initial: String
    var name: String
    var role: String
}

struct ContactCard: View {
    var contact: Contact
    
    var body: some View {
        HStack(spacing: 12) {
            Text(contact.initial)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.orange)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(contact.role)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "phone.fill")
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.green)
                .clipShape(Circle())
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
