//
//  ChatViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 28/06/26.
//

import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth

struct Message: Identifiable {

    let id: String
    let senderId: String
    let text: String
    let timestamp: Date
    let read: Bool

    func isFromCurrentUser(userId: String) -> Bool {
        senderId == userId
    }
}

@Observable
class ChatViewModel {
    
    var messages: [Message] = []
    
    var isOtherUserTyping = false
    
    var isLoading = false
    var errorMessage: String?
    
    var messageText = ""
    
    private let db = Firestore.firestore()
    
    private var messagesListener: ListenerRegistration?
    private var typingListener: ListenerRegistration?
    
    var conversationId: String
    var currentUserId: String
    var otherUserId: String
    
    init(
        conversationId: String,
        currentUserId: String,
        otherUserId: String
    ) {
        self.conversationId = conversationId
        self.currentUserId = currentUserId
        self.otherUserId = otherUserId
    }
    
    func startListening() {
        isLoading = true
        Task {
            await resetUnreadCount()
            // Make sure conversation doc exists in Firestore
            await ensureFirestoreConversation()
        }
        messagesListener = db
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                
                isLoading = false
                
                if let error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                messages = documents.compactMap { document in
                    let data = document.data()
                    
                    guard
                        let senderId = data["senderId"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = (
                            data["timestamp"] as? Timestamp
                        )?.dateValue()
                    else {
                        return nil
                    }
                    
                    return Message(
                        id: document.documentID,
                        senderId: senderId,
                        text: text,
                        timestamp: timestamp,
                        read: data["read"] as? Bool ?? false
                    )
                }
                
                Task {
                    await self.markMessagesAsRead()
                }
            }
        
        startTypingListener()
    }
    
    func stopListening() {
        messagesListener?.remove()
        typingListener?.remove()
        
        setTypingStatus(false)
    }
    
    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        
        messageText = ""
        
        do {
            // Check Firebase auth state before writing
            // If not authenticated the write will fail silently
            guard let firebaseUser = FirebaseAuth.Auth.auth().currentUser else {
                print("❌ No Firebase user — signing in anonymously first")
                try await FirebaseAuth.Auth.auth().signInAnonymously()
                print("✅ Firebase anonymous sign in successful")
                return
            }
            
            print("✅ Firebase user: \(firebaseUser.uid)")
            print("📝 Writing to conversation: \(conversationId)")
            
            try await db
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .addDocument(data: [
                    "senderId": currentUserId,
                    "text": text,
                    "timestamp": Timestamp(date: Date()),
                    "read": false
                ])
            
            print("✅ Message written to Firestore")
            await incrementUnreadCount()
            
            
            let _: [String: Bool] = try await APIClient.shared.request(
                endpoint: "/conversations/\(conversationId)/last-message",
                method: "PATCH",
                body: ["lastMessage": text]
            )
            
        } catch {
            print("❌ Send message error: \(error)")
            errorMessage = error.localizedDescription
            messageText = text
        }
    }
    func setTypingStatus(_ isTyping: Bool) {
        db
            .collection("conversations")
            .document(conversationId)
            .collection("typing")
            .document(currentUserId)
            .setData([
                "isTyping": isTyping
            ])
    }
    
    private func startTypingListener() {
        typingListener = db
            .collection("conversations")
            .document(conversationId)
            .collection("typing")
            .document(otherUserId)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.isOtherUserTyping =
                snapshot?.data()?["isTyping"] as? Bool ?? false
            }
    }
    
    func markMessagesAsRead() async {
        let unreadMessages = messages.filter {
            !$0.read &&
            $0.senderId != currentUserId
        }
        
        for message in unreadMessages {
            try? await db
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(message.id)
                .updateData([
                    "read": true
                ])
        }
    }
    // Update unread count for the other user
    // Called when a message is sent
    // Increments their unread count in Firestore
    func incrementUnreadCount() async {
        do {
            try await db
                .collection("conversations")
                .document(conversationId)
                .updateData([
                    // Use FieldValue.increment to safely increment
                    // even if multiple messages arrive simultaneously
                    "unreadCount.\(otherUserId)": FieldValue.increment(Int64(1))
                ])
        } catch {
            print("Failed to update unread count: \(error)")
        }
    }
    
    // Reset unread count for current user
    // Called when user opens the chat
    func resetUnreadCount() async {
        do {
            try await db
                .collection("conversations")
                .document(conversationId)
                .updateData([
                    "unreadCount.\(currentUserId)": 0
                ])
        } catch {
            print("Failed to reset unread count: \(error)")
        }
    }
    func ensureFirestoreConversation() async {
        do {
            try await db
                .collection("conversations")
                .document(conversationId)
                .setData([
                    "participants": [currentUserId, otherUserId],
                    "unreadCount": [
                        currentUserId: 0,
                        otherUserId: 0
                    ]
                ], merge: true)
                // merge: true means don't overwrite existing data
                // only add fields that don't exist yet
        } catch {
            print("Failed to ensure Firestore conversation: \(error)")
        }
    }
}
