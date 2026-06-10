//
//  GenerateCodeViewModel.swift
//  PetPocket
//
//  View-model for GenerateCodeView. Owns the access-code generation that
//  previously called PetRepository directly from the view.
//

import Foundation
import Observation

@Observable
final class GenerateCodeViewModel {
    let petId: UUID

    init(petId: UUID) {
        self.petId = petId
    }

    var codeString = "------"
    var isGenerating = false
    var errorMessage: String?

    func generate() async {
        guard codeString == "------" else { return }   // only once
        isGenerating = true
        errorMessage = nil
        do {
            codeString = try await PetRepository.shared.generateAccessCode(petId: petId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isGenerating = false
    }
}
