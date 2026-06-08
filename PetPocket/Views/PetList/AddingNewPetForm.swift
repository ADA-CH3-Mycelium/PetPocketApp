//
//  AddingNewPet.swift
//  PetPocket
//
//  Created by Michel Pierce on 28/05/26.
//

import SwiftUI
import PhotosUI

struct AddingNewPetForm: View {
    
    @Environment(\.dismiss) private var dismiss

    @State private var vm: AddNewPetViewModel
    @State private var pickedItem: PhotosPickerItem? = nil

    init(store: PetStore) {
        _vm = State(initialValue: AddNewPetViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Card
                VStack(spacing: 20) {
                    // Title
                    VStack(spacing: 4) {
                        Text("Add New Pet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Tell us about your furry companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Photo picker
                    PhotosPicker(selection: $pickedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if let image = vm.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                            } else {
                                VStack(spacing: -16) {
                                    Image("AddPetProfileImg")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 128, height: 128)
                                        .foregroundColor(.secondary)
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onChange(of: pickedItem) { _, newItem in
                        Task { await vm.loadPicked(newItem) }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Pet Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Pet Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("e.g. Buddy", text: $vm.petName)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Gender toggle
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gender")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 0) {
                            ForEach(vm.genders, id: \.self) { gender in
                                Button(action: { vm.selectedGender = gender }) {
                                    HStack(spacing: 6) {
                                        Text(gender)
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        vm.selectedGender == gender
                                        ? Color.primaryG
                                        : Color(.systemGray6)
                                    )
                                    .foregroundColor(
                                        vm.selectedGender == gender ? .white : .secondary
                                    )
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Age + Species
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("e.g. 3 yrs", text: $vm.age)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Species")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("e.g. Dog", text: $vm.species)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    // Breed
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Breed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("e.g. Golden Retriever", text: $vm.breed)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Save button
                    Button(action: { Task { if await vm.save() { dismiss() } } }) {
                        Text(vm.isSaving ? "Saving…" : "Save Pet")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: 220)
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(Color.primaryG)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
                    .disabled(!vm.canSave)

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primaryG)
                        Text("Back")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.primaryG)
                        
                    }
                    .foregroundColor(.accentColor)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("PawPocket")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryG)
                
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { Task { if await vm.save() { dismiss() } } }) {
                    Text(vm.isSaving ? "Saving…" : "Save")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .disabled(!vm.canSave)
            }
        }
    }
}
