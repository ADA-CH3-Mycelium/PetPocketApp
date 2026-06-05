//
//  AddMealSheet.swift
//  PetPocket
//
//  Used for both Adding a new meal and Editing an existing one.
//  Pass `editing: meal` to pre-fill all fields for editing.
//

import SwiftUI
import PhotosUI

struct AddMealSheet: View {
    @Environment(\.dismiss) private var dismiss

    let detail: PetDetailStore
    /// Pass an existing meal here to pre-fill fields for editing
    var editing: RoutineCardItem? = nil

    // Form fields
    @State private var mealName = ""
    @State private var time = ""
    @State private var description = ""
    @State private var selectedIcon = "fork.knife"

    // Media (optional) — photo or video
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var mediaData: Data? = nil
    @State private var mediaIsVideo = false

    // State
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirm = false
    @State private var showSymbolPicker = false

    private var isEditing: Bool { editing != nil }
    private var title: String { isEditing ? "Edit Meal" : "Add Meal" }
    private var saveLabel: String { isEditing ? "Save Changes" : "Add Meal" }

    private var canSave: Bool {
        !mealName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !time.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // ── Icon picker ──────────────────────────────
                        formCard {
                            Button { showSymbolPicker = true } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: selectedIcon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 52, height: 52)
                                        .background(Color.primaryG)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))

                                    VStack(alignment: .leading, spacing: 2) {
                                        sectionLabel("Icon")
                                        Text("Tap to choose a symbol")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        // ── Meal name + Time ─────────────────────────
                        formCard {
                            VStack(spacing: 14) {
                                field(label: "Meal Name", placeholder: "e.g. Breakfast", text: $mealName)
                                Divider()
                                field(label: "Time", placeholder: "e.g. 8:00", text: $time)
                            }
                        }

                        // ── Description ──────────────────────────────
                        formCard {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionLabel("Description")
                                TextField(
                                    "e.g. 1 Cup Dry Kibble. Mix with warm water to soften the grains.",
                                    text: $description,
                                    axis: .vertical
                                )
                                .lineLimit(3...6)
                                .textFieldStyle(.plain)
                                .font(.body)
                            }
                        }

                        // ── Photo / Video (optional) ─────────────────
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    sectionLabel("Photo or Video")
                                    Text("Optional")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                if selectedImage != nil || mediaData != nil {
                                    ZStack(alignment: .topTrailing) {
                                        if let img = selectedImage {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 160)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        } else {
                                            // video selected — show placeholder
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.8))
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 160)
                                                .overlay(
                                                    VStack(spacing: 6) {
                                                        Image(systemName: "play.circle.fill")
                                                            .font(.system(size: 40))
                                                        Text("Video selected").font(.caption)
                                                    }
                                                    .foregroundColor(.white)
                                                )
                                        }

                                        Button {
                                            selectedImage = nil
                                            mediaData = nil
                                            mediaIsVideo = false
                                            photoItem = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white, Color.black.opacity(0.5))
                                                .padding(6)
                                        }
                                    }
                                } else {
                                    PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .videos])) {
                                        HStack(spacing: 10) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.title3)
                                                .foregroundColor(.primaryG)
                                            Text("Add a photo or video")
                                                .foregroundColor(.primaryG)
                                                .fontWeight(.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.primaryG.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .onChange(of: photoItem) { _, newItem in
                                        Task { await loadPicked(newItem) }
                                    }
                                }
                            }
                        }

                        // ── Error ────────────────────────────────────
                        if let error = detail.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        // ── Save ─────────────────────────────────────
                        Button {
                            Task { await save() }
                        } label: {
                            Group {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(saveLabel).fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canSave ? Color.primaryG : Color(.systemGray4))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSave || isSaving || isDeleting)

                        // ── Delete (edit mode only) ──────────────────
                        if isEditing {
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Group {
                                    if isDeleting {
                                        ProgressView().tint(.red)
                                    } else {
                                        Label("Delete Meal", systemImage: "trash")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundColor(.red)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isSaving || isDeleting)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primaryG)
                }
            }
            .onAppear { prefill() }
            .sheet(isPresented: $showSymbolPicker) {
                SymbolPickerSheet(selection: $selectedIcon)
            }
            .alert("Delete this meal?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { Task { await deleteCard() } }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes the meal card.")
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func formCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        content()
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline).fontWeight(.medium)
            .foregroundColor(.primary)
    }

    @ViewBuilder
    private func field(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel(label)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.body)
        }
    }

    // MARK: - Helpers

    private func prefill() {
        guard let meal = editing else { return }
        mealName      = meal.title
        time          = meal.time
        description   = meal.description
        selectedIcon  = meal.icon
    }

    private func save() async {
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
            // EDIT: update the existing row, don't insert a new one.
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
        if ok { dismiss() }
    }

    /// Loads the picked photo OR video. Photo → downscaled JPEG; anything that
    /// isn't a decodable image is treated as a video (raw data uploaded as-is).
    private func loadPicked(_ item: PhotosPickerItem?) async {
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

    private func deleteCard() async {
        guard let editing else { return }
        isDeleting = true
        let ok = await detail.deleteMeal(id: editing.id)
        isDeleting = false
        if ok { dismiss() }
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

#Preview {
    AddMealSheet(detail: PetDetailStore(pet: .sample))
}
