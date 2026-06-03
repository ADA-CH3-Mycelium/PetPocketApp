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
                    title: row.mealName,
                    time: row.time,
                    description: [row.amount, row.notes].compactMap { $0 }.joined(separator: ". "),
                    icon: row.iconName ?? "fork.knife"
                )
            }

            let diet = try await dietRows
            allergies = diet.filter { $0.type == "allergy" }.map(\.item)
            restricted = diet.filter { $0.type == "restricted" }.map(\.item)

            wasteItems = try await wasteRows.map(Self.card)
            careItems = try await careRows.map(Self.card)
            firstAid = try await emergencyRows.map(Self.card)

            contacts = try await contactRows.map { row in
                ContactCardItem(
                    name: row.name,
                    relationship: row.role ?? "",
                    note: row.role ?? "",
                    phone: row.phone ?? ""
                )
            }

            clinics = try await clinicRows.map { row in
                VetClinicCardItem(
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

    private static func card(_ row: CareItemRow) -> RoutineCardItem {
        RoutineCardItem(
            title: row.title ?? "",
            time: "",
            description: row.content ?? "",
            icon: row.icon ?? "info.circle.fill"
        )
    }
}
