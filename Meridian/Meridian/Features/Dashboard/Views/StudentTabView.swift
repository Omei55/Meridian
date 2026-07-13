// StudentTabView.swift
// Root container for the entire student experience
// 5 tabs — Home, Tasks, Sage, Messages, Profile

import SwiftUI

struct StudentTabView: View {
    
    @State private var selectedTab = 0
    @State private var messagingState = MessagingState.shared
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: — Home
            StudentDashboardView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            // MARK: — Tasks
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: selectedTab == 1 ? "checklist" : "checklist")
                }
                .tag(1)
            
            // MARK: — Sage
            SageHomeView()
                .tabItem {
                    Label("Sage", systemImage: selectedTab == 2 ? "sparkles" : "sparkles")
                }
                .tag(2)
            
            // MARK: — Messages
            ConversationsListView()
                .tabItem {
                    Label("Messages", systemImage: selectedTab == 3 ? "message.fill" : "message")
                }
                .badge(messagingState.totalUnreadCount > 0 ? messagingState.totalUnreadCount : 0)
                .tag(3)
            
            // MARK: — Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 4 ? "person.fill" : "person")
                }
                .tag(4)
        }
        .tint(Color(hex: "4F46E5"))
    }
}

#Preview {
    StudentTabView()
        .environment(AuthManager.shared)
}
