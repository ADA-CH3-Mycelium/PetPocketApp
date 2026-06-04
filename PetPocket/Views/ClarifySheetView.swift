//
//  ClarifySheetView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

// MARK: - Main View

struct ClarifySheetView: View {
    let pet: PetRow
    let category: ClarifyCategory?
    var isInNavigationStack: Bool = false
    var routineTitle: String? = nil
    var initialThread: ClarifyThread? = nil

    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var isSidebarOpen = false
    @State private var initialLoadComplete = false
    @State private var viewModel: ClarifyViewModel

    init(
        pet: PetRow,
        category: ClarifyCategory? = nil,
        isInNavigationStack: Bool = false,
        routineTitle: String? = nil,
        initialThread: ClarifyThread? = nil
    ) {
        self.pet = pet
        self.category = category
        self.isInNavigationStack = isInNavigationStack
        self.routineTitle = routineTitle
        self.initialThread = initialThread

        if let initialThread {
            _viewModel = State(
                initialValue: ClarifyViewModel(pet: pet, thread: initialThread)
            )
        } else {
            _viewModel = State(
                initialValue: ClarifyViewModel(pet: pet, category: category)
            )
        }
    }

    private var titleText: String {
        if viewModel.isLoading {
            return "Clarify: Loading…"
        }
        if let thread = viewModel.currentThread {
            return "Clarify: \(thread.title)"
        }
        if let routineTitle = routineTitle {
            return "Clarify: \(routineTitle)"
        }
        return "Clarify"
    }

    private var subtitleText: String? {
        guard viewModel.currentThread != nil else { return nil }
        return "Active conversation"
    }

    private func messageModel(from msg: ClarifyMessage) -> MessageModel {
        let isMe = msg.senderId == viewModel.currentUser?.id
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return MessageModel(
            senderLabel: viewModel.senderLabel(for: msg.senderId),
            time: formatter.string(from: msg.createdAt),
            text: msg.message,
            isMe: isMe,
            avatarImage: Image(systemName: "person.circle.fill")
        )
    }

    var body: some View {
        ZStack(alignment: .leading) {

            // Main chat panel
            VStack(spacing: 0) {

                // Top bar
                HStack(alignment: .center, spacing: 10) {

                    if routineTitle == nil {
                        Button {
                            withAnimation(
                                .spring(response: 0.35, dampingFraction: 0.8)
                            ) {
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
                        Text(titleText)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        if let subtitle = subtitleText {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Mark as Resolved (owner-only)
                    if viewModel.canMarkAsResolved {
                        Button {
                            Task {
                                await viewModel.markAsResolved()
                                dismiss()
                            }
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
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider()

                // Messages content
                if !initialLoadComplete {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.shouldShowEmptyStateForOwner {
                    ownerEmptyState
                } else if viewModel.currentThread == nil,
                    let title = routineTitle,
                    viewModel.isCurrentUserSitter
                {
                    sitterStartButton(title: title)
                } else if viewModel.currentThread == nil
                    && viewModel.openThreadsInPet.isEmpty
                    && !viewModel.isLoading
                {
                    inboxEmptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(
                                    message: messageModel(from: message)
                                )
                            }
                        }
                        .padding(16)
                    }
                }

                Divider()

                // Input bar (only when thread exists)
                if viewModel.currentThread != nil {
                    HStack(spacing: 12) {
                        Button {
                        } label: {
                            Image(systemName: "paperclip")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        }

                        TextField("Type a message...", text: $messageText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())

                        Button {
                            let toSend = messageText
                            messageText = ""
                            Task {
                                await viewModel.sendMessage(toSend)
                            }
                        } label: {
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
            }
            // Dim overlay
            .overlay {
                if isSidebarOpen {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(
                                .spring(response: 0.35, dampingFraction: 0.8)
                            ) {
                                isSidebarOpen = false
                            }
                        }
                }
            }

            // Sidebar panel
            if isSidebarOpen {
                SidebarView(
                    threads: viewModel.openThreadsInPet,
                    onClose: {
                        withAnimation(
                            .spring(response: 0.35, dampingFraction: 0.8)
                        ) {
                            isSidebarOpen = false
                        }
                    },
                    onSelect: { thread in
                        Task {
                            await viewModel.selectThread(thread)
                        }
                        withAnimation(
                            .spring(response: 0.35, dampingFraction: 0.8)
                        ) {
                            isSidebarOpen = false
                        }
                    }
                )
                .frame(width: 280)
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
        .task {
            await viewModel.loadCurrentUser()
            await viewModel.loadThreads()

            // Determine which thread to open as default
            if let thread = initialThread {
                // From Inbox row tap (not used anymore but kept for compat)
                await viewModel.loadMessages(threadId: thread.id)
            } else if let title = routineTitle {
                // From RoutineCard with specific routine context
                await viewModel.loadThread(routineTitle: title)
            } else if let mostRecent = viewModel.openThreadsInPet.first {
                // From Dashboard toolbar → auto-load most recent (last chat)
                await viewModel.selectThread(mostRecent)
            }
            initialLoadComplete = true
        }
    }

    // MARK: - Empty states

    private var ownerEmptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No chat yet for this routine")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(
                "Wait for the sitter to start a\nconversation about this routine"
            )
            .font(.subheadline)
            .foregroundColor(.secondary.opacity(0.7))
            .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }

    private func sitterStartButton(title: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.primaryG.opacity(0.7))
            Text("No conversation yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Start a chat about \(title) with the owner")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task {
                    await viewModel.startThread(title: title)
                }
            } label: {
                Label("Start Conversation", systemImage: "plus.bubble.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.primaryG)
                    .clipShape(Capsule())
            }
            .disabled(viewModel.isLoading)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }

    private var inboxEmptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No active conversations")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Open a routine card to start a chat")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}

// MARK: - Sidebar

private struct SidebarView: View {
    let threads: [ClarifyThread]
    let onClose: () -> Void
    let onSelect: (ClarifyThread) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Sidebar header
            HStack {
                Text("Open Conversations")
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

            if threads.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No open conversations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(threads) { thread in
                            Button {
                                onSelect(thread)
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(thread.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Text(
                                            thread.category.rawValue.capitalized
                                        )
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
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color.primaryG.opacity(0.7))
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
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .frame(
                maxWidth: 260,
                alignment: message.isMe ? .trailing : .leading
            )

            if message.isMe {
                message.avatarImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color.primaryG.opacity(0.7))
                    .clipShape(Circle())
            } else {
                Spacer()
            }
        }
    }
}
