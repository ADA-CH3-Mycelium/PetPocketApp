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
    let category: String  // "waste" | "care" | "emergency"
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
        let noun =
            category == "emergency"
            ? "First Aid" : (category == "waste" ? "Routine" : "Note")
        return isEditing ? "Edit \(noun)" : "Add \(noun)"
    }
    private var canSave: Bool {
        !titleText.trimmingCharacters(in: .whitespaces).isEmpty
            && !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background).ignoresSafeArea()

                Form {
                    // ── Icon picker ──────────────────────────────
                    Section {
                        VStack {
                            Button {
                                showSymbolPicker = true
                            } label: {
                                
                                Image(systemName: selectedIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(10)
                                    .frame(width: 50, height: 60)
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .buttonBorderShape(.roundedRectangle)
                            .buttonStyle(.glassProminent)
                            .tint(Color.primaryG)
                            
                            Text("select icon")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }.listRowBackground(Color.clear)

                    // ── Name ─────────────────────────
                    Section {
                        TextField("Backyard", text: $titleText)
                    } header: {
                        Text("Title")
                            .modifier(onBoardingSectionHeaderStyle())
                    }

                    // ── Description ──────────────────────────────

                    Section {
                        TextField(
                            "Enter detailed description and instructions here.",
                            text: $content,
                            axis: .vertical
                        )
                        .lineLimit(4...8)
                        .frame(minHeight: 100, alignment: .topLeading)
                    } header: {
                        Text("Description")
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

                // error msg -----------------------------
                if let error = detail.errorMessage {
                    Text(error).font(.caption).foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

            }
            .navigationTitle(navTitle)
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
                    titleText = e.title
                    content = e.description
                    selectedIcon = e.icon
                }
            }
            .sheet(isPresented: $showSymbolPicker) {
                SymbolPickerSheet(selection: $selectedIcon)
            }
            .alert("Are you sure you want to delete this card?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    Task { await deleteCard() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the card forever.")
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
        Text(text).font(.subheadline).fontWeight(.medium).foregroundColor(
            .primary
        )
    }

    private func save() async {
        isSaving = true
        let t = titleText.trimmingCharacters(in: .whitespaces)
        let c = content.trimmingCharacters(in: .whitespaces)
        let ok: Bool
        if let editing {
            ok = await detail.updateCareItem(
                id: editing.id,
                category: category,
                title: t,
                content: c,
                icon: selectedIcon
            )
        } else {
            ok = await detail.addCareItem(
                category: category,
                title: t,
                content: c,
                icon: selectedIcon
            )
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
