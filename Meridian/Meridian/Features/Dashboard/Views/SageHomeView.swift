//
//  SageHomeView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 02/07/26.
//

import SwiftUI
import SwiftData



struct SageHomeView: View {
    
    @State private var viewModel = DashboardViewModel()
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(.rect(cornerRadius: 20))
                        
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 120, height: 120)
                            .offset(x: 100, y: -30)
                        
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hi, I'm Sage")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text("Pick an assignment and I'll help you understand it")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                    }
                    .frame(height: 120)
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Your Assignments")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "1E293B"))
                            .padding(.horizontal, 20)
                        
                        if viewModel.isLoading {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "F1F5F9"))
                                    .frame(height: 80)
                                    .redacted(reason: .placeholder)
                                    .padding(.horizontal, 20)
                            }
                            
                        } else if viewModel.upcomingAssignments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color(hex: "4F46E5").opacity(0.4))
                                
                                Text("No assignments yet")
                                    .font(.headline)
                                    .foregroundStyle(Color(hex: "1E293B"))
                                
                                Text("Once your professor posts assignments Sage will be ready to help")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "64748B"))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            
                        } else {
                            ForEach(viewModel.upcomingAssignments) { assignment in
                                NavigationLink(
                                    destination:
                                        SageChatView(assignment: assignment)
                                            .environment(AuthManager.shared)
                                ) {
                                    SageAssignmentRow(assignment: assignment)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationTitle("Sage")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.fetchDashboardData(context: modelContext)            }
            .task {
                await viewModel.fetchDashboardData(context: modelContext)
            }
        }
    }
}

struct SageAssignmentRow: View {
    
    let assignment: Assignment
    
    var body: some View {
        HStack(spacing: 14) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: assignment.deadlineColor).opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Color(hex: assignment.deadlineColor))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1E293B"))
                    .lineLimit(1)
                
                Text(assignment.relativeDeadline)
                    .font(.caption)
                    .foregroundStyle(Color(hex: assignment.deadlineColor))
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                
                Text("Ask Sage")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(Color(hex: "4F46E5"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: "4F46E5").opacity(0.08))
            .clipShape(.rect(cornerRadius: 20))
        }
        .padding(14)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    SageHomeView()
        .environment(AuthManager.shared)
}
