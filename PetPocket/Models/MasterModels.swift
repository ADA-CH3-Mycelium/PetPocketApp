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


struct AdditionalNotesCardItem: Identifiable {
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

enum PetCardType {
    case owning
    case sitting(sitter: String, sitterImage: String, dateRange: String)
}

struct PetCardItem {
    let name: String
    let image: String
    let type: PetCardType
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