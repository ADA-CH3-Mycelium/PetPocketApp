//
//  MasterModels.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import Foundation
import SwiftUI
import PhotosUI

// MARK: - PET PROFILE VIEW
// cases for diff screens possible
enum ScreenViews: Hashable {
    case food
    case waste
    case care
    case emergency
}

struct CategoryItem2: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let label: String
    let isActive: Bool
    var isAlert: Bool = false
    let targetScreen: ScreenViews

}

// category header
struct CategoryHeaderItem: Identifiable, Hashable {
    var id = UUID()
    var icon: String
    var label: String
}

// MARK: - ROUTINE CARD INFO

struct RoutineCardItem: Identifiable {
    let id: UUID
    let title: String
    let time: String
    let description: String
    let icon: String
    let media: MediaAttachment?

    init(
        id: UUID = UUID(),
        title: String,
        time: String,
        description: String,
        icon: String,
        media: MediaAttachment? = nil
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.description = description
        self.icon = icon
        self.media = media
    }
    
}

// MARK: - ADDITIONAL NOTES CARD
struct AdditionalNotesCardItem: Identifiable, Equatable {
    let id: UUID
    let description: String
    
    init(
    id: UUID = UUID(),
    description: String
    ){
        self.id = id
        self.description = description
    }
}

enum PetCardType: Hashable {
    case owning
    case sitting(sitter: String, sitterImage: String, dateRange: String)
}

struct PetItem: Hashable, Identifiable {
    let id : UUID
    let name: String
    let gender: String
    let age: String
    let breed: String
    let photoUrl: String?   // nil when no photo uploaded yet
    let type: PetCardType
    
    init(id: UUID, name: String, gender: String, age: String, breed: String, photoUrl: String?, type: PetCardType) {
        self.id = id
        self.name = name
        self.gender = gender
        self.age = age
        self.breed = breed
        self.photoUrl = photoUrl
        self.type = type
    }
}


// MARK: - EMERGENCY VIEW
// CONTACT CARD
struct ContactCardItem: Identifiable, Hashable {
    var id = UUID()
    var initial: String {
        String(name.prefix(1)).uppercased()
    }
    var name: String
    var relationship: String
    var note: String
    var phone: String
}

// VET CLINIC CARD
struct VetClinicCardItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var address: String
    var phone: String
    var note: String
}

// MARK: - Message Modle

struct MessageModel: Identifiable {
    let id = UUID()
    let senderLabel: String
    let time: String
    let text: String
    let isMe: Bool
    let avatarImage: Image
}

struct PastChat: Identifiable {
    let id = UUID()
    let title: String
    let time: String
}
