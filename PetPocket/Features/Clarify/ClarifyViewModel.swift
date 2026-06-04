//
//  ClarifyViewModel.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 03/06/26.
//

import Foundation
import SwiftUI
import Auth

@Observable
class ClarifyViewModel {
    
    let pet: PetRow?
    let category: ClarifyCategory?
        
    var currentUser: Profile?
    var currentThread: ClarifyThread?
    var messages: [ClarifyMessage] = []
    var openThreadsInPet: [ClarifyThread] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(pet: PetRow? = nil, category: ClarifyCategory? = nil) {
        self.pet = pet
        self.category = category
        
        loadMockThreadsAndMessages()
    }
    
    @MainActor
    func loadCurrentUser() async {
        guard let userId = AuthManager.shared.session?.user.id else {
            errorMessage = "Not authenticated"
            return
        }
        do {
            currentUser = try await ClarifyRepository.shared.fetchProfile(userId: userId)
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }
    
    var isCurrentUserOwner: Bool {
        guard let user = currentUser, let pet = pet else { return false }
        return user.id == pet.ownerId
    }
    
    var isCurrentUserSitter: Bool {
        guard let user = currentUser, let pet = pet else { return false }
        return user.id != pet.ownerId
    }
    
    var canMarkAsResolved: Bool {
        guard let thread = currentThread else { return false }
        return isCurrentUserOwner && !thread.isResolved
    }
    
    var shouldShowEmptyStateForOwner: Bool {
        return isCurrentUserOwner && currentThread == nil
    }
    
    
    private func loadMockThreadsAndMessages() {
        currentThread = ClarifyThread.mockBreakfast
        messages = ClarifyMessage.mockMessages
        openThreadsInPet = [
            ClarifyThread.mockBreakfast,
            ClarifyThread.mockEveryFourHour,
            ClarifyThread.mockFearTriggers
        ]
    }
    
    func sendMessage(_ text: String) {
        guard let thread = currentThread, let user = currentUser else {
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
        guard var thread = currentThread else { return }
        thread.isResolved = true
        thread.updatedAt = Date()
        currentThread = thread
        openThreadsInPet.removeAll { $0.id == thread.id }
    }
    
    func selectThread(_ thread: ClarifyThread) {
        currentThread = thread
        messages = ClarifyMessage.mockMessages.filter { $0.threadId == thread.id }
    }
    
    @discardableResult
    func loadThread(routineTitle: String) -> Bool {
        if let existing = openThreadsInPet.first(where: { $0.title == routineTitle }) {
            currentThread = existing
            messages = ClarifyMessage.mockMessages.filter { $0.threadId == existing.id }
            return true
        }
        currentThread = nil
        messages = []
        return false
    }
}
