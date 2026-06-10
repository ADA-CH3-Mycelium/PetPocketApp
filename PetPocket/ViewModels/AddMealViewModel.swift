//
//  AddMealViewModel.swift
//  PetPocket
//
//  View-model for AddMealSheet (add + edit). Owns form fields, media
//  upload prep, and the save/delete calls that lived in the view.
//

import SwiftUI
import PhotosUI
import Observation

@Observable
final class AddMealViewModel {
    let detail: PetDetailStore
    /// Existing meal when editing; nil when adding.
    let editing: RoutineCardItem?

    init(detail: PetDetailStore, editing: RoutineCardItem? = nil) {
        self.detail = detail
        self.editing = editing
    }

    // Form fields
    var mealName = ""
    var time = ""
    var description = ""
    var selectedIcon = "fork.knife"

    // Media (optional) — photo or video
    var selectedImage: UIImage?
    var mediaData: Data?
    var mediaIsVideo = false

    // State
    var isSaving = false
    var isDeleting = false

    var isEditing: Bool { editing != nil }
    var title: String { isEditing ? "Edit Meal" : "Add Meal" }
    var saveLabel: String { isEditing ? "Save Changes" : "Add Meal" }
    var errorMessage: String? { detail.errorMessage }

    var canSave: Bool {
        !mealName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !time.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func prefill() {
        guard let meal = editing else { return }
        mealName     = meal.title
        time         = meal.time
        description  = meal.description
        selectedIcon = meal.icon
    }

    func clearMedia() {
        selectedImage = nil
        mediaData = nil
        mediaIsVideo = false
    }

    @discardableResult
    func save() async -> Bool {
        isSaving = true

        var uploadedUrl: String? = nil
        var mediaType: String? = nil
        if let data = mediaData {
            if mediaIsVideo {
                uploadedUrl = try? await PetRepository.shared.uploadMealMedia(
                    data: data, contentType: "video/quicktime", fileExtension: "mov")
                mediaType = uploadedUrl != nil ? "video" : nil
            } else {
                uploadedUrl = try? await PetRepository.shared.uploadMealMedia(
                    data: data, contentType: "image/jpeg", fileExtension: "jpg")
                mediaType = uploadedUrl != nil ? "photo" : nil
            }
        }

        let ok: Bool
        if let editing {
            ok = await detail.updateMeal(
                id: editing.id,
                mealName: mealName.trimmingCharacters(in: .whitespaces),
                time: time.trimmingCharacters(in: .whitespaces),
                notes: description.trimmingCharacters(in: .whitespaces),
                iconName: selectedIcon,
                mediaUrl: uploadedUrl,
                mediaType: mediaType
            )
        } else {
            ok = await detail.addMeal(
                mealName: mealName.trimmingCharacters(in: .whitespaces),
                time: time.trimmingCharacters(in: .whitespaces),
                notes: description.trimmingCharacters(in: .whitespaces),
                iconName: selectedIcon,
                mediaUrl: uploadedUrl,
                mediaType: mediaType
            )
        }
        isSaving = false
        return ok
    }

    /// Loads the picked photo OR video. Photo → downscaled JPEG; anything that
    /// isn't a decodable image is treated as a video (raw data uploaded as-is).
    func loadPicked(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self) else { return }
        if let ui = UIImage(data: data) {
            let resized = ui.mealDownscaled(maxDimension: 1024)
            selectedImage = resized
            mediaData = resized.jpegData(compressionQuality: 0.8)
            mediaIsVideo = false
        } else {
            selectedImage = nil
            mediaData = data
            mediaIsVideo = true
        }
    }

    @discardableResult
    func deleteCard() async -> Bool {
        guard let editing else { return false }
        isDeleting = true
        let ok = await detail.deleteMeal(id: editing.id)
        isDeleting = false
        return ok
    }
}

private extension UIImage {
    /// Aspect-fit downscale so the longest side <= maxDimension. No upscaling.
    func mealDownscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
