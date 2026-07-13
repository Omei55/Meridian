//
//  MessagingState.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 28/06/26.
//

import Foundation
import Observation
import FirebaseFirestore

@Observable
class MessagingState {

    static let shared = MessagingState()

    var totalUnreadCount = 0

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {}

    func startListening(userId: String) {
        // Listen to all conversations where this user is a participant
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("MessagingState error: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var total = 0
                for doc in documents {
                    let data = doc.data()
                    if let unreadMap = data["unreadCount"] as? [String: Any] {
                        // Handle both Int and Int64 from Firestore
                        if let count = unreadMap[userId] as? Int {
                            total += count
                        } else if let count = unreadMap[userId] as? Int64 {
                            total += Int(count)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.totalUnreadCount = total
                }
            }
    }

    func stopListening() {
        listener?.remove()
    }
    
}
