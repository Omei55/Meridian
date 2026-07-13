//
//  NewConversationView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 28/06/26.
//

import SwiftUI

struct MessageableUser: Codable, Identifiable {

    let id: String
    let fullName: String
    let email: String
    let role: String
    let courseTitle: String

    var initial: String {
        String(fullName.prefix(1)).uppercased()
    }
}

struct NewConversationView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(AuthManager.self)
    private var authManager

    @State private var searchText = ""

    @State private var messageableUsers: [MessageableUser] = []

    @State private var isLoading = false
    @State private var isStartingConversation = false
    @State private var errorMessage: String?

    var onConversationCreated: (Conversation) -> Void

    var filteredUsers: [MessageableUser] {
        guard !searchText.isEmpty else {
            return messageableUsers
        }

        return messageableUsers.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.courseTitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color(hex: "94A3B8"))

                    TextField(
                        "Search people or courses",
                        text: $searchText
                    )
                    .autocorrectionDisabled()
                }
                .padding(12)
                .background(Color(hex: "F1F5F9"))
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider()

                ScrollView {
                    VStack(spacing: 8) {

                        if isLoading {

                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "F1F5F9"))
                                    .frame(height: 70)
                                    .redacted(reason: .placeholder)
                            }

                        } else if filteredUsers.isEmpty {

                            VStack(spacing: 12) {
                                Image(
                                    systemName: searchText.isEmpty
                                    ? "person.2"
                                    : "magnifyingglass"
                                )
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    Color(hex: "94A3B8")
                                )

                                Text(
                                    searchText.isEmpty
                                    ? "No one to message yet"
                                    : "No results for \"\(searchText)\""
                                )
                                .font(.headline)
                                .foregroundStyle(
                                    Color(hex: "1E293B")
                                )

                                if searchText.isEmpty {
                                    Text(
                                        authManager.isProfessor
                                        ? "Students will appear here once they enroll in your courses"
                                        : "Professors will appear here once you join their courses"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        Color(hex: "64748B")
                                    )
                                    .multilineTextAlignment(.center)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)

                        } else {

                            ForEach(filteredUsers) { user in
                                Button {
                                    Task {
                                        await startConversation(
                                            with: user
                                        )
                                    }
                                } label: {
                                    MessageableUserRow(
                                        user: user,
                                        isLoading:
                                            isStartingConversation
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color(hex: "F8FAFC"))
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "64748B"))
                }
            }
            .task {
                await fetchMessageableUsers()
            }
        }
    }

    func fetchMessageableUsers() async {
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let users: [MessageableUser] =
                try await APIClient.shared.request(
                    endpoint: "/conversations/messageable-users",
                    method: "GET"
                )

            messageableUsers = users

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startConversation(
        with user: MessageableUser
    ) async {
        isStartingConversation = true

        defer {
            isStartingConversation = false
        }

        do {
            let conversation: Conversation =
                try await APIClient.shared.request(
                    endpoint: "/conversations",
                    method: "POST",
                    body: [
                        "participantTwoId": user.id
                    ]
                )

            onConversationCreated(conversation)
            dismiss()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct MessageableUserRow: View {

    let user: MessageableUser
    let isLoading: Bool

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
                    .frame(width: 48, height: 48)

                Text(user.initial)
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        Color(hex: "1E293B")
                    )

                HStack(spacing: 4) {
                    Image(systemName: "books.vertical")
                        .font(.caption2)
                        .foregroundStyle(
                            Color(hex: "94A3B8")
                        )

                    Text(user.courseTitle)
                        .font(.caption)
                        .foregroundStyle(
                            Color(hex: "64748B")
                        )
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(user.role.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Color(hex: "4F46E5")
                        .opacity(0.1)
                )
                .foregroundStyle(Color(hex: "4F46E5"))
                .clipShape(.rect(cornerRadius: 8))
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
        .opacity(isLoading ? 0.6 : 1)
    }
}

#Preview {
    NewConversationView { _ in

    }
    .environment(AuthManager.shared)
}
