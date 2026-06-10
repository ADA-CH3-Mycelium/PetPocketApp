//
//  PetListViewModel.swift
//  PetPocket
//
//  View-model for PetListView. Wraps PetStore and holds the row→card
//  mapping + age formatting that previously lived in the view.
//

import Foundation
import Observation

@Observable
final class PetListViewModel {
    let store: PetStore

    init(store: PetStore = PetStore()) {
        self.store = store
    }

    var ownedPets: [PetRow] { store.ownedPets }
    var sittingPets: [PetRow] { store.sittingPets }
    var petCount: Int { store.ownedPets.count + store.sittingPets.count }

    func load() async {
        await store.load()
    }

    func signOut() async {
        await AuthManager.shared.signOut()
    }

    // PetRow (DB) -> PetItem (UI card)
    func card(for row: PetRow, type: PetCardType) -> PetItem {
        PetItem(
            id: row.id,
            name: row.name,
            gender: row.gender ?? "",
            age: Self.ageText(from: row.dateOfBirth),
            breed: row.breed ?? "",
            image: "",
            photoUrl: row.photoUrl,
            type: type
        )
    }

    private static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static func ageText(from iso: String?) -> String {
        guard let iso, let dob = dobFormatter.date(from: iso) else { return "" }
        let years = Calendar.current.dateComponents([.year], from: dob, to: .now).year ?? 0
        return years > 0 ? "\(years)" : ""
    }
}
