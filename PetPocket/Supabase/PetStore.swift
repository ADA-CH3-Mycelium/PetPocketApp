//
//  PetStore.swift
//  PetPocket
//
//  Observable view-model layer. Loads real Supabase data and maps DB rows
//  into the UI item structs the existing views already render.
//

import Foundation
import Observation

// MARK: - Pet list (home)
@Observable
final class PetStore {
    var profileName: String = ""
    var ownedPets: [PetRow] = []
    var sittingPets: [PetRow] = []
    var isLoading = false
    var errorMessage: String?

    private let repo = PetRepository.shared

    var hasAnyPet: Bool { !ownedPets.isEmpty || !sittingPets.isEmpty }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let profile = repo.fetchProfile()
            async let owned = repo.fetchOwnedPets()
            async let sitting = repo.fetchSittingPets()
            profileName = try await profile.name
            ownedPets = try await owned
            sittingPets = try await sitting
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func addPet(
        name: String,
        gender: String,
        ageText: String,
        species: String,
        breed: String,
        imageData: Data? = nil
    ) async -> Bool {
        errorMessage = nil
        do {
            var photoUrl: String?
            if let imageData {
                photoUrl = try await repo.uploadPetAvatar(data: imageData)
            }
            _ = try await repo.createPet(
                name: name,
                gender: gender.isEmpty ? nil : gender,
                dateOfBirth: Self.approxDOB(fromAgeText: ageText),
                breed: breed.isEmpty ? nil : breed,
                species: species.isEmpty ? nil : species,
                photoUrl: photoUrl
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func redeem(code: String) async -> Bool {
        errorMessage = nil
        do {
            _ = try await repo.redeemAccessCode(code.trimmingCharacters(in: .whitespaces))
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Best-effort: turn freeform age ("3", "3 yrs") into an ISO date of birth.
    static func approxDOB(fromAgeText text: String) -> String? {
        let digits = text.prefix { $0.isNumber }
        guard let years = Int(digits), years >= 0 else { return nil }
        guard let date = Calendar.current.date(byAdding: .year, value: -years, to: Date()) else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone = TimeZone(identifier: "UTC")
        return fmt.string(from: date)
    }
}

// MARK: - Single pet detail (categories)
@Observable
final class PetDetailStore {
    let pet: PetRow

    var meals: [RoutineCardItem] = []
    var allergies: [String] = []
    var restricted: [String] = []
    var wasteItems: [RoutineCardItem] = []
    var careItems: [RoutineCardItem] = []
    var firstAid: [RoutineCardItem] = []
    var contacts: [ContactCardItem] = []
    var clinics: [VetClinicCardItem] = []

    var loaded = false
    var errorMessage: String?

    private let repo = PetRepository.shared

    init(pet: PetRow) { self.pet = pet }

    @MainActor
    func loadIfNeeded() async {
        guard !loaded else { return }
        await load()
    }

    @MainActor
    func load() async {
        errorMessage = nil
        do {
            async let mealsRows = repo.fetchMeals(petId: pet.id)
            async let dietRows = repo.fetchDietary(petId: pet.id)
            async let wasteRows = repo.fetchCareItems(petId: pet.id, category: "waste")
            async let careRows = repo.fetchCareItems(petId: pet.id, category: "care")
            async let emergencyRows = repo.fetchCareItems(petId: pet.id, category: "emergency")
            async let contactRows = repo.fetchContacts(petId: pet.id)
            async let clinicRows = repo.fetchClinics(petId: pet.id)

            meals = try await mealsRows.map { row in
                RoutineCardItem(
                    id: row.id,
                    title: row.mealName,
                    time: row.time,
                    description: row.notes ?? "",
                    icon: row.iconName ?? "fork.knife"
                )
            }

            let row = try await dietRows.first
            allergies = Self.splitCSV(row?.allergies)
            restricted = Self.splitCSV(row?.restricted)

            wasteItems = try await wasteRows.map(Self.card)
            careItems = try await careRows.map(Self.card)
            firstAid = try await emergencyRows.map(Self.card)

            contacts = try await contactRows.map { row in
                ContactCardItem(
                    id: row.id,
                    name: row.name,
                    relationship: row.role ?? "",
                    note: row.role ?? "",
                    phone: row.phone ?? ""
                )
            }

            clinics = try await clinicRows.map { row in
                VetClinicCardItem(
                    id: row.id,
                    name: row.name,
                    address: row.address ?? "",
                    phone: row.phone ?? "",
                    note: (row.isPrimary == true) ? "Primary clinic" : ""
                )
            }

            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Splits comma-separated text into trimmed, non-empty items.
    static func splitCSV(_ text: String?) -> [String] {
        guard let text else { return [] }
        return text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private static func card(_ row: CareItemRow) -> RoutineCardItem {
        RoutineCardItem(
            id: row.id,
            title: row.title ?? "",
            time: "",
            description: row.content ?? "",
            icon: row.icon ?? "info.circle.fill"
        )
    }

    // MARK: Write — Meals
    @MainActor
    func addMeal(
        mealName: String,
        time: String,
        notes: String?,
        iconName: String?,
        mediaUrl: String?
    ) async -> Bool {
        errorMessage = nil
        do {
            let newRow = try await repo.addMeal(
                petId: pet.id,
                mealName: mealName,
                time: time,
                notes: notes.flatMap { $0.isEmpty ? nil : $0 },
                iconName: iconName,
                mediaUrl: mediaUrl,
                sortOrder: meals.count
            )
            meals.append(RoutineCardItem(
                id: newRow.id,
                title: newRow.mealName,
                time: newRow.time,
                description: newRow.notes ?? "",
                icon: newRow.iconName ?? "fork.knife"
            ))
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Write — Update meal
    @MainActor
    func updateMeal(
        id: UUID,
        mealName: String,
        time: String,
        notes: String?,
        iconName: String?,
        mediaUrl: String?
    ) async -> Bool {
        errorMessage = nil
        do {
            let row = try await repo.updateMeal(
                id: id,
                mealName: mealName,
                time: time,
                notes: notes.flatMap { $0.isEmpty ? nil : $0 },
                iconName: iconName,
                mediaUrl: mediaUrl
            )
            let updated = RoutineCardItem(
                id: row.id,
                title: row.mealName,
                time: row.time,
                description: row.notes ?? "",
                icon: row.iconName ?? "fork.knife"
            )
            if let idx = meals.firstIndex(where: { $0.id == id }) {
                meals[idx] = updated
            } else {
                meals.append(updated)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Write — Dietary restrictions
    @MainActor
    func updateDietary(allergies: [String], restricted: [String]) async -> Bool {
        errorMessage = nil
        let cleanA = allergies.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let cleanR = restricted.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        do {
            try await repo.replaceDietary(petId: pet.id, allergies: cleanA, restricted: cleanR)
            self.allergies = cleanA
            self.restricted = cleanR
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Write — Delete meal
    @MainActor
    func deleteMeal(id: UUID) async -> Bool {
        errorMessage = nil
        do {
            try await repo.deleteMeal(id: id)
            meals.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Write — Care items (waste / care / emergency first-aid)

    /// Maps a category string to the local array holding its cards.
    private static func bucket(_ category: String) -> ReferenceWritableKeyPath<PetDetailStore, [RoutineCardItem]> {
        switch category {
        case "waste":     return \.wasteItems
        case "care":      return \.careItems
        default:          return \.firstAid     // "emergency"
        }
    }

    private static func card(id: UUID, title: String, content: String, icon: String) -> RoutineCardItem {
        RoutineCardItem(id: id, title: title, time: "", description: content, icon: icon)
    }

    @MainActor
    func addCareItem(category: String, title: String, content: String, icon: String) async -> Bool {
        errorMessage = nil
        let kp = Self.bucket(category)
        do {
            let row = try await repo.addCareItem(
                petId: pet.id, category: category,
                title: title, content: content, icon: icon,
                sortOrder: self[keyPath: kp].count
            )
            self[keyPath: kp].append(Self.card(id: row.id, title: row.title ?? "", content: row.content ?? "", icon: row.icon ?? "info.circle.fill"))
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func updateCareItem(id: UUID, category: String, title: String, content: String, icon: String) async -> Bool {
        errorMessage = nil
        let kp = Self.bucket(category)
        do {
            let row = try await repo.updateCareItem(id: id, title: title, content: content, icon: icon)
            let updated = Self.card(id: row.id, title: row.title ?? "", content: row.content ?? "", icon: row.icon ?? "info.circle.fill")
            if let i = self[keyPath: kp].firstIndex(where: { $0.id == id }) {
                self[keyPath: kp][i] = updated
            } else {
                self[keyPath: kp].append(updated)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func deleteCareItem(id: UUID, category: String) async -> Bool {
        errorMessage = nil
        let kp = Self.bucket(category)
        do {
            try await repo.deleteCareItem(id: id)
            self[keyPath: kp].removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Write — Emergency contacts

    @MainActor
    func addContact(name: String, role: String, phone: String) async -> Bool {
        errorMessage = nil
        do {
            let row = try await repo.addContact(
                petId: pet.id, name: name,
                role: role.isEmpty ? nil : role,
                phone: phone.isEmpty ? nil : phone,
                sortOrder: contacts.count
            )
            contacts.append(ContactCardItem(id: row.id, name: row.name, relationship: row.role ?? "", note: row.role ?? "", phone: row.phone ?? ""))
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func updateContact(id: UUID, name: String, role: String, phone: String) async -> Bool {
        errorMessage = nil
        do {
            let row = try await repo.updateContact(id: id, name: name, role: role.isEmpty ? nil : role, phone: phone.isEmpty ? nil : phone)
            let updated = ContactCardItem(id: row.id, name: row.name, relationship: row.role ?? "", note: row.role ?? "", phone: row.phone ?? "")
            if let i = contacts.firstIndex(where: { $0.id == id }) { contacts[i] = updated } else { contacts.append(updated) }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func deleteContact(id: UUID) async -> Bool {
        errorMessage = nil
        do {
            try await repo.deleteContact(id: id)
            contacts.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Write — Vet clinics

    @MainActor
    func addClinic(name: String, address: String, phone: String, isPrimary: Bool) async -> Bool {
        errorMessage = nil
        do {
            let row = try await repo.addClinic(
                petId: pet.id, name: name,
                address: address.isEmpty ? nil : address,
                phone: phone.isEmpty ? nil : phone,
                isPrimary: isPrimary
            )
            clinics.append(VetClinicCardItem(id: row.id, name: row.name, address: row.address ?? "", phone: row.phone ?? "", note: (row.isPrimary == true) ? "Primary clinic" : ""))
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func updateClinic(id: UUID, name: String, address: String, phone: String, isPrimary: Bool) async -> Bool {
        errorMessage = nil
        do {
            let row = try await repo.updateClinic(id: id, name: name, address: address.isEmpty ? nil : address, phone: phone.isEmpty ? nil : phone, isPrimary: isPrimary)
            let updated = VetClinicCardItem(id: row.id, name: row.name, address: row.address ?? "", phone: row.phone ?? "", note: (row.isPrimary == true) ? "Primary clinic" : "")
            if let i = clinics.firstIndex(where: { $0.id == id }) { clinics[i] = updated } else { clinics.append(updated) }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func deleteClinic(id: UUID) async -> Bool {
        errorMessage = nil
        do {
            try await repo.deleteClinic(id: id)
            clinics.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
