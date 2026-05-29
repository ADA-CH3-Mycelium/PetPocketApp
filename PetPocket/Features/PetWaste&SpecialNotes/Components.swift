//
//  Components.swift
//  Pet Waste and Special Notes Feature
//

import SwiftUI

// MARK: - Pet Header (Get to Know Me)

struct PetHeaderView: View {
    let pet: Pet
    private let photoSize: CGFloat = 140

    var body: some View {
        VStack(spacing: 14) {
            Group {
                if UIImage(named: pet.imageName) != nil {
                    Image(pet.imageName).resizable().scaledToFill()
                } else {
                    // Fallback kalau asset belum di-drag ke project
                    ZStack {
                        Color.brandTertiary
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
            .frame(width: photoSize, height: photoSize)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            Text(pet.name)
                .font(.title.weight(.bold))
                .foregroundStyle(Color.brandNeutral)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                infoCard("AGE", pet.age)
                infoCard("GENDER", pet.gender)
                infoCard("BREED", pet.breed)
                infoCard("SPECIES", pet.species)
            }
        }
    }

    private func infoCard(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.brandNeutral)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(white: 0.90), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Category Tabs (sticky bar)

struct CategoryTabsView: View {
    @Binding var selected: PetCategory
    var isEditing: Bool
    var onEditTap: () -> Void
    var onDoneTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pet's Informations")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandNeutral)
                Spacer()
                rightControl
            }

            HStack(spacing: 10) {
                ForEach(PetCategory.allCases) { cat in
                    CategoryPill(category: cat, isSelected: cat == selected)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selected = cat
                            }
                        }
                }
            }

            Rectangle().fill(Color.black).frame(height: 1)

            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                Text("Swipe right on a card to Clarify & Ask")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.white)
    }

    @ViewBuilder
    private var rightControl: some View {
        if isEditing {
            Button(action: onDoneTap) {
                Text("Done")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Color.brandPrimary, in: Capsule())
            }
        } else {
            Menu {
                Button { } label: { Label("Manage access", systemImage: "person.crop.circle") }
                Button(action: onEditTap) { Label("Edit information", systemImage: "pencil") }
                Button { } label: { Label("Generate new code", systemImage: "list.bullet.clipboard") }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.brandNeutral)
                    .rotationEffect(.degrees(90))
                    .frame(width: 32, height: 32)
            }
            .glassEffect(.regular.interactive(), in: .circle)
        }
    }
}

// Pill: icon di card + label di bawah.
// Emergency punya skema warna merah, lainnya hijau saat selected.
private struct CategoryPill: View {
    let category: PetCategory
    let isSelected: Bool

    private var isEmergency: Bool { category == .emergency }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBg)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
                Image(systemName: category.icon)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(iconColor)
            }
            .frame(height: 48)

            Text(category.rawValue)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var cardBg: Color {
        if isEmergency { return isSelected ? .red : .red.opacity(0.10) }
        return isSelected ? .brandPrimary : .white
    }
    private var iconColor: Color {
        if isEmergency { return isSelected ? .white : .red }
        return isSelected ? .white : .brandNeutral
    }
    private var labelColor: Color { isEmergency ? .red : .brandNeutral }
    private var borderColor: Color {
        if isSelected { return .clear }
        return isEmergency ? .red.opacity(0.3) : .black.opacity(0.12)
    }
}

// MARK: - Info Card (normal & alert)

struct InfoCardView: View {
    @Binding var card: InfoCard
    var isEditing: Bool

    private var isAlert: Bool { card.style == .alert }
    private var primaryFG: Color { isAlert ? .white : card.accentColor }
    private var bodyFG: Color    { isAlert ? .white : .brandNeutral }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: card.icon)
                .font(.headline)
                .foregroundStyle(primaryFG)
                .frame(width: 32, height: 32)
                .background(
                    isAlert ? .white.opacity(0.25) : card.accentColor.opacity(0.18),
                    in: RoundedRectangle(cornerRadius: 8)
                )

            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Title", text: $card.title)
                        .textInputAutocapitalization(.characters)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(primaryFG).tint(primaryFG)
                } else {
                    Text(card.title.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(primaryFG)
                }

                if isEditing {
                    TextField("Content", text: $card.content, axis: .vertical)
                        .font(.footnote)
                        .foregroundStyle(bodyFG).tint(bodyFG)
                        .lineLimit(1...6)
                } else {
                    Text(card.content)
                        .font(.footnote)
                        .foregroundStyle(bodyFG)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isEditing {
                Image(systemName: "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isAlert ? .white.opacity(0.9) : .secondary)
                    .padding(4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isAlert ? Color.brandSecondary : .white,
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isAlert ? .clear : card.accentColor.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Quote Card

struct QuoteCardView: View {
    @Binding var quote: QuoteItem
    var isEditing: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "quote.bubble.fill")
                .font(.subheadline)
                .foregroundStyle(Color.brandPrimary)
                .frame(width: 28, height: 28)
                .background(Color.brandPrimary.opacity(0.15), in: Circle())

            if isEditing {
                TextField("Note", text: $quote.text, axis: .vertical)
                    .font(.footnote)
                    .foregroundStyle(Color.brandNeutral)
                    .lineLimit(1...6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(quote.text)
                    .font(.footnote)
                    .foregroundStyle(Color.brandNeutral)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isEditing {
                Image(systemName: "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(4)
            }
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Section Title

struct SectionTitleView: View {
    @Binding var text: String
    var isEditing: Bool

    var body: some View {
        Group {
            if isEditing {
                TextField("Section title", text: $text)
            } else {
                Text(text)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color.brandNeutral)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }
}

// MARK: - Empty State

struct EmptyCategoryView: View {
    let category: PetCategory
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("\(category.rawValue) content coming soon.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Swipeable Card
// Swipe kiri → kanan untuk munculin tombol "Clarify & Ask".

struct SwipeableCard<Content: View>: View {
    let onClarify: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var offsetX: CGFloat = 0
    @GestureState private var dragX: CGFloat = 0

    private let revealWidth: CGFloat = 96
    private let threshold:   CGFloat = 60

    var body: some View {
        ZStack(alignment: .leading) {
            Button {
                onClarify()
                withAnimation(.spring()) { offsetX = 0 }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "questionmark.circle.fill").font(.title3)
                    Text("Clarify & Ask")
                        .font(.caption2.weight(.semibold))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
                .frame(width: revealWidth)
                .frame(maxHeight: .infinity)
                .background(Color.brandSecondary, in: RoundedRectangle(cornerRadius: 14))
            }
            .opacity(currentOffset > 8 ? 1 : 0)

            content()
                .offset(x: currentOffset)
                .gesture(
                    DragGesture()
                        .updating($dragX) { value, state, _ in
                            state = max(0, value.translation.width)  // hanya swipe kanan
                        }
                        .onEnded { value in
                            let total = offsetX + max(0, value.translation.width)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                offsetX = total > threshold ? revealWidth + 8 : 0
                            }
                        }
                )
        }
        .onTapGesture {
            if offsetX != 0 {
                withAnimation(.spring()) { offsetX = 0 }
            }
        }
    }

    private var currentOffset: CGFloat {
        min(revealWidth + 8, offsetX + dragX)
    }
}

// MARK: - Clarify & Ask Sheet (half-sheet chat)

struct ClarifyChatSheet: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var messages: [ChatMessage] = ChatMessage.dummy

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageList
            inputBar
            markResolvedButton
        }
        .presentationBackground(.ultraThinMaterial)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.title3)
                .foregroundStyle(Color.brandPrimary)
                .padding(8)
                .background(Color.brandPrimary.opacity(0.18), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Clarify: \(title)").font(.headline)
                Text("Active Chat with Sarah")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.gray.opacity(0.15), in: Circle())
            }
        }
        .padding()
    }

    private var messageList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(messages) { ChatBubble(message: $0) }
                HStack {
                    Image(systemName: "photo")
                    Text("Tap to attach a photo of the bowl setup").font(.footnote)
                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "paperclip").foregroundStyle(.secondary)
            TextField("Type a message...", text: $draft).textFieldStyle(.plain)
            Button { sendMessage() } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Color.brandPrimary, in: Circle())
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var markResolvedButton: some View {
        Button { dismiss() } label: {
            Label("Mark as Resolved", systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.brandPrimary, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func sendMessage() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(
            sender: "ALEX", role: "(OWNER)", time: "now",
            text: trimmed, isMine: true
        ))
        draft = ""
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isMine { avatar } else { Spacer(minLength: 40) }

            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("\(message.sender) \(message.role)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(message.time).font(.caption2).foregroundStyle(.secondary)
                }
                Text(message.text)
                    .font(.footnote)
                    .padding(10)
                    .background(
                        message.isMine ? Color.brandPrimary.opacity(0.18)
                                       : Color.gray.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .foregroundStyle(Color.brandNeutral)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(message.isMine ? Color.brandPrimary : .clear, lineWidth: 1)
                    )
            }

            if message.isMine { avatar } else { Spacer(minLength: 40) }
        }
    }

    private var avatar: some View {
        Circle()
            .fill(Color.brandTertiary)
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            )
    }
}
