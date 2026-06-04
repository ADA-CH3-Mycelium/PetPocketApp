//
//  CareItemSheet.swift
//  PetPocket
//
//  Add / edit / delete a care_items card. Shared by Waste, Care and the
//  Emergency first-aid section (category passed in).
//

import SwiftUI

struct CareItemSheet: View {
    @Environment(\.dismiss) private var dismiss

    let detail: PetDetailStore
    let category: String                 // "waste" | "care" | "emergency"
    var editing: RoutineCardItem? = nil

    @State private var titleText = ""
    @State private var content = ""
    @State private var selectedIcon = "info.circle.fill"
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirm = false
    @State private var showSymbolPicker = false

    private var isEditing: Bool { editing != nil }
    private var navTitle: String {
        let noun = category == "emergency" ? "First Aid" : (category == "waste" ? "Routine" : "Note")
        return isEditing ? "Edit \(noun)" : "Add \(noun)"
    }
    private var canSave: Bool {
        !titleText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {

                        // Icon
                        formCard {
                            Button { showSymbolPicker = true } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: selectedIcon)
                                        .font(.title2).foregroundColor(.white)
                                        .frame(width: 52, height: 52)
                                        .background(Color.primaryG)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    VStack(alignment: .leading, spacing: 2) {
                                        sectionLabel("Icon")
                                        Text("Tap to choose a symbol")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline).foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        // Title
                        formCard {
                            VStack(alignment: .leading, spacing: 6) {
                                sectionLabel("Title")
                                TextField("e.g. Backyard", text: $titleText)
                                    .textFieldStyle(.plain).font(.body)
                            }
                        }

                        // Description / content
                        formCard {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionLabel("Description")
                                TextField("Details…", text: $content, axis: .vertical)
                                    .lineLimit(3...6)
                                    .textFieldStyle(.plain).font(.body)
                            }
                        }

                        if let error = detail.errorMessage {
                            Text(error).font(.caption).foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Save
                        Button { Task { await save() } } label: {
                            Group {
                                if isSaving { ProgressView().tint(.white) }
                                else { Text(isEditing ? "Save Changes" : "Add").fontWeight(.semibold) }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(canSave ? Color.primaryG : Color(.systemGray4))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSave || isSaving || isDeleting)

                        // Delete (edit only)
                        if isEditing {
                            Button(role: .destructive) { showDeleteConfirm = true } label: {
                                Group {
                                    if isDeleting { ProgressView().tint(.red) }
                                    else { Label("Delete", systemImage: "trash").fontWeight(.semibold) }
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
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
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.primaryG)
                }
            }
            .onAppear {
                if let e = editing {
                    titleText = e.title
                    content = e.description
                    selectedIcon = e.icon
                }
            }
            .sheet(isPresented: $showSymbolPicker) {
                SymbolPickerSheet(selection: $selectedIcon)
            }
            .alert("Delete this card?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { Task { await deleteCard() } }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes the card.")
            }
        }
    }

    @ViewBuilder
    private func formCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        content()
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.subheadline).fontWeight(.medium).foregroundColor(.primary)
    }

    private func save() async {
        isSaving = true
        let t = titleText.trimmingCharacters(in: .whitespaces)
        let c = content.trimmingCharacters(in: .whitespaces)
        let ok: Bool
        if let editing {
            ok = await detail.updateCareItem(id: editing.id, category: category, title: t, content: c, icon: selectedIcon)
        } else {
            ok = await detail.addCareItem(category: category, title: t, content: c, icon: selectedIcon)
        }
        isSaving = false
        if ok { dismiss() }
    }

    private func deleteCard() async {
        guard let editing else { return }
        isDeleting = true
        let ok = await detail.deleteCareItem(id: editing.id, category: category)
        isDeleting = false
        if ok { dismiss() }
    }
}

#Preview {
    CareItemSheet(detail: PetDetailStore(pet: .sample), category: "care")
}
