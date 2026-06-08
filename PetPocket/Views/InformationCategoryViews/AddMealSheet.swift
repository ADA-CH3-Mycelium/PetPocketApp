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

    @State private var vm: AddMealViewModel

    // UI-only state
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showDeleteConfirm = false
    @State private var showSymbolPicker = false

    init(detail: PetDetailStore, editing: RoutineCardItem? = nil) {
        _vm = State(initialValue: AddMealViewModel(detail: detail, editing: editing))
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
                                    Image(systemName: vm.selectedIcon)
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
                                field(label: "Meal Name", placeholder: "e.g. Breakfast", text: $vm.mealName)
                                Divider()
                                field(label: "Time", placeholder: "e.g. 8:00", text: $vm.time)
                            }
                        }

                        // ── Description ──────────────────────────────
                        formCard {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionLabel("Description")
                                TextField(
                                    "e.g. 1 Cup Dry Kibble. Mix with warm water to soften the grains.",
                                    text: $vm.description,
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

                                if vm.selectedImage != nil || vm.mediaData != nil {
                                    ZStack(alignment: .topTrailing) {
                                        if let img = vm.selectedImage {
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
                                            vm.clearMedia()
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
                                        Task { await vm.loadPicked(newItem) }
                                    }
                                }
                            }
                        }

                        // ── Error ────────────────────────────────────
                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        // ── Save ─────────────────────────────────────
                        Button {
                            Task { if await vm.save() { dismiss() } }
                        } label: {
                            Group {
                                if vm.isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(vm.saveLabel).fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(vm.canSave ? Color.primaryG : Color(.systemGray4))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!vm.canSave || vm.isSaving || vm.isDeleting)

                        // ── Delete (edit mode only) ──────────────────
                        if vm.isEditing {
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Group {
                                    if vm.isDeleting {
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
                            .disabled(vm.isSaving || vm.isDeleting)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(vm.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primaryG)
                }
            }
            .onAppear { vm.prefill() }
            .sheet(isPresented: $showSymbolPicker) {
                SymbolPickerSheet(selection: $vm.selectedIcon)
            }
            .alert("Delete this meal?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { Task { if await vm.deleteCard() { dismiss() } } }
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

}

#Preview {
    AddMealSheet(detail: PetDetailStore(pet: .sample))
}
