//
//  MessagesViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 28/06/26.
//

import Foundation
import Observation
import FirebaseFirestore

struct Conversation: Codable, Identifiable {

    let id: String
    let participantOne: String
    let participantTwo: String
    let courseId: String?
    let assignmentId: String?
    let lastMessage: String?
    let lastMessageTime: String?
    let createdAt: String

    let otherUserId: String
    let otherUserName: String
    let otherUserEmail: String
    let otherUserRole: String

    var otherUserInitial: String {
        String(otherUserName.prefix(1)).uppercased()
    }

    var lastMessageTimeFormatted: String {
        guard let timeString = lastMessageTime else {
            return ""
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let date = formatter.date(from: timeString) else {
            return ""
        }

        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated

        return relativeFormatter.localizedString(
            for: date,
            relativeTo: Date()
        )
    }
}

@Observable
class MessagesViewModel {

    var conversations: [Conversation] = []

    var isLoading = false
    var errorMessage: String?

    func fetchConversations() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let fetched: [Conversation] =
                try await APIClient.shared.request(
                    endpoint: "/conversations",
                    method: "GET"
                )

            conversations = fetched

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func getOrCreateConversation(
        withUserId: String,
        courseId: String? = nil,
        assignmentId: String? = nil
    ) async -> String? {

        do {
            var body: [String: Any] = [
                "participantTwoId": withUserId
            ]

            if let courseId {
                body["courseId"] = courseId
            }

            if let assignmentId {
                body["assignmentId"] = assignmentId
            }

            let conversation: Conversation =
                try await APIClient.shared.request(
                    endpoint: "/conversations",
                    method: "POST",
                    body: body
                )

            return conversation.id

        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    // Shared messaging state
    // Tracks total unread count across all conversations
    // Used by tab views to show badge
    @Observable class MessagingState {
        static let shared = MessagingState()
        var totalUnreadCount = 0
        private let db = Firestore.firestore()
        private var listener: ListenerRegistration?
        
        private init() {}
        
        func startListening(userId: String) {
            listener = db.collection("conversations")
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let documents = snapshot?.documents else { return }
                    var total = 0
                    for doc in documents {
                        let data = doc.data()
                        if let unreadMap = data["unreadCount"] as? [String: Any] {
                            if let count = unreadMap[userId] as? Int {
                                total += count
                            }
                        }
                    }
                    self?.totalUnreadCount = total
                }
        }
        
        func stopListening() {
            listener?.remove()
        }
    }
}

