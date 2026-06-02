//
//  PetProfileView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

struct PetProfileView: View {
    let pet: Pet2


    @State private var selectedTab: PetInfoTab = .food


    private let infoColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            //            VStack(alignment: .leading, spacing: 20) {
            //
            //                // MARK: Avatar + Name (centered)
            //                HStack {
            //                    Spacer()
            //                    PetAvatarHeaderView(name: pet.name, imageName: pet.avatarImageName)
            //                    Spacer()
            //                }
            //                .padding(.top, 8)
            //
            //                // MARK: Info Grid (Age, Gender, Breed, Species)
            //                LazyVGrid(columns: infoColumns, spacing: 10) {
            //                    InfoGridCard(label: "Age",     value: pet.age)
            //                    InfoGridCard(label: "Gender",  value: pet.gender)
            //                    InfoGridCard(label: "Breed",   value: pet.breed)
            //                    InfoGridCard(label: "Species", value: pet.species)
            //                }
            //
            //                // MARK: "Pet's Informations" Section
            //                VStack(alignment: .leading, spacing: 14) {
            //                    Text("Pet's Informations")
            //                        .font(.headline)
            //                        .fontWeight(.bold)
            //
            //                    PetInfoTabBarView(selectedTab: $selectedTab)
            //                }
            //
            //                Divider()
            //
            //                // MARK: Tab Content (Food tab for now)
            //                if selectedTab == .food {
            //                    foodTabContent
            //                } else {
            //                    ContentUnavailableView(
            //                        selectedTab.title,
            //                        systemImage: selectedTab.iconName,
            //                        description: Text("Coming soon")
            //                    )
            //                    .frame(maxWidth: .infinity)
            //                    .padding(.vertical, 40)
            //                }
            //            }
            //            .padding(.horizontal, 16)
            //            .padding(.bottom, 40)
        
            foodTabContent
        }
        .background(Color.ppBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {

                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // MARK: - Food Tab Content
    @ViewBuilder
    private var foodTabContent: some View {
        VStack(alignment: .leading, spacing: 16) {


            if let restriction = pet.dietaryRestriction {
                DietaryRestrictionBanner(
                    allergies: restriction.allergies,
                    restricted: restriction.restricted
                )
            }

            HStack {
                Text("Daily Feeding Routine")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(pet.feedingMeals.count) Meals / Day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(pet.feedingMeals) { meal in
                    FeedingRoutineCard(meal: meal)
                }
                AddInformationCard()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PetProfileView(pet: .sampleCooper)
    }
}
