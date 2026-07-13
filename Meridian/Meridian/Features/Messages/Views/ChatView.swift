//
//  ChatView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 28/06/26.
//

import SwiftUI

struct ChatView: View {

    let conversation: Conversation
    let currentUserId: String

    @State private var viewModel: ChatViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var scrollProxy: ScrollViewProxy?

    init(
        conversation: Conversation,
        currentUserId: String
    ) {
        self.conversation = conversation
        self.currentUserId = currentUserId

        _viewModel = State(
            initialValue: ChatViewModel(
                conversationId: conversation.id,
                currentUserId: currentUserId,
                otherUserId: conversation.otherUserId
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {

                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        }

                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser:
                                    message.isFromCurrentUser(
                                        userId: currentUserId
                                    )
                            )
                            .id(message.id)
                        }

                        if viewModel.isOtherUserTyping {
                            TypingIndicator(
                                name: conversation.otherUserName
                            )
                            .id("typing")
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(
                            "bottom",
                            anchor: .bottom
                        )
                    }
                }
                .onChange(of: viewModel.isOtherUserTyping) { _, _ in
                    withAnimation {
                        proxy.scrollTo(
                            "bottom",
                            anchor: .bottom
                        )
                    }
                }
            }

            MessageInputBar(
                text: $viewModel.messageText,
                onTyping: {
                    viewModel.setTypingStatus(true)
                },
                onSend: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
            )
        }
        .background(Color(hex: "F8FAFC"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            Color(hex: "4F46E5")
                        )
                }
            }

            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(conversation.otherUserName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            Color(hex: "1E293B")
                        )

                    Text(
                        conversation.otherUserRole.capitalized
                    )
                    .font(.caption)
                    .foregroundStyle(
                        Color(hex: "64748B")
                    )
                }
            }
        }
        .onAppear {
            Task {
                
                await AuthManager.shared.signInToFirebase()
                viewModel.startListening()
            }
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

struct MessageBubble: View {

    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {

            if isFromCurrentUser {
                Spacer()
            }

            VStack(
                alignment: isFromCurrentUser
                    ? .trailing
                    : .leading,
                spacing: 4
            ) {

                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(
                        isFromCurrentUser
                        ? .white
                        : Color(hex: "1E293B")
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                        ? Color(hex: "4F46E5")
                        : Color.white
                    )
                    .clipShape(
                        .rect(
                            topLeadingRadius:
                                isFromCurrentUser ? 18 : 4,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius:
                                isFromCurrentUser ? 4 : 18,
                            topTrailingRadius: 18
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(
                            isFromCurrentUser ? 0 : 0.04
                        ),
                        radius: 4,
                        x: 0,
                        y: 2
                    )

                HStack(spacing: 4) {
                    Text(
                        message.timestamp.formatted(
                            date: .omitted,
                            time: .shortened
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(
                        Color(hex: "94A3B8")
                    )

                    if isFromCurrentUser {
                        Image(
                            systemName: message.read
                                ? "checkmark.circle.fill"
                                : "checkmark.circle"
                        )
                        .font(.caption2)
                        .foregroundStyle(
                            message.read
                            ? Color(hex: "4F46E5")
                            : Color(hex: "94A3B8")
                        )
                    }
                }
            }
            .frame(maxWidth: 280, alignment: isFromCurrentUser ? .trailing : .leading)

            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

struct TypingIndicator: View {

    let name: String

    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom) {

            HStack(spacing: 4) {

                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(hex: "94A3B8"))
                        .frame(width: 8, height: 8)
                        .offset(y: animating ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.4)
                                .repeatForever()
                                .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 18))
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 4,
                x: 0,
                y: 2
            )

            Spacer()
        }
        .onAppear {
            animating = true
        }
        .onDisappear {
            animating = false
        }
    }
}

struct MessageInputBar: View {

    @Binding var text: String

    var onTyping: () -> Void
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            TextField(
                "Message...",
                text: $text,
                axis: .vertical
            )
            .lineLimit(1...4)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        Color(hex: "E2E8F0"),
                        lineWidth: 1.5
                    )
            }
            .onChange(of: text) { _, newValue in
                if !newValue.isEmpty {
                    onTyping()
                }
            }

            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        text.trimmingCharacters(
                            in: .whitespaces
                        ).isEmpty
                        ? Color(hex: "94A3B8")
                        : Color(hex: "4F46E5")
                    )
            }
            .disabled(
                text.trimmingCharacters(
                    in: .whitespaces
                ).isEmpty
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 8,
            x: 0,
            y: -2
        )
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: Conversation(
                id: "123",
                participantOne: "456",
                participantTwo: "789",
                courseId: nil,
                assignmentId: nil,
                lastMessage: nil,
                lastMessageTime: nil,
                createdAt: "",
                otherUserId: "789",
                otherUserName: "Alex Student",
                otherUserEmail: "alex@test.com",
                otherUserRole: "student"
            ),
            currentUserId: "456"
        )
        .environment(AuthManager.shared)
    }
}
