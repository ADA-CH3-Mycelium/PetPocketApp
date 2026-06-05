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

extension ClarifyThread {
    
}

extension ClarifyMessage {
   
}
