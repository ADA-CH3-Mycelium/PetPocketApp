//
//  Models.swift
//  PetPocket
//
//  Unified models for Supabase integration.
//

import Foundation

// MARK: - Profile
struct Profile: Identifiable, Codable {
    let id: UUID
    var name: String
    var photoURL: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name
        case photoURL = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Pet
struct Pet: Identifiable, Codable {
    let id: UUID
    let ownerID: UUID
    var name: String
    var gender: String?
    var dateOfBirth: Date?
    var breed: String?
    var species: String?
    var photoURL: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, gender, breed, species
        case ownerID = "owner_id"
        case dateOfBirth = "date_of_birth"
        case photoURL = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - FeedingMeal
struct FeedingMeal: Identifiable, Codable {
    let id: UUID
    let petID: UUID
    var mealName: String
    var time: String
    var amount: String
    var notes: String?
    var iconName: String?
    var mediaURL: String?
    var mediaType: String?
    var sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, time, amount, notes
        case petID = "pet_id"
        case mealName = "meal_name"
        case iconName = "icon_name"
        case mediaURL = "media_url"
        case mediaType = "media_type"
        case sortOrder = "sort_order"
    }
}

// MARK: - CareItem
struct CareItem: Identifiable, Codable {
    let id: UUID
    let petID: UUID
    var category: String // 'waste', 'care', 'emergency'
    var itemType: String // 'card', 'section_title', 'quote'
    var title: String?
    var content: String?
    var icon: String?
    var style: String? // 'normal', 'alert'
    var sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, category, title, content, icon, style
        case petID = "pet_id"
        case itemType = "item_type"
        case sortOrder = "sort_order"
    }
}

// MARK: - DietaryRestriction
struct DietaryRestriction: Identifiable, Codable {
    let id: UUID
    let petID: UUID
    var type: String // 'allergy', 'restricted'
    var item: String

    enum CodingKeys: String, CodingKey {
        case id, type, item
        case petID = "pet_id"
    }
}
