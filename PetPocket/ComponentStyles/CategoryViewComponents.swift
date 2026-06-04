//
//  CategoryViewComponents.swift
//  PetPocket
//
//  Shared UI primitives used across FoodView, WasteView, and CareView.
//

import SwiftUI

// MARK: - Ghost Placeholder Card
// Looks exactly like a RoutineCard (same glass + layout) but with
// redacted/dimmed content to show the shape of what will be there.

struct GhostRoutineCard: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let titlePlaceholder: String
    let descriptionPlaceholder: String

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                // Header row — same as RoutineCard
                HStack {
                    Image(systemName: icon)
                        .font(.caption)
                    Text(titlePlaceholder)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color.primaryG.opacity(0.35))

                // Body text
                Text(descriptionPlaceholder)
                    .font(.body)
                    .foregroundColor(Color.primary.opacity(0.25))
            }

            Spacer()

            // Right column — ghost clarify button shape
            VStack(alignment: .trailing, spacing: 7) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryG.opacity(0.08))
                    .frame(width: 36, height: 28)
            }
        }
        .padding(20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .glassEffect(
            .regular.tint(colorScheme == .dark ? .clear : .white),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color.primaryG.opacity(0.2),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
        )
        .opacity(0.7)
    }
}

// MARK: - Ghost Alert Card
// Same idea for the alert/restriction section.

struct GhostAlertCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("NO DIETARY RESTRICTIONS")
                    .font(.caption)
                    .bold()
            }
            .foregroundColor(Color.alertRed.opacity(0.3))

            Text("No allergies or restricted items recorded.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(Color.alertRed.opacity(0.04)), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color.alertRed.opacity(0.2),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
        )
    }
}

// MARK: - Add Card Button
// Dashed + button at the bottom of a section in edit mode.

struct AddCardButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("Add")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color.primaryG)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.primaryG.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        Color.primaryG.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Edit Menu Button

struct EditMenuButton: View {
    @Binding var isEditing: Bool

    var body: some View {
        Menu {
            Button(action: { withAnimation { isEditing.toggle() } }) {
                Label(
                    isEditing ? "Done Editing" : "Edit information",
                    systemImage: isEditing ? "checkmark" : "pencil"
                )
            }
        } label: {
            Image(systemName: "ellipsis")
                .imageScale(.large)
                .rotationEffect(.degrees(90))
                .foregroundColor(Color.primaryG)
        }
    }
}

// MARK: - Tappable Routine Card
// In normal mode: renders RoutineCard as-is.
// In edit mode: wraps it in a Button that opens the edit sheet.

struct TappableRoutineCard: View {
    let item: RoutineCardItem
    let isEditing: Bool
    let onEditTap: (RoutineCardItem) -> Void

    var body: some View {
        if isEditing {
            Button {
                onEditTap(item)
            } label: {
                RoutineCard(item: item, isEmergency: false)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white, Color.primaryG)
                            .padding(6)
                    }
            }
            .buttonStyle(.plain)
        } else {
            RoutineCard(item: item, isEmergency: false)
        }
    }
}
