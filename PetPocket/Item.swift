//
//  Item.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
