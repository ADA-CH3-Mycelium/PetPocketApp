//
//  ClarifySheetView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

// MARK: - Mock Data
private struct MockMessage: Identifiable {
    let id = UUID()
    let senderLabel: String
    let time: String
    let text: String
    let isMe: Bool
    let avatarColor: Color
}

private let mockMessages: [MockMessage] = [
    MockMessage(
        senderLabel: "SARAH (SITTER)",
        time: "14:02",
        text: "What kind of Kibble should I give to Cooper?",
        isMe: false,
        avatarColor: Color(hex: "8FAF9F")
    ),
    MockMessage(
        senderLabel: "ALEX (OWNER)",
        time: "14:05",
        text: "Eum dunno, anything fine please!",
        isMe: true,
        avatarColor: Color(hex: "5C7A6E")
    )
]

// MARK: - Main Sheet
struct ClarifySheetView: View {
    let mealName: String
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.ppForestGreen.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.ppForestGreen)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Clarify: \(mealName) Routine")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Active Chat with Sarah")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(mockMessages) { message in
                        ChatBubbleView(message: message)
                    }

                    AttachmentSuggestionCard()
                }
                .padding(16)
            }

            Divider()

            VStack(spacing: 12) {
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
                            .background(Color.ppForestGreen)
                            .clipShape(Circle())
                    }
                }


                Button {} label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark as Resolved")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.ppForestGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Chat Bubble
private struct ChatBubbleView: View {
    let message: MockMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isMe {
                Circle()
                    .fill(message.avatarColor)
                    .frame(width: 32, height: 32)
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
                        message.isMe
                            ? Color.ppForestGreen
                            : Color(.systemGray6)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .frame(maxWidth: 260, alignment: message.isMe ? .trailing : .leading)

            if message.isMe {

                Circle()
                    .fill(message.avatarColor)
                    .frame(width: 32, height: 32)
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

