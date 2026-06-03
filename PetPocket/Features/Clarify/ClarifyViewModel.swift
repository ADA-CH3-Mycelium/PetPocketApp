//
//  ClarifyViewModel.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 03/06/26.
//

import Foundation
import SwiftUI

@Observable
class ClarifyViewModel {
    var currentThread: ClarifyThread?

    var messages: [ClarifyMessage] = []

    var openThreadsInPet: [ClarifyThread] = []

    var isLoading: Bool = false

    var currentUser: Profile?

    init() {
        loadMockData()
    }

    private func loadMockData() {
        currentUser = Profile.mockSarah

        currentThread = ClarifyThread.mockBreakfast

        messages = ClarifyMessage.mockMessages

        openThreadsInPet = [
                ClarifyThread.mockBreakfast,
                ClarifyThread.mockEveryFourHour,
                ClarifyThread.mockFearTriggers
            ]
    }

    func sendMessage(_ text: String) {
        guard let thread = currentThread,
            let user = currentUser
        else {
            print("⚠️ Cannot send: no active thread or user")
            return
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = ClarifyMessage(
            id: UUID(),
            threadId: thread.id,
            senderId: user.id,
            message: trimmed,
            createdAt: Date()
        )

        messages.append(newMessage)
    }

    func markAsResolved() {
        guard var thread = currentThread else {
            print("⚠️ Cannot resolve: no active thread")
            return
        }

        thread.isResolved = true
        thread.updatedAt = Date()

        currentThread = thread

        openThreadsInPet.removeAll { $0.id == thread.id }
    }
    
    func selectThread(_ thread: ClarifyThread) {
            currentThread = thread
            messages = ClarifyMessage.mockMessages.filter { $0.threadId == thread.id }
        }

    var isCurrentUserSitter: Bool {
        guard let thread = currentThread,
            let user = currentUser
        else {
            return false
        }
        return thread.createdBy == user.id
    }

    var canMarkAsResolved: Bool {
        guard let thread = currentThread else { return false }
        return isCurrentUserSitter && !thread.isResolved
    }

    @discardableResult
    func loadThread(routineTitle: String) -> Bool {
        if let existing = openThreadsInPet.first(where: {
            $0.title == routineTitle
        }) {
            currentThread = existing
            messages = ClarifyMessage.mockMessages.filter {
                $0.threadId == existing.id
            }
            return true
        }

        currentThread = nil
        messages = []
        return false
    }

    var shouldShowEmptyStateForOwner: Bool {
        return !isCurrentUserSitter && currentThread == nil
    }
}
