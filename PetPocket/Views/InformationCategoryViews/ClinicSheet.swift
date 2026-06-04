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
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        formCard {
                            VStack(spacing: 14) {
                                field("Clinic Name", "e.g. Oakwood Veterinary", $name)
                                Divider()
                                field("Address", "e.g. 1240 Oakwood Ave", $address)
                                Divider()
                                field("Phone", "e.g. (555) 012-3456", $phone, keyboard: .phonePad)
                                Divider()
                                HStack(spacing: 12) {
                                    field("Latitude", "e.g. 40.7128", $latitudeText, keyboard: .numbersAndPunctuation)
                                    field("Longitude", "e.g. -74.0060", $longitudeText, keyboard: .numbersAndPunctuation)
                                }
                                Text("Used to pin the clinic on the map. Leave blank to hide the map.")
                                    .font(.caption2).foregroundColor(.secondary)
                                Divider()
                                Toggle("Primary clinic", isOn: $isPrimary)
                                    .tint(Color.primaryG)
                            }
                        }

                        if let error = detail.errorMessage {
                            Text(error).font(.caption).foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button { Task { await save() } } label: {
                            Group {
                                if isSaving { ProgressView().tint(.white) }
                                else { Text(isEditing ? "Save Changes" : "Add Clinic").fontWeight(.semibold) }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(canSave ? Color.primaryG : Color(.systemGray4))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSave || isSaving || isDeleting)

                        if isEditing {
                            Button(role: .destructive) { showDeleteConfirm = true } label: {
                                Group {
                                    if isDeleting { ProgressView().tint(.red) }
                                    else { Label("Delete", systemImage: "trash").fontWeight(.semibold) }
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .foregroundColor(.red).background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isSaving || isDeleting)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(isEditing ? "Edit Clinic" : "Add Clinic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.primaryG)
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
            .alert("Delete this clinic?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { Task { await deleteClinic() } }
                Button("Cancel", role: .cancel) {}
            } message: { Text("This permanently removes the clinic.") }
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
