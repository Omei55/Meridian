//
//  ProfileView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 23/06/26.
//

import SwiftUI

struct ProfileView: View {

    @Environment(AuthManager.self) private var authManager

    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 16) {

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
                                .frame(width: 90, height: 90)
                                .shadow(
                                    color: Color(hex: "4F46E5").opacity(0.3),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )

                            Text(
                                authManager.currentUser?
                                    .fullName
                                    .prefix(1) ?? "U"
                            )
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        }

                        VStack(spacing: 6) {

                            Text(
                                authManager.currentUser?.fullName
                                ?? "User"
                            )
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "1E293B"))

                            Text(
                                authManager.currentUser?.email
                                ?? ""
                            )
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "64748B"))

                            Text(
                                authManager.isProfessor
                                ? "Professor"
                                : "Student"
                            )
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(
                                authManager.isProfessor
                                ? Color(hex: "4F46E5").opacity(0.1)
                                : Color(hex: "10B981").opacity(0.1)
                            )
                            .foregroundStyle(
                                authManager.isProfessor
                                ? Color(hex: "4F46E5")
                                : Color(hex: "10B981")
                            )
                            .clipShape(.rect(cornerRadius: 20))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 8,
                        x: 0,
                        y: 2
                    )

                    VStack(spacing: 0) {

                        ProfileRow(
                            icon: "person.fill",
                            iconColor: "4F46E5",
                            title: "Full Name",
                            value: authManager.currentUser?.fullName ?? ""
                        )

                        Divider()
                            .padding(.leading, 56)

                        ProfileRow(
                            icon: "envelope.fill",
                            iconColor: "0891B2",
                            title: "Email",
                            value: authManager.currentUser?.email ?? ""
                        )

                        Divider()
                            .padding(.leading, 56)

                        ProfileRow(
                            icon: authManager.isProfessor
                                ? "person.fill.checkmark"
                                : "graduationcap.fill",
                            iconColor: authManager.isProfessor
                                ? "4F46E5"
                                : "10B981",
                            title: "Role",
                            value: authManager.isProfessor
                                ? "Professor"
                                : "Student"
                        )
                    }
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 8,
                        x: 0,
                        y: 2
                    )

                    VStack(spacing: 0) {

                        ProfileRow(
                            icon: "info.circle.fill",
                            iconColor: "64748B",
                            title: "Version",
                            value: "1.0.0 (Phase 1)"
                        )

                        Divider()
                            .padding(.leading, 56)

                        ProfileRow(
                            icon: "sparkles",
                            iconColor: "F59E0B",
                            title: "AI Assistant",
                            value: "Sage (Coming in Phase 3)"
                        )
                    }
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 8,
                        x: 0,
                        y: 2
                    )

                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(
                                systemName:
                                    "rectangle.portrait.and.arrow.right"
                            )

                            Text("Log Out")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.red.opacity(0.08))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .alert("Log Out", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) { }

                        Button("Log Out", role: .destructive) {
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            authManager.logout()
                        }                    } message: {
                        Text(
                            "Are you sure you want to log out of Meridian?"
                        )
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let iconColor: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: iconColor).opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: iconColor))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "94A3B8"))

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "1E293B"))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager.shared)
}
