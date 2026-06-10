//
//  AddMealSheet.swift
//  PetPocket
//
//  Used for both Adding a new meal and Editing an existing one.
//  Pass `editing: meal` to pre-fill all fields for editing.
//

import PhotosUI
import SwiftUI

struct AddMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm: AddMealViewModel
    
    // UI-only state
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showDeleteConfirm = false
    @State private var showSymbolPicker = false
    
    private var isEditing: Bool { vm.editing != nil }
    private var title: String { isEditing ? "Edit Meal" : "Add Meal" }
    private var saveLabel: String { isEditing ? "Save Changes" : "Add Meal" }
    
    private var canSave: Bool {
        !vm.mealName.trimmingCharacters(in: .whitespaces).isEmpty
        && !vm.time.trimmingCharacters(in: .whitespaces).isEmpty
        && !vm.description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(detail: PetDetailStore, editing: RoutineCardItem? = nil) {
        _vm = State(initialValue: AddMealViewModel(detail: detail, editing: editing))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background).ignoresSafeArea()
                
                Form {
                    Section {
                        
                        HStack(spacing: 20) {
                            
                            // ── Icon picker ──────────────────────────────
                            VStack {
                                Button {
                                    showSymbolPicker = true
                                } label: {
                                    Image(systemName: vm.selectedIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(10)
                                        .frame(width: 40, height: 50)
                                    
                                }
                                .buttonBorderShape(.roundedRectangle)
                                .buttonStyle(.glassProminent)
                                .tint(Color.primaryG)
                                
                                Text("select icon")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            // ── Meal name + Time ─────────────────────────
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("Meal Name", text: $vm.mealName)
                                    .padding(5)
                                
                                Divider()
                                
                                TextField("8:00", text: $vm.time)
                                    .padding(5)
                            }
                            
                        }
                        
                    } header: {
                        Text("Meal Details")
                            .modifier(onBoardingSectionHeaderStyle())
                    }
                    
                    // ── Description ──────────────────────────────
                    
                    Section {
                        TextField(
                            "Enter detailed meal description and instructions here.",
                            text: $vm.description,
                            axis: .vertical
                        )
                        .lineLimit(4...8)
                        .frame(minHeight: 100, alignment: .topLeading)
                    } header: {
                        Text("Description")
                            .modifier(onBoardingSectionHeaderStyle())
                    }
                    
                    // ── Photo / Video (optional) ─────────────────
                    Section {
                        
                        if vm.selectedImage != nil || vm.mediaData != nil {
                            ZStack(alignment: .topTrailing) {
                                if let img = vm.selectedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                        )
                                } else {
                                    // video selected — show placeholder
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.8))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(
                                                systemName:
                                                    "play.circle.fill"
                                            )
                                            .font(.system(size: 40))
                                            
                                            .foregroundColor(.white)
                                        )
                                }
                                
                                Button {
                                    vm.selectedImage = nil
                                    vm.mediaData = nil
                                    vm.mediaIsVideo = false
                                    photoItem = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(
                                            .white,
                                            Color.black.opacity(0.5)
                                        )
                                        .padding(6)
                                }
                            }
                        } else {
                            // add photo / video button state
                            PhotosPicker(
                                selection: $photoItem,
                                matching: .any(of: [.images, .videos])
                            ) {
                                
                                Label(
                                    "Add Media",
                                    systemImage: "photo.badge.plus"
                                )
                                .labelStyle(.iconOnly)
                                .font(.title3)
                                .foregroundColor(.primaryG)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .glassEffect(
                                    .regular.tint(Color.secondaryG),
                                    in: .rect(cornerRadius: 12)
                                )
                                
                            }
                            
                            .onChange(of: photoItem) { _, newItem in
                                Task { await vm.loadPicked(newItem) }
                            }
                        }
                        
                    } header: {
                        Text("Visual Media (optional)")
                            .modifier(onBoardingSectionHeaderStyle())
                    } .listRowInsets(EdgeInsets())
                    
                    
                    // ── Delete (edit mode only) ──────────────────
                    if vm.isEditing {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            if vm.isDeleting {
                                ProgressView().tint(.red)
                            } else {
                                HStack(spacing: 2) {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                } .padding(10)
                                
                            }
                        }
                        .foregroundColor(.secondary)
                        .buttonStyle(.glass)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(.clear))
                        .disabled(vm.isSaving || vm.isDeleting)
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(.compact)
                
                // ── Error ────────────────────────────────────
                if let error = vm.detail.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }
                
            }
            .navigationTitle(vm.title)
            .navigationBarTitleDisplayMode(.inline)
            // toolbar
            .toolbar {
                // cancel
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                
                // save changes
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("save changes btn pressed")
                        Task { if await vm.save() { dismiss() } }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(
                                vm.isSaving ? Color.secondary : Color.accent
                            )
                        
                    }
                    .disabled(!vm.canSave || vm.isSaving || vm.isDeleting)
                }
                
            }
            .onAppear { vm.prefill() }
            .sheet(isPresented: $showSymbolPicker) {
                SymbolPickerSheet(selection: $vm.selectedIcon)
            }
            .alert("Are you sure you want to delete this meal?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    Task { await vm.deleteCard(); dismiss()}
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the meal forever.")
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
    private func field(
        label: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel(label)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.body)
        }
    }
    
    // MARK: - Helpers
    
    private func prefill() {
        guard let meal = vm.editing else { return }
        vm.mealName = meal.title
        vm.time = meal.time
        vm.description = meal.description
        vm.selectedIcon = meal.icon
    }
    
    private func save() async {
        vm.isSaving = true
        
        var uploadedUrl: String? = nil
        var mediaType: String? = nil
        if let data = vm.mediaData {
            if vm.mediaIsVideo {
                uploadedUrl = try? await PetRepository.shared.uploadMealMedia(
                    data: data,
                    contentType: "video/quicktime",
                    fileExtension: "mov"
                )
                mediaType = uploadedUrl != nil ? "video" : nil
            } else {
                uploadedUrl = try? await PetRepository.shared.uploadMealMedia(
                    data: data,
                    contentType: "image/jpeg",
                    fileExtension: "jpg"
                )
                mediaType = uploadedUrl != nil ? "photo" : nil
            }
        }
        //
        //        let ok: Bool
        //        if let vm.editing {
        //            // EDIT: update the existing row, don't insert a new one.
        //            ok = await vm.detail.updateMeal(
        //                id: vm.editing.id,
        //                mealName: vm.mealName.trimmingCharacters(in: .whitespaces),
        //                time: vm.time.trimmingCharacters(in: .whitespaces),
        //                notes: vm.description.trimmingCharacters(in: .whitespaces),
        //                iconName: vm.selectedIcon,
        //                mediaUrl: uploadedUrl,
        //                mediaType: mediaType
        //            )
        //        } else {
        //            ok = await detail.addMeal(
        //                mealName: mealName.trimmingCharacters(in: .whitespaces),
        //                time: time.trimmingCharacters(in: .whitespaces),
        //                notes: description.trimmingCharacters(in: .whitespaces),
        //                iconName: selectedIcon,
        //                mediaUrl: uploadedUrl,
        //                mediaType: mediaType
        //            )
        //        }
        //        isSaving = false
        //        if ok { dismiss() }
        //    }
        
        /// Loads the picked photo OR video. Photo → downscaled JPEG; anything that
        /// isn't a decodable image is treated as a video (raw data uploaded as-is).
        //    private func loadPicked(_ item: PhotosPickerItem?) async {
        //        guard let item,
        //            let data = try? await item.loadTransferable(type: Data.self)
        //        else { return }
        //        if let ui = UIImage(data: data) {
        //            let resized = ui.mealDownscaled(maxDimension: 1024)
        //            selectedImage = resized
        //            mediaData = resized.jpegData(compressionQuality: 0.8)
        //            mediaIsVideo = false
        //        } else {
        //            selectedImage = nil
        //            mediaData = data
        //            mediaIsVideo = true
        //        }
        //    }
        
        //    private func deleteCard() async {
        //        guard let editing else { return }
        //        isDeleting = true
        //        let ok = await detail.deleteMeal(id: editing.id)
        //        isDeleting = false
        //        if ok { dismiss() }
        //    }
    }
}


#Preview {
    AddMealSheet(detail: PetDetailStore(pet: .sample))
}


extension UIImage {
    /// Aspect-fit downscale so the longest side <= maxDimension. No upscaling.
    fileprivate func mealDownscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
