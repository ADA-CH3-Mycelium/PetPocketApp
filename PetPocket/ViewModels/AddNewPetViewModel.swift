//
//  AddNewPetViewModel.swift
//  PetPocket
//
//  View-model for AddingNewPetForm. Owns the form fields, image
//  downscale/upload prep, and the save call that lived in the view.
//

import SwiftUI
import PhotosUI
import Observation

@Observable
final class AddNewPetViewModel {
    let store: PetStore

    init(store: PetStore) {
        self.store = store
    }

    var petName = ""
    var selectedGender = "Male"
    var dateOfBirth = Date()
    var species = ""
    var breed = ""
    var selectedImage: UIImage?
    var imageData: Data?
    var isSaving = false

    let genders = ["Male", "Female"]

    var canSave: Bool {
        !isSaving && !petName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var errorMessage: String? { store.errorMessage }

    @discardableResult
    func save() async -> Bool {
        isSaving = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dobString = formatter.string(from: dateOfBirth)

        let ok = await store.addPet(
            name: petName.trimmingCharacters(in: .whitespaces),
            gender: selectedGender,
            dateOfBirthString: dobString,
            species: species,
            breed: breed,
            imageData: imageData
        )
        isSaving = false
        return ok
    }

    /// Loads the picked photo, downscales it, and keeps JPEG data for upload.
    func loadPicked(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        let resized = uiImage.downscaled(maxDimension: 1024)
        selectedImage = resized
        imageData = resized.jpegData(compressionQuality: 0.8)
    }
}

private extension UIImage {
    /// Aspect-fit downscale so the longest side <= maxDimension. No upscaling.
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
