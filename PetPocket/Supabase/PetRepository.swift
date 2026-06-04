//
//  PetRepository.swift
//  PetPocket
//
//  Thin async wrapper over the Supabase Postgrest API. All access is
//  scoped by RLS to the signed-in user.
//

import Foundation
import Supabase

struct PetRepository {
    static let shared = PetRepository()

    private var client: SupabaseClient { supabase }

    // MARK: Identity
    func currentUserId() async throws -> UUID {
        try await client.auth.session.user.id
    }

    // MARK: Profile
    func fetchProfile() async throws -> ProfileRow {
        let uid = try await currentUserId()
        return try await client
            .from("profiles")
            .select()
            .eq("id", value: uid.uuidString)
            .single()
            .execute()
            .value
    }

    // MARK: Pets
    func fetchOwnedPets() async throws -> [PetRow] {
        let uid = try await currentUserId()
        return try await client
            .from("pets")
            .select()
            .eq("owner_id", value: uid.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    /// Pets the user has been explicitly granted sitter access to via pet_access.
    func fetchSittingPets() async throws -> [PetRow] {
        let uid = try await currentUserId()

        // Step 1: get the pet IDs this user is an active sitter for
        struct AccessRow: Decodable {
            let petId: UUID
            enum CodingKeys: String, CodingKey { case petId = "pet_id" }
        }
        let granted: [AccessRow] = try await client
            .from("pet_access")
            .select("pet_id")
            .eq("sitter_id", value: uid.uuidString)
            .eq("is_active", value: true)
            .execute()
            .value

        guard !granted.isEmpty else { return [] }

        // Step 2: fetch only those specific pets
        let ids = granted.map { $0.petId.uuidString }
        return try await client
            .from("pets")
            .select()
            .in("id", values: ids)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    @discardableResult
    func createPet(
        name: String,
        gender: String?,
        dateOfBirth: String?,
        breed: String?,
        species: String?,
        photoUrl: String?
    ) async throws -> PetRow {
        let uid = try await currentUserId()
        let payload = PetInsert(
            ownerId: uid,
            name: name,
            gender: gender,
            dateOfBirth: dateOfBirth,
            breed: breed,
            species: species,
            photoUrl: photoUrl
        )
        return try await client
            .from("pets")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    /// Uploads a pet avatar to the `pet-avatars` bucket under `<uid>/<uuid>.jpg`
    /// (path prefix must be the user id to satisfy the storage RLS policy).
    /// Returns the public URL string.
    func uploadPetAvatar(data: Data) async throws -> String {
        let uid = try await currentUserId()
        // Lowercase: storage RLS compares the path's first folder against
        // auth.uid()::text, which Postgres renders lowercase. Swift's
        // UUID.uuidString is uppercase, so an un-lowercased path => 400 (RLS deny).
        let path = "\(uid.uuidString.lowercased())/\(UUID().uuidString.lowercased()).jpg"
        try await client.storage
            .from("pet-avatars")
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        return try client.storage
            .from("pet-avatars")
            .getPublicURL(path: path)
            .absoluteString
    }

    /// Uploads a meal photo to the `pet-media` bucket.
    /// Returns the public URL string, or throws on failure.
    func uploadMealPhoto(data: Data) async throws -> String {
        let uid = try await currentUserId()
        let path = "\(uid.uuidString.lowercased())/meals/\(UUID().uuidString.lowercased()).jpg"
        try await client.storage
            .from("pet-media")
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        return try client.storage
            .from("pet-media")
            .getPublicURL(path: path)
            .absoluteString
    }

    // MARK: Category content

    func fetchMeals(petId: UUID) async throws -> [FeedingMealRow] {
        try await client
            .from("feeding_meals")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    @discardableResult
    func addMeal(
        petId: UUID,
        mealName: String,
        time: String,
        notes: String?,
        iconName: String?,
        mediaUrl: String?,
        sortOrder: Int?
    ) async throws -> FeedingMealRow {
        let payload = FeedingMealInsert(
            petId: petId,
            mealName: mealName,
            time: time,
            notes: notes,
            iconName: iconName,
            mediaUrl: mediaUrl,
            sortOrder: sortOrder
        )
        return try await client
            .from("feeding_meals")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchDietary(petId: UUID) async throws -> [DietaryRestrictionRow] {
        try await client
            .from("dietary_restrictions")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .execute()
            .value
    }

    func fetchCareItems(petId: UUID, category: String) async throws -> [CareItemRow] {
        try await client
            .from("care_items")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .eq("category", value: category)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func fetchContacts(petId: UUID) async throws -> [EmergencyContactRow] {
        try await client
            .from("emergency_contacts")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func fetchClinics(petId: UUID) async throws -> [VetClinicRow] {
        try await client
            .from("vet_clinics")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .execute()
            .value
    }

    // MARK: Access sharing
    /// Owner generates a 6-digit access code for a pet.
    @discardableResult
    func generateAccessCode(petId: UUID) async throws -> String {
        let uid = try await currentUserId()
        let code = String(format: "%06d", Int.random(in: 0...999_999))
        try await client
            .from("access_codes")
            .insert(AccessCodeInsert(petId: petId, createdBy: uid, code: code))
            .execute()
        return code
    }

    /// Sitter redeems a code. Runs the `redeem_access_code` SECURITY DEFINER
    /// RPC (RLS blocks a sitter from writing pet_access directly).
    @discardableResult
    func redeemAccessCode(_ code: String) async throws -> UUID {
        try await client
            .rpc("redeem_access_code", params: ["p_code": code])
            .execute()
            .value
    }
}
