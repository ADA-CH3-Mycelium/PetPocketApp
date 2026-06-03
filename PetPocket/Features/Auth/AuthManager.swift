//
//  AuthManager.swift
//  PetPocket
//

import Foundation
import Supabase

@Observable
class AuthManager {
    static let shared = AuthManager()

    var session: Session?
    var isLoading = false
    var errorMessage: String?

    var isAuthenticated: Bool { session != nil }

    init() {
        Task { await restoreSession() }
    }

    // Restore existing session on app launch
    @MainActor
    func restoreSession() async {
        do {
            session = try await supabase.auth.session
        } catch {
            session = nil
        }
    }

    @MainActor
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            session = try await supabase.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
            session = response.session
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            session = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
