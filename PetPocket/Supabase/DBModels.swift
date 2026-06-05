//
//  DBModels.swift
//  PetPocket
//
//  Codable row models mirroring the Supabase `public` schema. Keys are
//  snake_case to match Postgres (supabase-swift does not auto-convert).
//

import Foundation

// MARK: - Profile
struct ProfileRow: Decodable, Identifiable {
    let id: UUID
    let name: String
    let photoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case photoUrl = "photo_url"
    }
}

// MARK: - Pet
struct PetRow: Decodable, Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let name: String
    let gender: String?
    let dateOfBirth: String?   // ISO date "yyyy-MM-dd"
    let breed: String?
    let species: String?
    let photoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, gender, breed, species
        case ownerId = "owner_id"
        case dateOfBirth = "date_of_birth"
        case photoUrl = "photo_url"
    }

    /// Human age string derived from date_of_birth, e.g. "3 years old".
    var ageDescription: String {
        guard let dob = dateOfBirth else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone = TimeZone(identifier: "UTC")
        guard let date = fmt.date(from: String(dob.prefix(10))) else { return "" }
        let years = Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
        if years <= 0 {
            let months = Calendar.current.dateComponents([.month], from: date, to: Date()).month ?? 0
            return months <= 1 ? "\(max(months, 0)) month old" : "\(months) months old"
        }
        return years == 1 ? "1 year old" : "\(years) years old"
    }
}

#if DEBUG
extension PetRow {
    static let sample = PetRow(
        id: UUID(), ownerId: UUID(), name: "Cooper",
        gender: "Male", dateOfBirth: "2023-01-01",
        breed: "Golden Retriever", species: "Dog", photoUrl: nil
    )
}
#endif

struct PetInsert: Encodable {
    let ownerId: UUID
    let name: String
    let gender: String?
    let dateOfBirth: String?
    let breed: String?
    let species: String?
    let photoUrl: String?

    enum CodingKeys: String, CodingKey {
        case name, gender, breed, species
        case ownerId = "owner_id"
        case dateOfBirth = "date_of_birth"
        case photoUrl = "photo_url"
    }
}

// MARK: - Feeding meals
struct FeedingMealRow: Decodable, Identifiable {
    let id: UUID
    let mealName: String
    let time: String
    let notes: String?
    let iconName: String?
    let mediaUrl: String?
    let mediaType: String?

    enum CodingKeys: String, CodingKey {
        case id, time, notes
        case mealName  = "meal_name"
        case iconName  = "icon_name"
        case mediaUrl  = "media_url"
        case mediaType = "media_type"
    }
}

struct FeedingMealInsert: Encodable {
    let petId: UUID
    let mealName: String
    let time: String
    let notes: String?
    let iconName: String?
    let mediaUrl: String?
    let mediaType: String?   // "photo" | "video"
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case time, notes
        case petId     = "pet_id"
        case mealName  = "meal_name"
        case iconName  = "icon_name"
        case mediaUrl  = "media_url"
        case mediaType = "media_type"
        case sortOrder = "sort_order"
    }
}

struct FeedingMealUpdate: Encodable {
    let mealName: String
    let time: String
    let notes: String?
    let iconName: String?
    let mediaUrl: String?
    let mediaType: String?   // "photo" | "video"

    enum CodingKeys: String, CodingKey {
        case time, notes
        case mealName = "meal_name"
        case iconName = "icon_name"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
    }
}

// MARK: - Dietary restrictions
// One row per pet. `allergies` / `restricted` are comma-separated text.
struct DietaryRestrictionRow: Decodable, Identifiable {
    let id: UUID
    let allergies: String
    let restricted: String
}

struct DietaryInsert: Encodable {
    let petId: UUID
    let allergies: String
    let restricted: String

    enum CodingKeys: String, CodingKey {
        case allergies, restricted
        case petId = "pet_id"
    }
}

// MARK: - Care items (waste / care / emergency text content)
struct CareItemRow: Decodable, Identifiable {
    let id: UUID
    let category: String   // "waste" | "care" | "emergency"
    let itemType: String   // "card" | "section_title" | "quote"
    let title: String?
    let content: String?
    let icon: String?
    let style: String?

    enum CodingKeys: String, CodingKey {
        case id, category, title, content, icon, style
        case itemType = "item_type"
    }
}

struct CareItemInsert: Encodable {
    let petId: UUID
    let category: String       // "waste" | "care" | "emergency"
    let itemType: String       // "card"
    let title: String
    let content: String
    let icon: String
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case category, title, content, icon
        case petId = "pet_id"
        case itemType = "item_type"
        case sortOrder = "sort_order"
    }
}

struct CareItemUpdate: Encodable {
    let title: String
    let content: String
    let icon: String
}

// MARK: - Emergency contacts
struct EmergencyContactRow: Decodable, Identifiable {
    let id: UUID
    let name: String
    let role: String?
    let phone: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id, name, role, phone, description
    }
}

struct EmergencyContactInsert: Encodable {
    let petId: UUID
    let name: String
    let role: String?
    let phone: String?
    let description: String?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case name, role, phone, description
        case petId = "pet_id"
        case sortOrder = "sort_order"
    }
}

struct EmergencyContactUpdate: Encodable {
    let name: String
    let role: String?
    let phone: String?
    let description: String?
}

// MARK: - Vet clinics
struct VetClinicRow: Decodable, Identifiable {
    let id: UUID
    let name: String
    let address: String?
    let phone: String?
    let latitude: Double?
    let longitude: Double?
    let isPrimary: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, address, phone, latitude, longitude
        case isPrimary = "is_primary"
    }
}

struct VetClinicInsert: Encodable {
    let petId: UUID
    let name: String
    let address: String?
    let phone: String?
    let latitude: Double?
    let longitude: Double?
    let isPrimary: Bool?

    enum CodingKeys: String, CodingKey {
        case name, address, phone, latitude, longitude
        case petId = "pet_id"
        case isPrimary = "is_primary"
    }
}

struct VetClinicUpdate: Encodable {
    let name: String
    let address: String?
    let phone: String?
    let latitude: Double?
    let longitude: Double?
    let isPrimary: Bool?

    enum CodingKeys: String, CodingKey {
        case name, address, phone, latitude, longitude
        case isPrimary = "is_primary"
    }
}

// MARK: - Access codes
struct AccessCodeInsert: Encodable {
    let petId: UUID
    let createdBy: UUID
    let code: String

    enum CodingKeys: String, CodingKey {
        case code
        case petId = "pet_id"
        case createdBy = "created_by"
    }
}
