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

    let store: PetStore

    @State private var petName = ""
    @State private var selectedGender = "Male"
    @State private var age = "1"
    @State private var showAgePicker: Bool = false
    @State private var species = ""
    @State private var breed = ""
    @State private var selectedImage: UIImage? = nil
    @State private var pickedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var isSaving = false

    let genders = ["Male", "Female"]

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
                            if let image = selectedImage {
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
                        Task { await loadPicked(newItem) }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)

                    // Pet Name ------------------------------------

                    Section {
                        TextField("Buddy", text: $petName)

                    } header: {
                        Text("Name")
                            .modifier(onBoardingSectionHeaderStyle())

                    }

                    // SPECIES ------------------------------------
                    Section {

                        TextField("Breed", text: $breed)
                        TextField("Species (optional)", text: $species)

                    } header: {
                        Text("Breed")
                            .modifier(onBoardingSectionHeaderStyle())
                    }

                    // AGE ------------------------------------
                    Section {
                        HStack {
                            Text(age)
                            Spacer()
                            Text("years old")
                                .foregroundStyle(Color.secondary)
                        }
                        .onTapGesture {
                            withAnimation {
                                showAgePicker.toggle()
                            }
                        }

                        if showAgePicker {
                            Picker("Age", selection: $age) {

                                ForEach(1...100, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                            .pickerStyle(.wheel)
                            .padding()
                            .transition(
                                .move(edge: .bottom).combined(
                                    with: .opacity
                                )
                            )
                            .onChange(of: age) {
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.8
                                ) {
                                    withAnimation { showAgePicker = false }
                                }
                            }
                        }
                    } header: {
                        Text("Age")
                            .modifier(onBoardingSectionHeaderStyle())
                    }

                    .animation(
                        .easeInOut(duration: 0.25),
                        value: showAgePicker
                    )

                    // GENDER ------------------------------------
                    Section {
                        Picker(
                            selection: $selectedGender,
                            label: Text("Gender")
                        ) {
                            ForEach(genders, id: \.self) {
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

                if let error = store.errorMessage {
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
                    Button(action: { Task { await save() } }) {
                        //                        Text(isSaving ? "Saving…" : "Save")
                        //                            .fontWeight(.semibold)
                        //                            .foregroundStyle(.primary)

                        Image(systemName: "checkmark")
                    }
                    .disabled(
                        isSaving
                            || petName.trimmingCharacters(in: .whitespaces)
                                .isEmpty
                    )
                }
            }
        }

    }

    private func save() async {
        isSaving = true
        let ok = await store.addPet(
            name: petName.trimmingCharacters(in: .whitespaces),
            gender: selectedGender,
            ageText: age,
            species: species,
            breed: breed,
            imageData: imageData
        )
        isSaving = false
        if ok { dismiss() }
    }

    /// Loads the picked photo, downscales it, and keeps JPEG data for upload.
    private func loadPicked(_ item: PhotosPickerItem?) async {
        guard let item,
            let data = try? await item.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else { return }
        let resized = uiImage.downscaled(maxDimension: 1024)
        selectedImage = resized
        imageData = resized.jpegData(compressionQuality: 0.8)
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
