//
//  AddingNewPet.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import PhotosUI
import SwiftUI

struct AddingNewPetForm: View {

    @Environment(\.dismiss) private var dismiss

    @State private var vm: AddNewPetViewModel
    @State private var pickedItem: PhotosPickerItem? = nil

    init(store: PetStore) {
        _vm = State(initialValue: AddNewPetViewModel(store: store))
    }

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack {

                Form {
                    // Photo picker
                    PhotosPicker(
                        selection: $pickedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        ZStack {
                            if let image = vm.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding(35)
                                    .frame(width: 120, height: 120)
                                    .background(Color.secondaryG)
                                    .foregroundStyle(Color.primaryG)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .onChange(of: pickedItem) { _, newItem in
                        Task { await vm.loadPicked(newItem) }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)

                    // Pet Name ------------------------------------

                    Section {
                        TextField("Buddy", text: $vm.petName)

                    } header: {
                        Text("Name")
                            .modifier(onBoardingSectionHeaderStyle())

                    }

                    // SPECIES ------------------------------------
                    Section {

                        TextField("Breed", text: $vm.breed)
                        TextField("Species (optional)", text: $vm.species)

                    } header: {
                        Text("Breed")
                            .modifier(onBoardingSectionHeaderStyle())
                    }

                    // DATE OF BIRTH ------------------------------------
                    Section {
                        DatePicker(
                            "Date of Birth",
                            selection: $vm.dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                    } header: {
                        Text("Date of Birth")
                            .modifier(onBoardingSectionHeaderStyle())
                    }

                    // GENDER ------------------------------------
                    Section {
                        Picker(
                            selection: $vm.selectedGender,
                            label: Text("Gender")
                        ) {
                            ForEach(vm.genders, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()

                    } header: {
                        Text("Gender")
                            .modifier(onBoardingSectionHeaderStyle())
                    }.listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                }
                .listStyle(.plain)
                .listSectionSpacing(10)
                .scrollContentBackground(.hidden)

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

            }
            //title
            .navigationTitle("Add a new pet")
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle("Tell us about your companion")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { Task { await vm.save() } }) {
                        //                        Text(vm.isSaving ? "Saving…" : "Save")
                        //                            .fontWeight(.semibold)
                        //                            .foregroundStyle(.primary)

                        Image(systemName: "checkmark")
                    }
                    .disabled(
                        vm.isSaving
                            || vm.petName.trimmingCharacters(in: .whitespaces)
                                .isEmpty
                    )
                }
            }
        }

    }

    /// Loads the picked photo, downscales it, and keeps JPEG data for upload.
    private func loadPicked(_ item: PhotosPickerItem?) async {
        guard let item,
            let data = try? await item.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else { return }
        let resized = uiImage.downscaled(maxDimension: 1024)
        vm.selectedImage = resized
        vm.imageData = resized.jpegData(compressionQuality: 0.8)
    }
}

extension UIImage {
    /// Aspect-fit downscale so the longest side <= maxDimension. No upscaling.
    fileprivate func downscaled(maxDimension: CGFloat) -> UIImage {
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
