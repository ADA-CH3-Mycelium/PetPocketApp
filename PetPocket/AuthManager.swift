//
//  AuthManager.swift
//  PetPocket
//
//  Handles Supabase Auth (Sign Up, Login, Profile creation).
//

import Foundation
import Supabase
import SwiftUI

@Observable
class AuthManager {
    static let shared = AuthManager()
    
    var session: Session?
    var profile: Profile?
    var isLoading = false
    var errorMessage: String?
    
    var currentUser: User? {
        session?.user
    }
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    @MainActor
    func checkSession() async {
        do {
            self.session = try await supabase.auth.session
            if let user = session?.user {
                await fetchProfile(for: user.id)
            }
        } catch {
            print("Session check error: \(error)")
        }
    }
    
    @MainActor
    func fetchProfile(for id: UUID) async {
        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
            self.profile = profile
        } catch {
            print("Fetch profile error: \(error)")
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // supabase-swift v2: signIn returns Session directly
            self.session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            if let user = session?.user {
                await fetchProfile(for: user.id)
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.auth.signUp(
                email: email, 
                password: password, 
                data: ["name": .string(name)]
            )
            self.session = response.session
            
            if let user = session?.user {
                await fetchProfile(for: user.id)
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.profile = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
