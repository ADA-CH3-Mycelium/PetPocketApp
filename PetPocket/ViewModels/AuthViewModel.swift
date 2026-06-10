//
//  AuthViewModel.swift
//  PetPocket
//
//  View-model for LoginView / RegisterView. Owns the form fields,
//  validation rules, and auth submit that previously lived in the views.
//  Delegates the actual session work to AuthManager.shared.
//

import Foundation
import Observation

@Observable
final class AuthViewModel {
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    var errorMessage: String? { AuthManager.shared.errorMessage }

    var isLoginValid: Bool {
        email.contains("@") && email.contains(".")
            && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isRegisterValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty && !confirmPassword.isEmpty
            && password == confirmPassword
    }

    @discardableResult
    func login() async -> Bool {
        await AuthManager.shared.signIn(email: email, password: password)
        return AuthManager.shared.isAuthenticated
    }

    @discardableResult
    func register() async -> Bool {
        await AuthManager.shared.signUp(email: email, password: password, name: name)
        return AuthManager.shared.isAuthenticated
    }
}
