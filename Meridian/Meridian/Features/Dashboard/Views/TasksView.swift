//
//  TasksView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 25/06/26.
//

import SwiftUI
import SwiftData

struct TasksView: View {

    @State private var viewModel = DashboardViewModel()
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var modelContext

    var overdueAssignments: [Assignment] {
        viewModel.upcomingAssignments.filter {
            guard let date = $0.dueDateFormatted else { return false }
            return date < Date()
        }
    }

    var dueSoonAssignments: [Assignment] {
        viewModel.upcomingAssignments.filter {
            guard let date = $0.dueDateFormatted else { return false }

            let days = Calendar.current.dateComponents(
                [.day],
                from: .now,
                to: date
            ).day ?? 0

            return days >= 0 && days <= 2
        }
    }

    var upcomingAssignments: [Assignment] {
        viewModel.upcomingAssignments.filter {
            guard let date = $0.dueDateFormatted else { return false }

            let days = Calendar.current.dateComponents(
                [.day],
                from: .now,
                to: date
            ).day ?? 0

            return days > 2
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: — Cached Data Banner
                    
                    
                    // MARK: — Cached Data Banner
                    // Shows when displaying cached data due to network error
                    if viewModel.isShowingCachedData && viewModel.errorMessage != nil {
                        HStack(spacing: 10) {
                            Image(systemName: "wifi.slash")
                                .foregroundStyle(Color(hex: "F59E0B"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Showing cached data")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "1E293B"))
                                Text("Pull down to retry")
                                    .font(.caption2)
                                    .foregroundStyle(Color(hex: "64748B"))
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await viewModel.fetchDashboardData(context: modelContext)
                                }
                            } label: {
                                Text("Retry")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "F59E0B").opacity(0.15))
                                    .foregroundStyle(Color(hex: "F59E0B"))
                                    .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "FEF9C3"))
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }


                    if viewModel.isLoading {

                        ForEach(0..<5, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F1F5F9"))
                                .frame(height: 80)
                                .redacted(reason: .placeholder)
                        }
                        .padding(.horizontal, 20)

                    } else if viewModel.upcomingAssignments.isEmpty {

                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(Color(hex: "10B981"))

                            Text("All caught up!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "1E293B"))

                            Text(
                                "No assignments due. Enjoy your free time."
                            )
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "64748B"))
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)

                    } else {

                        if !overdueAssignments.isEmpty {
                            TaskSection(
                                title: "Overdue",
                                icon: "exclamationmark.circle.fill",
                                iconColor: "EF4444",
                                assignments: overdueAssignments
                            )
                        }

                        if !dueSoonAssignments.isEmpty {
                            TaskSection(
                                title: "Due Soon",
                                icon: "clock.fill",
                                iconColor: "F59E0B",
                                assignments: dueSoonAssignments
                            )
                        }

                        if !upcomingAssignments.isEmpty {
                            TaskSection(
                                title: "Upcoming",
                                icon: "calendar",
                                iconColor: "10B981",
                                assignments: upcomingAssignments
                            )
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationTitle("My Tasks")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchDashboardData(context: modelContext)
            }
            .refreshable {
                await viewModel.fetchDashboardData(context: modelContext)
            }
        }
    }
}

struct TaskSection: View {

    let title: String
    let icon: String
    let iconColor: String
    let assignments: [Assignment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Color(hex: iconColor))

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1E293B"))

                Text("\(assignments.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Color(hex: iconColor)
                            .opacity(0.12)
                    )
                    .foregroundStyle(Color(hex: iconColor))
                    .clipShape(.rect(cornerRadius: 20))
            }
            .padding(.horizontal, 20)

            ForEach(assignments) { assignment in
                NavigationLink {
                    AssignmentDetailView(assignment: assignment)
                        .environment(AuthManager.shared)
                } label: {
                    TaskRow(assignment: assignment)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TaskRow: View {

    let assignment: Assignment

    var body: some View {
        HStack(spacing: 14) {

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: assignment.deadlineColor))
                .frame(width: 4, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1E293B"))
                    .lineLimit(1)

                Text(assignment.relativeDeadline)
                    .font(.caption)
                    .foregroundStyle(
                        Color(hex: assignment.deadlineColor)
                    )
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(hex: "CBD5E1"))
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
    TasksView()
        .environment(AuthManager.shared)
}
