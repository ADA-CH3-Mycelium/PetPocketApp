//
//  ContactSheet.swift
//  PetPocket
//
//  Add / edit / delete an emergency contact.
//

import SwiftUI

struct ContactSheet: View {
    @Environment(\.dismiss) private var dismiss

    let detail: PetDetailStore
    var editing: ContactCardItem? = nil

    @State private var name = ""
    @State private var role = ""
    @State private var phone = ""
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
                                field("Name", "e.g. Naufal", $name)
                                Divider()
                                field("Relationship", "e.g. Neighbour", $role)
                                Divider()
                                field("Phone", "e.g. 0912xxxx", $phone, keyboard: .phonePad)
                            }
                        }

                        if let error = detail.errorMessage {
                            Text(error).font(.caption).foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button { Task { await save() } } label: {
                            Group {
                                if isSaving { ProgressView().tint(.white) }
                                else { Text(isEditing ? "Save Changes" : "Add Contact").fontWeight(.semibold) }
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
            .navigationTitle(isEditing ? "Edit Contact" : "Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.primaryG)
                }
            }
            .onAppear {
                if let e = editing {
                    name = e.name; role = e.relationship; phone = e.phone
                }
            }
            .alert("Delete this contact?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { Task { await deleteContact() } }
                Button("Cancel", role: .cancel) {}
            } message: { Text("This permanently removes the contact.") }
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
        let n = name.trimmingCharacters(in: .whitespaces)
        let r = role.trimmingCharacters(in: .whitespaces)
        let p = phone.trimmingCharacters(in: .whitespaces)
        let ok: Bool
        if let editing {
            ok = await detail.updateContact(id: editing.id, name: n, role: r, phone: p)
        } else {
            ok = await detail.addContact(name: n, role: r, phone: p)
        }
        isSaving = false
        if ok { dismiss() }
    }

    private func deleteContact() async {
        guard let editing else { return }
        isDeleting = true
        let ok = await detail.deleteContact(id: editing.id)
        isDeleting = false
        if ok { dismiss() }
    }
}

#Preview {
    ContactSheet(detail: PetDetailStore(pet: .sample))
}
