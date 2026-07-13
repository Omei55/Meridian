//
//  GradingTabView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 25/06/26.
//

import SwiftUI

struct GradingTabView: View {

    @State private var viewModel = GradingViewModel()
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    HStack(spacing: 12) {
                        GradingStatCard(
                            value: "\(viewModel.totalSubmissions)",
                            label: "Total",
                            icon: "tray.fill",
                            color: "4F46E5"
                        )

                        GradingStatCard(
                            value: "\(viewModel.pendingCount)",
                            label: "Pending",
                            icon: "clock.fill",
                            color: "F59E0B"
                        )

                        GradingStatCard(
                            value: "\(viewModel.gradedCount)",
                            label: "Graded",
                            icon: "checkmark.circle.fill",
                            color: "10B981"
                        )
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {

                        HStack {
                            Text("Needs Grading")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "1E293B"))

                            if viewModel.pendingCount > 0 {
                                Text("\(viewModel.pendingCount)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Color(hex: "F59E0B")
                                            .opacity(0.12)
                                    )
                                    .foregroundStyle(
                                        Color(hex: "F59E0B")
                                    )
                                    .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                        .padding(.horizontal, 20)

                        if viewModel.isLoading {

                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "F1F5F9"))
                                    .frame(height: 80)
                                    .redacted(reason: .placeholder)
                                    .padding(.horizontal, 20)
                            }

                        } else if viewModel.assignmentsWithSubmissions.isEmpty {

                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(
                                        Color(hex: "10B981")
                                    )

                                Text("All caught up!")
                                    .font(.headline)
                                    .foregroundStyle(
                                        Color(hex: "1E293B")
                                    )

                                Text("No pending submissions to grade")
                                    .font(.subheadline)
                                    .foregroundStyle(
                                        Color(hex: "64748B")
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)

                        } else {

                            ForEach(viewModel.assignmentsWithSubmissions) {
                                item in

                                NavigationLink {
                                    SubmissionsListView(
                                        assignment: item.assignment
                                    )
                                    .environment(AuthManager.shared)

                                } label: {
                                    GradingAssignmentRow(item: item)
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
            .navigationTitle("Grading")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.fetchGradingData()
            }
            .task {
                await viewModel.fetchGradingData()
            }
        }
    }
}

struct GradingStatCard: View {

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
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

struct GradingAssignmentRow: View {

    let item: GradingItem

    var body: some View {
        HStack(spacing: 14) {

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "F59E0B").opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Color(hex: "F59E0B"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1E293B"))
                    .lineLimit(1)

                Text(item.courseName)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "64748B"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.ungradedCount) ungraded")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Color(hex: "F59E0B")
                            .opacity(0.12)
                    )
                    .foregroundStyle(Color(hex: "F59E0B"))
                    .clipShape(.rect(cornerRadius: 20))

                Text("\(item.totalCount) total")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "94A3B8"))
            }

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
    GradingTabView()
        .environment(AuthManager.shared)
}
