//
//  ClarifySheetView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

private let mockMessages: [MessageModel] = [
    MessageModel(
        senderLabel: "SARAH (SITTER)",
        time: "14:02",
        text: "What kind of Kibble should I give to Cooper?",
        isMe: false,
        avatarImage: Image("SarahPic")
    ),
    MessageModel(
        senderLabel: "ALEX (OWNER)",
        time: "14:05",
        text: "Eum dunno, anything fine please!",
        isMe: true,
        avatarImage: Image("AlexProfilePicture")
    )
]

private let pastChats: [PastChat] = [
    PastChat(title: "Morning Walk Routine",    time: "Yesterday, 09:14"),
    PastChat(title: "Dinner Meal Routine",     time: "Mon, 19:30"),
    PastChat(title: "Vet Visit Instructions",  time: "Sun, 11:05"),
    PastChat(title: "Playtime Schedule",       time: "Sat, 15:22"),
    PastChat(title: "Medication Reminder",     time: "Fri, 08:00"),
]

// MARK: - Main View

struct ClarifySheetView: View {
//    let mealName: String
//      for this use local cache
    /// Pass `true` when this view is pushed onto a NavigationStack
    /// so the back button appears alongside the hamburger.
    var isInNavigationStack: Bool = false

    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var isSidebarOpen = false

    var body: some View {
        ZStack(alignment: .leading) {

            // ── Main chat panel ──────────────────────────────────────
            VStack(spacing: 0) {

                // Top bar
                HStack(alignment: .center, spacing: 10) {

                    // Left side: optional Back + Hamburger
                    HStack(spacing: 4) {
                        if isInNavigationStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.primaryG)
                            }
                        }

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isSidebarOpen.toggle()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.primaryG)
                                        .frame(width: 20, height: 2.5)
                                }
                            }
                            .frame(width: 36, height: 36)
                            .background(Color.primaryG.opacity(0.12))
                            .clipShape(Circle())
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clarify: Morning Routine")
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text("Active Chat with Sarah")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Right: Mark as Resolved
                    Button {
                        dismiss()
                    } label: {
                            Image(systemName: "checkmark")
                            .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.primaryG)
                        .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider()

                // Messages
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(mockMessages) { message in
                            ChatBubbleView(message: message)
                        }
//                        AttachmentSuggestionCard()
                    }
                    .padding(16)
                }

                Divider()

                // Input bar
                HStack(spacing: 12) {
                    Button {} label: {
                        Image(systemName: "paperclip")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }

                    TextField("Type a message...", text: $messageText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())

                    Button {} label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.primaryG)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            // Dim + close sidebar on tap
            .overlay {
                if isSidebarOpen {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isSidebarOpen = false
                            }
                        }
                }
            }

            // ── Sidebar panel ────────────────────────────────────────
            if isSidebarOpen {
                SidebarView(pastChats: pastChats) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isSidebarOpen = false
                    }
                }
                .frame(width: 280)
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
    }
}

// MARK: - Sidebar

private struct SidebarView: View {
    let pastChats: [PastChat]
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Sidebar header
            HStack {
                Text("Past Chats")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(7)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(pastChats) { chat in
                        Button {} label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(chat.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(chat.time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(.systemGray3))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }

                        Divider()
                            .padding(.leading, 64)
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.12), radius: 16, x: 4, y: 0)
    }
}

// MARK: - Chat Bubble

private struct ChatBubbleView: View {
    let message: MessageModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isMe {
                message.avatarImage
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Spacer()
            }

            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(message.senderLabel)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isMe ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isMe ? Color.primaryG : Color(.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .frame(maxWidth: 260, alignment: message.isMe ? .trailing : .leading)

            if message.isMe {
                message.avatarImage
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Spacer()
            }
        }
    }
}

// MARK: - Attachment Suggestion Card

private struct AttachmentSuggestionCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 18))
                .foregroundColor(.secondary)

            Text("Tap to attach a photo of the bowl setup")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .foregroundColor(Color(.systemGray4))
        )
    }
}

// MARK: - Preview

#Preview("Sheet (no nav stack)") {
    ClarifySheetView(isInNavigationStack: false)
}
//
//#Preview("Inside NavigationStack") {
//    NavigationStack {
//        ClarifySheetView(isInNavigationStack: true)
//    }
//}
