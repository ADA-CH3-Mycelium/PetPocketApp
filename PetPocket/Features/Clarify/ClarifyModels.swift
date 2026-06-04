//
//  Models.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 03/06/26.
//

import Foundation

enum ClarifyCategory: String, Codable, Hashable, CaseIterable {
    case food
    case waste
    case care
    case emergency
}

struct ClarifyThread: Identifiable, Codable, Hashable {
    let id: UUID
    let petId: UUID
    let category: ClarifyCategory
    let title: String
    let createdBy: UUID
    var isResolved: Bool
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case category
        case title
        case createdBy = "created_by"
        case isResolved = "is_resolved"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ClarifyMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let threadId: UUID
    let senderId: UUID
    let message: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case threadId = "thread_id"
        case senderId = "sender_id"
        case message
        case createdAt = "created_at"
    }
}

struct Profile: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var photoUrl: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case photoUrl = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Profile {
    static let mockAlex = Profile(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        name: "Alex",
        photoUrl: "AlexProfilePicture",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockSarah = Profile(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        name: "Sarah",
        photoUrl: "SarahPic",
        createdAt: Date(),
        updatedAt: Date()
    )
}

extension ClarifyThread {
    static let mockBreakfast = ClarifyThread(
        id: UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!,
        petId: UUID(),
        category: .food,
        title: "Breakfast",
        createdBy: Profile.mockSarah.id,
        isResolved: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockEveryFourHour = ClarifyThread(
        id: UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!,
        petId: UUID(),
        category: .waste,
        title: "Every 4 Hour",
        createdBy: Profile.mockSarah.id,
        isResolved: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockFearTriggers = ClarifyThread(
        id: UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc")!,
        petId: UUID(),
        category: .care,
        title: "Fear Triggers",
        createdBy: Profile.mockSarah.id,
        isResolved: false,
        createdAt: Date(),
        updatedAt: Date()
    )
}

extension ClarifyMessage {
    static let mockMessages: [ClarifyMessage] = [
        ClarifyMessage(
            id: UUID(),
            threadId: ClarifyThread.mockBreakfast.id,
            senderId: Profile.mockSarah.id,
            message: "What kind of Kibble should I give to Cooper?",
            createdAt: Date()
        ),
        ClarifyMessage(
            id: UUID(),
            threadId: ClarifyThread.mockBreakfast.id,
            senderId: Profile.mockAlex.id,
            message: "Eum dunno, anything fine please!",
            createdAt: Date()
        )
    ]
}


