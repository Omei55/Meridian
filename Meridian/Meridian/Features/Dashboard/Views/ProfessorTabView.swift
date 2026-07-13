// ProfessorTabView.swift
// Root container for the entire professor experience
// 4 tabs — Home, Grading, Messages, Profile

import SwiftUI

struct ProfessorTabView: View {
    
    @State private var selectedTab = 0
    @State private var messagingState = MessagingState.shared
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: — Home
            ProfessorDashboardView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            // MARK: — Grading Hub
            GradingTabView()
                .tabItem {
                    Label("Grading", systemImage: selectedTab == 1 ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .tag(1)
            
            // MARK: — Messages
            ConversationsListView()
                .tabItem {
                    Label("Messages", systemImage: selectedTab == 2 ? "message.fill" : "message")
                }
                .badge(messagingState.totalUnreadCount > 0 ? messagingState.totalUnreadCount : 0)
                .tag(2)
            
            // MARK: — Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(Color(hex: "4F46E5"))
    }
}

#Preview {
    ProfessorTabView()
        .environment(AuthManager.shared)
}
