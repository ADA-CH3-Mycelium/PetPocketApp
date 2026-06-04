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
