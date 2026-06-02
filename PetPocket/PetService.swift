//
//  PetService.swift
//  PetPocket
//
//  Service for Pet CRUD operations using Supabase.
//

import Foundation
import Supabase

@Observable
class PetService {
    static let shared = PetService()
    
    var pets: [Pet] = []
    var isLoading = false
    var errorMessage: String?
    
    @MainActor
    func fetchPets() async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await supabase.auth.session.user
            let fetchedPets: [Pet] = try await supabase
                .from("pets")
                .select()
                .filter("owner_id", operator: "eq", value: user.id.uuidString)
                .execute()
                .value
            
            self.pets = fetchedPets
            isLoading = false
        } catch {
            isLoading = false
            self.errorMessage = error.localizedDescription
            print("Fetch pets error: \(error)")
        }
    }
    
    @MainActor
    func createPet(name: String, breed: String?, species: String?) async {
        isLoading = true
        do {
            let user = try await supabase.auth.session.user
            let newPet = Pet(
                id: UUID(),
                ownerID: user.id,
                name: name,
                breed: breed,
                species: species,
                createdAt: nil,
                updatedAt: nil
            )
            
            try await supabase
                .from("pets")
                .insert(newPet)
                .execute()
            
            await fetchPets()
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
