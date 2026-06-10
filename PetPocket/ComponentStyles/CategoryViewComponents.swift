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
        ZStack(alignment: .leading) {
            Color.accentColor.opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 6) {
                //HEADER
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("DIETARY RESTRICTIONS")
                        .font(.subheadline)
                        .bold()
                }.foregroundColor(Color.accent.opacity(0.35))
                
                Text("No allergies recorded.")
                    .opacity(0.25)
                Text("No restricted items recorded.")
                    .opacity(0.25)
            }.padding(20)
        }
        
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(/*.regular.tint(Color.accent.opacity(0.25)),*/ in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color.accent.opacity(0.2),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
        )
        .opacity(0.7)
    }
}

// MARK: - Add Card Button
// Dashed + button at the bottom of a section in edit mode.

struct AddCardButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline)
        }
        .buttonStyle(.glassProminent)
        .frame(width: 36, height: 36)
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
            }
            .buttonStyle(.plain)
        } else {
            RoutineCard(item: item, isEmergency: false)
        }
    }
}

// MARK: - Edit Hint Banner
// Shown below the header while in edit mode.

struct EditHintBanner: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap.fill")
            Text("Press a card to edit")
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.primaryG)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        //.background(Color.primaryG.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
