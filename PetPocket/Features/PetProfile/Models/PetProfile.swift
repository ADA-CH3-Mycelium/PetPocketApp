//
//  PetProfile.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import Foundation
import AVKit

enum MediaAttachment {
    case photo(String)
    case video(URL)
}

// MARK: - Pet
struct Pet: Identifiable {
    let id: UUID
    var name: String
    var avatarImageName: String
    var age: String
    var gender: String
    var breed: String
    var species: String
    var dietaryRestriction: DietaryRestriction?
    var feedingMeals: [FeedingMeal]

    init(
        id: UUID = UUID(),
        name: String,
        avatarImageName: String,
        age: String,
        gender: String,
        breed: String,
        species: String,
        dietaryRestriction: DietaryRestriction? = nil,
        feedingMeals: [FeedingMeal] = []
    ) {
        self.id = id
        self.name = name
        self.avatarImageName = avatarImageName
        self.age = age
        self.gender = gender
        self.breed = breed
        self.species = species
        self.dietaryRestriction = dietaryRestriction
        self.feedingMeals = feedingMeals
    }
}

// MARK: - DietaryRestriction
struct DietaryRestriction {
    var allergies: [String]
    var restricted: [String]
}

// MARK: - FeedingMeal
struct FeedingMeal: Identifiable {
    let id: UUID
    var mealName: String   
    var time: String
    var amount: String
    var notes: String
    var iconName: String
    var media: MediaAttachment?

    init(
        id: UUID = UUID(),
        mealName: String,
        time: String,
        amount: String,
        notes: String,
        iconName: String,
        media: MediaAttachment? = nil
    ) {
        self.id = id
        self.mealName = mealName
        self.time = time
        self.amount = amount
        self.notes = notes
        self.iconName = iconName
        self.media = media
    }
}

// MARK: - Mock Data
extension Pet {
    static let sampleCooper = Pet(
        name: "Cooper",
        avatarImageName: "cooper_avatar",
        age: "3 years",
        gender: "Male",
        breed: "Golden Retriever",
        species: "Dog",
        dietaryRestriction: DietaryRestriction(
            allergies: ["Chicken"],
            restricted: ["Grapes", "Chocolate", "Onion"]
        ),
        feedingMeals: [
            FeedingMeal(
                mealName: "Breakfast",
                time: "8:00 AM",
                amount: "1 Cup Dry Kibble",
                notes: "Mix with warm water to soften the grains. Add probiotic powder.",
                iconName: "sunrise.fill",
                media: MediaAttachment.photo("testphoto")
            ),
            FeedingMeal(
                mealName: "Lunch",
                time: "1:00 PM",
                amount: "1/2 Can Wet Food",
                notes: "Use the Lamb & Rice formula. Serve at room temperature.",
                iconName: "sun.max.fill"
            ),
            FeedingMeal(
                mealName: "Dinner",
                time: "7:00 PM",
                amount: "1 Cup Dry Kibble",
                notes: "Mix with 1 tbsp of Salmon Oil for coat health. Fasting overnight after.",
                iconName: "moon.fill"
            )
        ]
    )
}
