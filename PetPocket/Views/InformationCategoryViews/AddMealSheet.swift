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

    // Photo (optional)
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

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

                        // ── Photo (optional) ─────────────────────────
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    sectionLabel("Photo")
                                    Text("Optional")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                if let img = selectedImage {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))

                                        Button {
                                            selectedImage = nil
                                            photoItem = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white, Color.black.opacity(0.5))
                                                .padding(6)
                                        }
                                    }
                                } else {
                                    PhotosPicker(selection: $photoItem, matching: .images) {
                                        HStack(spacing: 10) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.title3)
                                                .foregroundColor(.primaryG)
                                            Text("Add a photo")
                                                .foregroundColor(.primaryG)
                                                .fontWeight(.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.primaryG.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .onChange(of: photoItem) { _, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let ui = UIImage(data: data) {
                                                selectedImage = ui
                                            }
                                        }
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
        if let img = selectedImage, let data = img.jpegData(compressionQuality: 0.8) {
            uploadedUrl = try? await PetRepository.shared.uploadMealPhoto(data: data)
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
                mediaUrl: uploadedUrl
            )
        } else {
            ok = await detail.addMeal(
                mealName: mealName.trimmingCharacters(in: .whitespaces),
                time: time.trimmingCharacters(in: .whitespaces),
                notes: description.trimmingCharacters(in: .whitespaces),
                iconName: selectedIcon,
                mediaUrl: uploadedUrl
            )
        }
        isSaving = false
        if ok { dismiss() }
    }

    private func deleteCard() async {
        guard let editing else { return }
        isDeleting = true
        let ok = await detail.deleteMeal(id: editing.id)
        isDeleting = false
        if ok { dismiss() }
    }
}

#Preview {
    AddMealSheet(detail: PetDetailStore(pet: .sample))
}
