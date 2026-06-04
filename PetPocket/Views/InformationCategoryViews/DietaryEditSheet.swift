//
//  DietaryEditSheet.swift
//  PetPocket
//
//  Edit a pet's dietary restrictions. Mirrors the AddMealSheet (card/notes)
//  styling: white form cards, comma-separated entries for allergies and
//  restricted items — matching how AlertCardStyle renders them.
//

import SwiftUI

struct DietaryEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let detail: PetDetailStore

    @State private var allergiesText = ""
    @State private var restrictedText = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // ── Allergies ────────────────────────────────
                        formCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.alertRed)
                                    sectionLabel("Allergies")
                                }
                                Text("Foods the pet must never have. Separate with commas.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField(
                                    "e.g. Chocolate, Chicken",
                                    text: $allergiesText,
                                    axis: .vertical
                                )
                                .lineLimit(2...5)
                                .textFieldStyle(.plain)
                                .font(.body)
                            }
                        }

                        // ── Restricted ───────────────────────────────
                        formCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundColor(.alertRed)
                                    sectionLabel("Restricted")
                                }
                                Text("Limit or avoid these. Separate with commas.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField(
                                    "e.g. Grapes, Onion, Shellfish",
                                    text: $restrictedText,
                                    axis: .vertical
                                )
                                .lineLimit(2...5)
                                .textFieldStyle(.plain)
                                .font(.body)
                            }
                        }

                        if let error = detail.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        // ── Save ─────────────────────────────────────
                        Button {
                            Task { await save() }
                        } label: {
                            Group {
                                if isSaving { ProgressView().tint(.white) }
                                else { Text("Save Changes").fontWeight(.semibold) }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.primaryG)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isSaving)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Dietary Restrictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.primaryG)
                }
            }
            .onAppear {
                allergiesText  = detail.allergies.joined(separator: ", ")
                restrictedText = detail.restricted.joined(separator: ", ")
            }
        }
    }

    // MARK: - Subviews (match AddMealSheet)

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

    // MARK: - Helpers

    /// Splits a comma-separated string into trimmed, non-empty items.
    private func parse(_ text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func save() async {
        isSaving = true
        let ok = await detail.updateDietary(
            allergies: parse(allergiesText),
            restricted: parse(restrictedText)
        )
        isSaving = false
        if ok { dismiss() }
    }
}

#Preview {
    DietaryEditSheet(detail: PetDetailStore(pet: .sample))
}
