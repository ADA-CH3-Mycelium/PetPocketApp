//
//  ClarifyRepository.swift
//  PetPocket
//
//  Created by Muhammad Saffa Wardana on 04/06/26.
//

import Foundation
import Supabase

struct ClarifyRepository {
    static let shared = ClarifyRepository()
    
    private var client: SupabaseClient { supabase }
    
    
    func currentUserId() async throws -> UUID {
        try await client.auth.session.user.id
    }
    
    
    func fetchThreads(petId: UUID, category: ClarifyCategory) async throws -> [ClarifyThread] {
        try await client
            .from("clarify_threads")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .eq("category", value: category.rawValue)
            .order("updated_at", ascending: false)
            .execute()
            .value
    }
    
    func fetchInboxThreads(petId: UUID) async throws -> [ClarifyThread] {
        try await client
            .from("clarify_threads")
            .select()
            .eq("pet_id", value: petId.uuidString)
            .eq("is_resolved", value: false)
            .order("updated_at", ascending: false)
            .execute()
            .value
    }
    
    @discardableResult
    func startThread(
        petId: UUID,
        category: ClarifyCategory,
        title: String
    ) async throws -> ClarifyThread {
        let uid = try await currentUserId()
        let payload = ClarifyThreadInsert(
            petId: petId,
            category: category.rawValue,
            title: title,
            createdBy: uid
        )
        return try await client
            .from("clarify_threads")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }
    
    func markAsResolved(threadId: UUID) async throws {
        let payload = ClarifyThreadResolveUpdate(isResolved: true)
        try await client
            .from("clarify_threads")
            .update(payload)
            .eq("id", value: threadId.uuidString)
            .execute()
    }
    
    func fetchMessages(threadId: UUID) async throws -> [ClarifyMessage] {
        try await client
            .from("clarify_messages")
            .select()
            .eq("thread_id", value: threadId.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    
    @discardableResult
    func sendMessage(threadId: UUID, message: String) async throws -> ClarifyMessage {
        let uid = try await currentUserId()
        let payload = ClarifyMessageInsert(
            threadId: threadId,
            senderId: uid,
            message: message
        )
        return try await client
            .from("clarify_messages")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }
    
    func fetchProfile(userId: UUID) async throws -> Profile {
        try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
    }
    

    func subscribeToMessages(
        threadId: UUID,
        onInsert: @escaping (ClarifyMessage) -> Void
    ) async -> RealtimeChannelV2 {
        let channel = client.channel("clarify-messages-\(threadId.uuidString)")
        
        let stream = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "clarify_messages",
            filter: "thread_id=eq.\(threadId.uuidString)"
        )
        
        await channel.subscribe()
        print("[Clarify Realtime] Subscribed to messages for thread \(threadId)")
        
        Task {
            for await change in stream {
                if let message = Self.decodeMessage(from: change.record) {
                    onInsert(message)
                }
            }
        }
        
        return channel
    }
    
    func subscribeToThreadUpdates(
        threadId: UUID,
        onUpdate: @escaping (Bool) -> Void
    ) async -> RealtimeChannelV2 {
        let channel = client.channel("clarify-thread-\(threadId.uuidString)")
        
        let stream = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "clarify_threads",
            filter: "id=eq.\(threadId.uuidString)"
        )
        
        await channel.subscribe()
        print("[Clarify Realtime] Subscribed to thread updates for \(threadId)")
        
        Task {
            for await change in stream {
                print("[Clarify Realtime] Message INSERT received: \(change.record)")
                if let isResolved = Self.decodeThreadIsResolved(from: change.record) {
                    onUpdate(isResolved)
                }
            }
        }
        
        return channel
    }
    
    func subscribeToThreadsForPet(
        petId: UUID,
        onInsert: @escaping (ClarifyThread) -> Void
    ) async -> RealtimeChannelV2 {
        let channel = client.channel("clarify-threads-pet-\(petId.uuidString)")
        
        let stream = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "clarify_threads",
            filter: "pet_id=eq.\(petId.uuidString)"
        )
        
        await channel.subscribe()
        print("[Clarify Realtime] Subscribed to threads for pet \(petId)")
        
        Task {
            for await change in stream {
                if let thread = Self.decodeThread(from: change.record) {
                    onInsert(thread)
                }
            }
        }
        
        return channel
    }
    
    private static func decodeThread(from record: [String: AnyJSON]) -> ClarifyThread? {
        guard
            case .string(let idStr) = record["id"],
            let id = UUID(uuidString: idStr),
            case .string(let petIdStr) = record["pet_id"],
            let petId = UUID(uuidString: petIdStr),
            case .string(let categoryStr) = record["category"],
            let category = ClarifyCategory(rawValue: categoryStr),
            case .string(let titleStr) = record["title"],
            case .string(let createdByStr) = record["created_by"],
            let createdBy = UUID(uuidString: createdByStr),
            case .bool(let isResolved) = record["is_resolved"],
            case .string(let createdAtStr) = record["created_at"],
            case .string(let updatedAtStr) = record["updated_at"]
        else {
            print("[Clarify Realtime] Could not decode thread record: \(record)")
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let createdAt = formatter.date(from: createdAtStr) ?? Date()
        let updatedAt = formatter.date(from: updatedAtStr) ?? Date()
        
        return ClarifyThread(
            id: id,
            petId: petId,
            category: category,
            title: titleStr,
            createdBy: createdBy,
            isResolved: isResolved,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private static func decodeThreadIsResolved(from record: [String: AnyJSON]) -> Bool? {
        guard case .bool(let isResolved) = record["is_resolved"] else {
            print("[Clarify Realtime] Could not decode is_resolved from record: \(record)")
            return nil
        }
        return isResolved
    }

    func unsubscribe(_ channel: RealtimeChannelV2) async {
        await client.removeChannel(channel)
        print("[Clarify Realtime] Unsubscribed channel")
    }

    private static func decodeMessage(from record: [String: AnyJSON]) -> ClarifyMessage? {
        guard
            case .string(let idStr) = record["id"],
            let id = UUID(uuidString: idStr),
            case .string(let threadIdStr) = record["thread_id"],
            let threadId = UUID(uuidString: threadIdStr),
            case .string(let senderIdStr) = record["sender_id"],
            let senderId = UUID(uuidString: senderIdStr),
            case .string(let messageStr) = record["message"],
            case .string(let createdAtStr) = record["created_at"]
        else {
            print("[Clarify Realtime] Decode error: missing or invalid field in record: \(record)")
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var createdAt = formatter.date(from: createdAtStr)
        if createdAt == nil {
            formatter.formatOptions = [.withInternetDateTime]
            createdAt = formatter.date(from: createdAtStr)
        }
        
        return ClarifyMessage(
            id: id,
            threadId: threadId,
            senderId: senderId,
            message: messageStr,
            createdAt: createdAt ?? Date()
        )
    }
}


struct ClarifyThreadInsert: Encodable {
    let petId: UUID
    let category: String
    let title: String
    let createdBy: UUID
    
    enum CodingKeys: String, CodingKey {
        case petId = "pet_id"
        case category
        case title
        case createdBy = "created_by"
    }
}

struct ClarifyMessageInsert: Encodable {
    let threadId: UUID
    let senderId: UUID
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case threadId = "thread_id"
        case senderId = "sender_id"
        case message
    }
}

struct ClarifyThreadResolveUpdate: Encodable {
    let isResolved: Bool
    
    enum CodingKeys: String, CodingKey {
        case isResolved = "is_resolved"
    }
}
