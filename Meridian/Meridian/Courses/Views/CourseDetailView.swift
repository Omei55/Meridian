//
//  CourseDetailView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/06/26.
//

import SwiftUI

struct CourseDetailView: View {

    @State private var viewModel: CourseDetailViewModel

    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    init(course: Course) {
        _viewModel = State(
            initialValue: CourseDetailViewModel(course: course)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                ZStack(alignment: .bottomLeading) {

                    Color(hex: viewModel.course.color)
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top)

//                    Text(viewModel.course.initial)
//                        .font(.system(size: 120, weight: .black))
//                        .foregroundStyle(.white.opacity(0.1))
//                        .offset(x: 160, y: 20)

                    VStack(alignment: .leading, spacing: 6) {

                        Text(viewModel.course.courseCode)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 20))
                            

                        Text(viewModel.course.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        if let description = viewModel.course.description {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 5)
                    
                }

                VStack(alignment: .leading, spacing: 16) {

                    HStack {
                        Text("Assignments")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "1E293B"))

                        if !viewModel.assignments.isEmpty {
                            Text("\(viewModel.assignments.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Color(hex: "4F46E5").opacity(0.1)
                                )
                                .foregroundStyle(Color(hex: "4F46E5"))
                                .clipShape(.rect(cornerRadius: 20))
                        }

                        Spacer()

                        if authManager.isProfessor {
                            Button {
                                viewModel.showCreateAssignment = true
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
                    }

                    if viewModel.isLoading {

                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F1F5F9"))
                                .frame(height: 80)
                                .redacted(reason: .placeholder)
                        }

                    } else if viewModel.assignments.isEmpty {

                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 36))
                                .foregroundStyle(Color(hex: "94A3B8"))

                            Text("No assignments yet")
                                .font(.headline)
                                .foregroundStyle(Color(hex: "1E293B"))

                            Text(
                                authManager.isProfessor
                                ? "Tap 'New' to create your first assignment"
                                : "Your professor hasn't posted any assignments yet"
                            )
                            .font(.caption)
                            .foregroundStyle(Color(hex: "64748B"))
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)

                    } else {

                        ForEach(viewModel.assignments) { assignment in
                            NavigationLink(destination: AssignmentDetailView(assignment: assignment)
                                .environment(AuthManager.shared)) {
                                AssignmentRow(assignment: assignment)
                            }
                            .buttonStyle(.plain)
                            // Swipe to delete — professor only
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if authManager.isProfessor {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteAssignment(assignment)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .background(Color(hex: "F8FAFC"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchAssignments()
        }
        .sheet(isPresented: $viewModel.showCreateAssignment) {
            CreateAssignmentView(courseId: viewModel.course.id) {
                Task {
                    await viewModel.fetchAssignments()
                }
            }
        }
    }
}

struct AssignmentRow: View {
    let assignment: Assignment

    var body: some View {
        HStack(spacing: 14) {

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: assignment.deadlineColor))
                .frame(width: 4, height: 50)

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

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(hex: "CBD5E1"))
        }
        .padding(14)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        CourseDetailView(
            course: Course(
                id: "123",
                professorId: "456",
                title: "Introduction to Computer Science",
                description: "Learn the fundamentals of CS",
                courseCode: "CS101",
                isActive: true,
                createdAt: ""
            )
        )
        .environment(AuthManager.shared)
    }
}
