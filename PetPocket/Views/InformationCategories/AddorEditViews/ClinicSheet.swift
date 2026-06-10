//
//  ClinicSheet.swift
//  PetPocket
//
//  Add / edit / delete a trusted vet clinic.
//

import SwiftUI

struct ClinicSheet: View {
    @Environment(\.dismiss) private var dismiss

    let detail: PetDetailStore
    var editing: VetClinicCardItem? = nil

    @State private var name = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var latitudeText = ""
    @State private var longitudeText = ""
    @State private var isPrimary = false
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirm = false

    private var isEditing: Bool { editing != nil }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background).ignoresSafeArea()

                Form {
                    // clinic name -------------------------
                    Section {
                        TextField("Oakwood Veterinary", text: $name)
                    } header: {
                        Text("Clinic Name")
                            .modifier(onBoardingSectionHeaderStyle())
                    }
                    
                    // address -------------------------
                    Section {
                        TextField("1240 Oakwood Ave", text: $address)
                            .textContentType(.fullStreetAddress)
                    } header: {
                        Text("Address")
                            .modifier(onBoardingSectionHeaderStyle())
                    }
                    
                    // phone -------------------------
                    Section {
                        TextField("(555) 012-3456", text: $phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.numberPad)
                    } header: {
                        Text("Phone Number")
                            .modifier(onBoardingSectionHeaderStyle())
                    }
                    
                    // set as default clinic -------------------------
                    Section {
                        Toggle("Set as primary clinic", isOn: $isPrimary)
                            //.tint(Color.primaryG)
                    }
                    
                    
                    // ── Delete (edit mode only) ──────────────────
                    if isEditing {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            if isDeleting {
                                ProgressView().tint(.red)
                            } else {
                                HStack(spacing: 2) {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }.padding(10)

                            }
                        }
                        .foregroundColor(.secondary)
                        .buttonStyle(.glass)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(.clear))
                        .disabled(isSaving || isDeleting)
                    }
                    
                    
                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(.compact)

//                                HStack(spacing: 12) {
//                                    field("Latitude", "e.g. 40.7128", $latitudeText, keyboard: .numbersAndPunctuation)
//                                    field("Longitude", "e.g. -74.0060", $longitudeText, keyboard: .numbersAndPunctuation)
//                                }
//                                Text("Used to pin the clinic on the map. Leave blank to hide the map.")
//                                    .font(.caption2).foregroundColor(.secondary)

                        
                        // error msg
                        if let error = detail.errorMessage {
                            Text(error).font(.caption).foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                
            }
            .navigationTitle(isEditing ? "Edit Clinic" : "Add Clinic")
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
                        Task {
                            await save()

                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(
                                isSaving ? Color.secondary : Color.accent
                            )

                    }
                    .disabled(!canSave || isSaving || isDeleting)
                }

            }
            .onAppear {
                if let e = editing {
                    name = e.name; address = e.address; phone = e.phone
                    isPrimary = e.note == "Primary clinic"
                    latitudeText = e.latitude.map { String($0) } ?? ""
                    longitudeText = e.longitude.map { String($0) } ?? ""
                }
            }
            .alert("Are you sure you want to delete this clinic?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { Task { await deleteClinic() } }
                Button("Cancel", role: .cancel) {}
            } message: { Text("This will permanently delete the clinic forever.") }
        }
    }

    @ViewBuilder
    private func formCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        content().padding(16).background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func field(_ label: String, _ placeholder: String, _ text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline).fontWeight(.medium)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain).font(.body).keyboardType(keyboard)
        }
    }

    private func save() async {
        isSaving = true
        let ok: Bool
        let n = name.trimmingCharacters(in: .whitespaces)
        let a = address.trimmingCharacters(in: .whitespaces)
        let p = phone.trimmingCharacters(in: .whitespaces)
        let lat = Double(latitudeText.trimmingCharacters(in: .whitespaces))
        let lon = Double(longitudeText.trimmingCharacters(in: .whitespaces))
        if let editing {
            ok = await detail.updateClinic(id: editing.id, name: n, address: a, phone: p, latitude: lat, longitude: lon, isPrimary: isPrimary)
        } else {
            ok = await detail.addClinic(name: n, address: a, phone: p, latitude: lat, longitude: lon, isPrimary: isPrimary)
        }
        isSaving = false
        if ok { dismiss() }
    }

    private func deleteClinic() async {
        guard let editing else { return }
        isDeleting = true
        let ok = await detail.deleteClinic(id: editing.id)
        isDeleting = false
        if ok { dismiss() }
    }
}

#Preview {
    ClinicSheet(detail: PetDetailStore(pet: .sample))
}
