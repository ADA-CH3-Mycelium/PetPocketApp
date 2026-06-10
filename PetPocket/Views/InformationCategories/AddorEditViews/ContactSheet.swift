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
    @State private var contactDescription = ""
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirm = false

    private var isEditing: Bool { editing != nil }
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background).ignoresSafeArea()
                Form {
                    // name -------------------------
                    Section {
                        TextField("Naufal", text: $name)
                    } header: {
                        Text("Name")
                            .modifier(onBoardingSectionHeaderStyle())
                    }

                    // relationship -------------------------
                    Section {
                        TextField("Neighbour", text: $role)
                    } header: {
                        Text("Relationship")
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

                    // ── Description ──────────────────────────────

                    Section {
                        TextField(
                            "Enter additional information about this contact.",
                            text: $contactDescription,
                            axis: .vertical
                        )
                        .lineLimit(1...3)
                        .frame(minHeight: 80, alignment: .topLeading)
                    } header: {
                        Text("Additional Information (optional)")
                            .modifier(onBoardingSectionHeaderStyle())
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

                // error msg

                if let error = detail.errorMessage {
                    Text(error).font(.caption).foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

            }
            .navigationTitle(isEditing ? "Edit Contact" : "Add Contact")
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
                    name = e.name
                    role = e.relationship
                    phone = e.phone
                    contactDescription = e.note
                }
            }
            .alert("Delete this contact?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    Task { await deleteContact() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes the contact.")
            }
        }
    }

    @ViewBuilder
    private func formCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        content().padding(16).background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func field(
        _ label: String,
        _ placeholder: String,
        _ text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
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
        let d = contactDescription.trimmingCharacters(in: .whitespaces)
        let ok: Bool
        if let editing {
            ok = await detail.updateContact(
                id: editing.id,
                name: n,
                role: r,
                phone: p,
                description: d
            )
        } else {
            ok = await detail.addContact(
                name: n,
                role: r,
                phone: p,
                description: d
            )
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
