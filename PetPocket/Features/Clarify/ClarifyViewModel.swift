//
//  ClarifyViewModel.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 03/06/26.
//

import Foundation
import SwiftUI
import Auth
import Realtime

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
    var profileCache: [UUID: Profile] = [:]
    private var messageChannel: RealtimeChannelV2?
    private var threadChannel: RealtimeChannelV2?
    private var threadsListChannel: RealtimeChannelV2?
    
    init(pet: PetRow? = nil, category: ClarifyCategory? = nil) {
        self.pet = pet
        self.category = category
        
    }
    
    init(pet: PetRow, thread: ClarifyThread) {
        self.pet = pet
        self.category = nil
        self.currentThread = thread
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
    
    @MainActor
    func loadThreads() async {
        guard let pet = pet else {
            errorMessage = "No pet context"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let category = category {
                // Category-specific mode
                openThreadsInPet = try await ClarifyRepository.shared.fetchThreads(
                    petId: pet.id,
                    category: category
                )
            } else {
                // Inbox mode (cross-category, unresolved only)
                openThreadsInPet = try await ClarifyRepository.shared.fetchInboxThreads(petId: pet.id)
            }
        } catch {
            errorMessage = "Failed to load threads: \(error.localizedDescription)"
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
    
    @MainActor
    func sendMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let thread = currentThread, !trimmed.isEmpty else { return }
        
        do {
            let newMessage = try await ClarifyRepository.shared.sendMessage(
                threadId: thread.id,
                message: trimmed
            )
            messages.append(newMessage)
            await loadProfiles(forSenderIds: [newMessage.senderId])
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func markAsResolved() async {
        guard let thread = currentThread else { return }
        
        do {
            try await ClarifyRepository.shared.markAsResolved(threadId: thread.id)
            // Remove from inbox list (since resolved threads are filtered out)
            openThreadsInPet.removeAll { $0.id == thread.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    @discardableResult
    func loadThread(routineTitle: String) async -> Bool {
        if let existing = openThreadsInPet.first(where: { $0.title == routineTitle }) {
            currentThread = existing
            await loadMessages(threadId: existing.id)
            await subscribeToThreadUpdates(threadId: existing.id)
            return true
        }
        currentThread = nil
        messages = []
        return false
    }
    
    @MainActor
    func loadMessages(threadId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        // Subscribe FIRST so events during fetch get captured
        await subscribeToMessages(threadId: threadId)
        
        do {
            let fetched = try await ClarifyRepository.shared.fetchMessages(threadId: threadId)
            
            // Merge: fetched + any realtime-arrived during fetch (dedup by id)
            let fetchedIds = Set(fetched.map { $0.id })
            let realtimeOnly = messages.filter { !fetchedIds.contains($0.id) }
            messages = (fetched + realtimeOnly).sorted { $0.createdAt < $1.createdAt }
            
            let senderIds = Array(Set(messages.map { $0.senderId }))
            await loadProfiles(forSenderIds: senderIds)
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func selectThread(_ thread: ClarifyThread) async {
        currentThread = thread
        await loadMessages(threadId: thread.id)
        await subscribeToThreadUpdates(threadId: thread.id)
    }
    
    @MainActor
    func startThread(title: String) async {
        guard let pet = pet else {
            errorMessage = "No pet context"
            return
        }
        
        let category = self.category ?? .food
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newThread = try await ClarifyRepository.shared.startThread(
                petId: pet.id,
                category: category,
                title: title
            )
            currentThread = newThread
            openThreadsInPet.append(newThread)
            messages = []
        } catch {
            errorMessage = "Failed to start thread: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Profile Cache

    @MainActor
    func loadProfiles(forSenderIds ids: [UUID]) async {
        let uncachedIds = ids.filter { profileCache[$0] == nil }
        guard !uncachedIds.isEmpty else { return }
        
        for id in uncachedIds {
            if let profile = try? await ClarifyRepository.shared.fetchProfile(userId: id) {
                profileCache[id] = profile
            }
        }
    }

    func displayName(for senderId: UUID) -> String {
        profileCache[senderId]?.name ?? "Unknown"
    }

    func roleLabel(for senderId: UUID) -> String {
        guard let pet = pet else { return "" }
        return senderId == pet.ownerId ? "OWNER" : "SITTER"
    }

    func senderLabel(for senderId: UUID) -> String {
        let name = displayName(for: senderId).uppercased()
        let role = roleLabel(for: senderId)
        return "\(name) (\(role))"
    }

    @MainActor
    func subscribeToMessages(threadId: UUID) async {
        await unsubscribeMessages()
        
        messageChannel = await ClarifyRepository.shared.subscribeToMessages(
            threadId: threadId,
            onInsert: { [weak self] message in
                Task { @MainActor in
                    guard let self else { return }
                    // Dedup: skip if message already in list (sent locally)
                    guard !self.messages.contains(where: { $0.id == message.id }) else { return }
                    self.messages.append(message)
                    await self.loadProfiles(forSenderIds: [message.senderId])
                }
            }
        )
    }

    @MainActor
    func unsubscribeMessages() async {
        if let channel = messageChannel {
            await ClarifyRepository.shared.unsubscribe(channel)
            messageChannel = nil
        }
    }
    
    @MainActor
    func subscribeToThreadUpdates(threadId: UUID) async {
        await unsubscribeThread()
        
        threadChannel = await ClarifyRepository.shared.subscribeToThreadUpdates(
            threadId: threadId,
            onUpdate: { [weak self] isResolved in
                Task { @MainActor in
                    guard let self else { return }
                    guard var thread = self.currentThread, thread.id == threadId else { return }
                    thread.isResolved = isResolved
                    self.currentThread = thread
                    
                    // If resolved, remove from open threads
                    if isResolved {
                        self.openThreadsInPet.removeAll { $0.id == threadId }
                    }
                }
            }
        )
    }

    @MainActor
    func unsubscribeThread() async {
        if let channel = threadChannel {
            await ClarifyRepository.shared.unsubscribe(channel)
            threadChannel = nil
        }
    }
    
    @MainActor
    func subscribeToThreadsForPet() async {
        guard let pet = pet else { return }
        await unsubscribeThreadsList()
        
        threadsListChannel = await ClarifyRepository.shared.subscribeToThreadsForPet(
            petId: pet.id,
            onInsert: { [weak self] thread in
                Task { @MainActor in
                    guard let self else { return }
                    // Dedup: skip if thread already in list
                    guard !self.openThreadsInPet.contains(where: { $0.id == thread.id }) else { return }
                    // Only show unresolved threads in inbox
                    guard !thread.isResolved else { return }
                    self.openThreadsInPet.append(thread)
                    // Resort by updatedAt desc (consistent with fetchInboxThreads order)
                    self.openThreadsInPet.sort { $0.updatedAt > $1.updatedAt }
                }
            }
        )
    }
    
    @MainActor
    func resubscribeAll() async {
        // Re-fetch threads list (catch any created during background)
        await loadThreads()
        
        // Re-subscribe to pet-level threads list (Milestone C)
        await subscribeToThreadsForPet()
        
        // Re-fetch + re-subscribe messages + thread updates for current thread
        if let thread = currentThread {
            await loadMessages(threadId: thread.id)
            await subscribeToThreadUpdates(threadId: thread.id)
        }
    }

    @MainActor
    func unsubscribeAllChannels() async {
        await unsubscribeMessages()
        await unsubscribeThread()
        await unsubscribeThreadsList()
    }

    @MainActor
    func unsubscribeThreadsList() async {
        if let channel = threadsListChannel {
            await ClarifyRepository.shared.unsubscribe(channel)
            threadsListChannel = nil
        }
    }
}
