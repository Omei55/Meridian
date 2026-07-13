//
//  ConversationsListView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 28/06/26.
//

import SwiftUI
import FirebaseFirestore

struct ConversationsListView: View {

    @State private var viewModel = MessagesViewModel()
    @State private var showNewConversation = false
    @State private var activeConversation: Conversation?
    @State private var navigateToChat = false
    @State private var totalUnreadCount = 0
    private let db = Firestore.firestore()
    
    @Environment(AuthManager.self)
    private var authManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    if viewModel.isLoading {

                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F1F5F9"))
                                .frame(height: 72)
                                .redacted(reason: .placeholder)
                        }

                    } else if viewModel.conversations.isEmpty {

                        VStack(spacing: 16) {
                            Image(systemName: "message")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    Color(hex: "94A3B8")
                                )

                            Text("No messages yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    Color(hex: "1E293B")
                                )

                            Text(
                                authManager.isProfessor
                                ? "Students will be able to message you directly"
                                : "Message your professors directly about assignments"
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                Color(hex: "64748B")
                            )
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)

                    } else {

                        ForEach(viewModel.conversations) {
                            conversation in

                            NavigationLink {
                                ChatView(
                                    conversation: conversation,
                                    currentUserId:
                                        authManager.currentUser?.id ?? ""
                                )
                                .environment(AuthManager.shared)

                            } label: {
                                ConversationRow(
                                    conversation: conversation
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewConversation = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Color(hex: "4F46E5"))
                    }
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.fetchConversations()
            }
            .task {
                await viewModel.fetchConversations()
            }
            .sheet(isPresented: $showNewConversation) {
                NewConversationView { conversation in
                    activeConversation = conversation
                    navigateToChat = true
                    Task {
                        await viewModel.fetchConversations()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToChat) {
                if let conversation = activeConversation {
                    ChatView(
                        conversation: conversation,
                        currentUserId: authManager.currentUser?.id ?? ""
                    )
                    .environment(AuthManager.shared)
                }
            }
        }
    }
    func listenForUnreadCounts() {
        guard let userId = authManager.currentUser?.id else { return }
        
        db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                var total = 0
                for doc in documents {
                    let data = doc.data()
                    if let unreadMap = data["unreadCount"] as? [String: Int] {
                        total += unreadMap[userId] ?? 0
                    }
                }
                totalUnreadCount = total
            }
    }
}

struct ConversationRow: View {

    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4F46E5"),
                                Color(hex: "7C3AED")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Text(conversation.otherUserInitial)
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {

                HStack {
                    Text(conversation.otherUserName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            Color(hex: "1E293B")
                        )

                    Spacer()

                    if !conversation.lastMessageTimeFormatted.isEmpty {
                        Text(conversation.lastMessageTimeFormatted)
                            .font(.caption)
                            .foregroundStyle(
                                Color(hex: "94A3B8")
                            )
                    }
                }

                HStack {
                    Text(
                        conversation.lastMessage
                        ?? "No messages yet"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        Color(hex: "64748B")
                    )
                    .lineLimit(1)

                    Spacer()

                    Text(
                        conversation.otherUserRole.capitalized
                    )
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Color(hex: "4F46E5")
                            .opacity(0.1)
                    )
                    .foregroundStyle(
                        Color(hex: "4F46E5")
                    )
                    .clipShape(.rect(cornerRadius: 6))
                }
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 6,
            x: 0,
            y: 2
        )
    }
    
}

#Preview {
    ConversationsListView()
        .environment(AuthManager.shared)
}
