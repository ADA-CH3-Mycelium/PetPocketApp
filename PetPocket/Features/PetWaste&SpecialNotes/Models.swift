//
//  Models.swift
//  Pet Waste and Special Notes Feature
//
//  Data models + dummy data.
//  Hanya .waste & .careNotes punya konten — .food & .emergency
//  dikerjakan teammate lain (akan di-merge nanti).
//

import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let brandPrimary   = Color(red: 107/255, green: 150/255, blue: 125/255) // #6B967D
    static let brandSecondary = Color(red: 244/255, green: 162/255, blue:  97/255) // #F4A261
    static let brandTertiary  = Color(red: 245/255, green: 240/255, blue: 230/255) // #F5F0E6
    static let brandNeutral   = Color(red:  74/255, green:  74/255, blue:  74/255) // #4A4A4A
}

// MARK: - Pet

struct Pet {
    let name, imageName, age, gender, breed, species: String

    static let cooper = Pet(
        name: "Cooper", imageName: "cooper",
        age: "3 years", gender: "Male",
        breed: "Golden Retriever", species: "Dog"
    )
}

// MARK: - Category

enum PetCategory: String, CaseIterable, Identifiable {
    case food      = "Food"
    case waste     = "Waste"
    case careNotes = "Care/Notes"
    case emergency = "Emergency"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food:      "fork.knife"
        case .waste:     "leaf"
        case .careNotes: "heart.text.square"
        case .emergency: "cross.case.fill"
        }
    }
}

// MARK: - Info Card

struct InfoCard: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var content: String
    var icon: String
    var style: CardStyle

    enum CardStyle: Equatable { case normal, alert }

    var accentColor: Color {
        style == .alert ? .brandSecondary : .brandPrimary
    }
}

struct QuoteItem: Identifiable, Equatable {
    let id = UUID()
    var text: String
}

// Tipe campuran utk konten kategori (card / section title / quote)
enum CategoryItem: Identifiable, Equatable {
    case card(InfoCard)
    case sectionTitle(String)
    case quote(QuoteItem)

    var id: String {
        switch self {
        case .card(let c):         "card-\(c.id.uuidString)"
        case .sectionTitle(let t): "title-\(t)"
        case .quote(let q):        "quote-\(q.id.uuidString)"
        }
    }
}

// MARK: - Dummy Data

extension CategoryItem {
    static let wasteItems: [CategoryItem] = [
        .card(InfoCard(title: "Schedule",
                       content: "Every 4 hours\nConsistent timing prevents accidents and builds bladder control.",
                       icon: "clock.fill", style: .normal)),
        .card(InfoCard(title: "Location",
                       content: "Backyard/Park\nFamiliar scents help Cooper focus on the task quickly.",
                       icon: "mappin.and.ellipse", style: .normal)),
        .card(InfoCard(title: "Cleanup",
                       content: "Biodegradable bags in side pocket",
                       icon: "leaf.fill", style: .normal)),
        .card(InfoCard(title: "Diet Note",
                       content: "Avoid table scraps and dairy — may cause loose stool.\nStick to the kibble in the labeled container.",
                       icon: "leaf.circle.fill", style: .normal)),
        .card(InfoCard(title: "Stool Check",
                       content: "Inspect daily for color & consistency.\nReport to owner if dark, runny, or contains visible objects.",
                       icon: "checkmark.circle.fill", style: .normal)),
        .card(InfoCard(title: "Indoor Accidents",
                       content: "Wipe with paper towel first, then spray enzymatic cleaner under the sink.\nDon't scold — redirect to the door.",
                       icon: "sparkles", style: .normal)),
        .card(InfoCard(title: "Hydration",
                       content: "Refill the water bowl 2× a day.\nLow water intake → fewer bathroom breaks → constipation risk.",
                       icon: "drop.fill", style: .normal)),
        .sectionTitle("Behavioral Signs"),
        .quote(QuoteItem(text: "Cooper will pace at the back door and whine when he needs to go.")),
        .quote(QuoteItem(text: "Tail held high and circling on the rug means he needs to go urgently — bring him out right away.")),
        .quote(QuoteItem(text: "Refuses to eliminate during heavy rain. Bring a small umbrella or wait it out — he won't have an accident inside.")),
        .quote(QuoteItem(text: "Sniffs intensely at one spot for more than 10 seconds → take him out within 5 minutes."))
    ]

    static let careNotesItems: [CategoryItem] = [
        .card(InfoCard(title: "Critical Medication",
                       content: "Heartworm pill at 1st of every month.\nKept in the green container on the kitchen counter.",
                       icon: "pills.fill", style: .normal)),
        .card(InfoCard(title: "Alert",
                       content: "Thunderstorms and Fireworks cause severe anxiety.\nKeep thunder jacket nearby.",
                       icon: "exclamationmark.triangle.fill", style: .alert)),
        .card(InfoCard(title: "Bathing",
                       content: "Once every 2 weeks with oatmeal shampoo (sensitive skin).\nDry thoroughly behind the ears to prevent infections.",
                       icon: "shower.fill", style: .normal)),
        .card(InfoCard(title: "Grooming",
                       content: "Brush coat daily — golden retrievers shed heavily.\nCheck for mats behind ears and under the legs.",
                       icon: "comb.fill", style: .normal)),
        .card(InfoCard(title: "Exercise",
                       content: "1 hour walk in the morning + 30 min play in the evening.\nFetch is his favorite — ball is in the basket by the door.",
                       icon: "figure.walk", style: .normal)),
        .card(InfoCard(title: "Dental Care",
                       content: "Brush teeth 3× a week with poultry-flavored paste.\nDental chew on Sundays only (high calorie).",
                       icon: "mouth.fill", style: .normal)),
        .sectionTitle("Additional Notes"),
        .quote(QuoteItem(text: "Cooper will pace at night if his favorite blanket isn't in his crate. Please check the laundry if missing.")),
        .quote(QuoteItem(text: "Sleep in crate only and before sleeping always go for 45 mins walk.")),
        .quote(QuoteItem(text: "Loves belly rubs — non-negotiable bonding ritual at bedtime. He'll flop over and stare until you do it.")),
        .quote(QuoteItem(text: "Doesn't like strangers in hats. Approach calmly and remove headwear if possible.")),
        .quote(QuoteItem(text: "Will sneak the cat's food if the dish is left out — always pick it up after meals."))
    ]

    static func items(for category: PetCategory) -> [CategoryItem] {
        switch category {
        case .waste:     wasteItems
        case .careNotes: careNotesItems
        case .food, .emergency: []   // diisi teammate lain
        }
    }
}

// MARK: - Chat

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender, role, time, text: String
    let isMine: Bool   // true = owner (kanan), false = sitter (kiri)
}

extension ChatMessage {
    static let dummy: [ChatMessage] = [
        ChatMessage(sender: "SARAH", role: "(SITTER)", time: "14:02",
                    text: "What kind of Kibble should I give to Cooper?", isMine: false),
        ChatMessage(sender: "ALEX",  role: "(OWNER)",  time: "14:05",
                    text: "Eum dunno, anything fine please!", isMine: true)
    ]
}
