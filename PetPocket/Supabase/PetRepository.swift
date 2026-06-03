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

    /// Pets the user can see but does not own (i.e. shared with them as sitter).
    func fetchSittingPets() async throws -> [PetRow] {
        let uid = try await currentUserId()
        let all: [PetRow] = try await client
            .from("pets")
            .select()
            .execute()
            .value
        return all.filter { $0.ownerId != uid }
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
