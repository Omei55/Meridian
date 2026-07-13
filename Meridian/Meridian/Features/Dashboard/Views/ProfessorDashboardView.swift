//
//  ProfessorDashboardView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 12/06/26.
//

import SwiftUI
import SwiftData

struct ProfessorDashboardView: View {

    @State private var viewModel = DashboardViewModel()
    @Environment(AuthManager.self) private var authManager
    @State private var showCreateCourse = false
    @Environment(\.modelContext) private var modelContext

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

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

                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 200, height: 200)
                            .offset(x: -80, y: -40)

                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 140, height: 140)
                            .offset(x: 100, y: 50)

                        HStack {
                            VStack(alignment: .leading, spacing: 6) {

                                Text(greeting)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white.opacity(0.75))

                                Text(
                                    authManager.currentUser?
                                        .fullName
                                        .components(separatedBy: " ")
                                        .first ?? "Professor"
                                )
                                .font(
                                    .system(
                                        size: 26,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.white)

                                Text("Here's your overview")
                                    .font(.caption)
                                    .foregroundStyle(Color.white.opacity(0.6))
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 52, height: 52)

                                Text(
                                    authManager.currentUser?.fullName.prefix(1)
                                    ?? "P"
                                )
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 32)
                    }
                    .ignoresSafeArea(edges: .top)
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 24,
                            bottomTrailingRadius: 24,
                            topTrailingRadius: 0
                        )
                    )

                    HStack(spacing: 12) {
                        StatCard(
                            value: "\(viewModel.courses.count)",
                            label: "Courses",
                            icon: "books.vertical.fill",
                            color: "4F46E5"
                        )

                        StatCard(
                            value: "\(viewModel.upcomingAssignments.count)",
                            label: "Assignments",
                            icon: "doc.fill",
                            color: "0891B2"
                        )

                        StatCard(
                            value: "0",
                            label: "Submissions",
                            icon: "tray.fill",
                            color: "059669"
                        )
                    }
                    .padding(.horizontal, 20)

//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Quick Actions")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundStyle(Color(hex: "1E293B"))
//                            .padding(.horizontal, 20)
//
//                        HStack(spacing: 12) {
//                            QuickActionButton(
//                                title: "New Course",
//                                icon: "plus.circle.fill",
//                                color: "4F46E5"
//                            ) {
//                                showCreateCourse = true
//                            }
//
//                            QuickActionButton(
//                                title: "New Assignment",
//                                icon: "doc.badge.plus",
//                                color: "0891B2"
//                            ) {
//                            }
//
//                            QuickActionButton(
//                                title: "View Submissions",
//                                icon: "tray.2.fill",
//                                color: "059669"
//                            ) {
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("My Courses")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "1E293B"))

                            Spacer()

                            Button {
                                showCreateCourse = true

                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.caption)

                                    Text("New")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Color(hex: "4F46E5").opacity(0.1)
                                )
                                .foregroundStyle(Color(hex: "4F46E5"))
                                .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                        .padding(.horizontal, 20)

                        if viewModel.isLoading {

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<4, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "F1F5F9"))
                                        .frame(height: 140)
                                        .redacted(reason: .placeholder)
                                }
                            }
                            .padding(.horizontal, 20)

                        } else if viewModel.courses.isEmpty {

                            VStack(spacing: 12) {
                                Image(systemName: "books.vertical")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color(hex: "94A3B8"))

                                Text("No courses yet")
                                    .font(.headline)
                                    .foregroundStyle(Color(hex: "1E293B"))

                                Text("Create your first course to get started")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "64748B"))
                                    .multilineTextAlignment(.center)

                                Button {
                                    showCreateCourse = true

                                } label: {
                                    Text("Create Course")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "4F46E5"))
                                        .foregroundStyle(.white)
                                        .clipShape(.rect(cornerRadius: 12))
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)

                        } else {

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.courses) { course in
                                    NavigationLink(destination: CourseDetailView(course: course)
                                        .environment(AuthManager.shared)) {
                                        CourseCard(course: course)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .refreshable {
                await viewModel.fetchDashboardData(context: modelContext)
            }
            .task {
                await viewModel.fetchDashboardData(context: modelContext)

            }.sheet(isPresented: $showCreateCourse) {
                CreateCourseView {
                    Task {
                        await viewModel.fetchDashboardData(context: modelContext)

                    }
                }
            }
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour < 12 { return "Good morning 👋" }
        if hour < 17 { return "Good afternoon 👋" }

        return "Good evening 👋"
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: color))

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "1E293B"))

            Text(label)
                .font(.caption)
                .foregroundStyle(Color(hex: "64748B"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: color).opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: color))
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "1E293B"))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

#Preview {
    ProfessorDashboardView()
        .environment(AuthManager.shared)
}
