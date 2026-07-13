//
//  JoinCourseView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 23/06/26.
//

import SwiftUI

struct JoinCourseView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var courseCode = ""

    @State private var foundCourse: Course?

    @State private var isSearching = false
    @State private var isJoining = false
    @State private var errorMessage: String?

    var onJoined: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "059669"),
                                        Color(hex: "0891B2")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 120)

                        HStack(spacing: 16) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white.opacity(0.9))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Join a Course")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)

                                Text("Enter the code from your professor")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Course Code")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(hex: "64748B"))

                        HStack {
                            Image(systemName: "number")
                                .foregroundStyle(Color(hex: "94A3B8"))
                                .frame(width: 20)

                            TextField(
                                "e.g. CS101",
                                text: $courseCode
                            )
                            .autocapitalization(.allCharacters)
                            .autocorrectionDisabled()
                            .onChange(of: courseCode) { _, _ in
                                foundCourse = nil
                                errorMessage = nil
                            }

                            if !courseCode.isEmpty {
                                Button {
                                    Task {
                                        await searchCourse()
                                    }
                                } label: {
                                    if isSearching {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Find")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(
                                                Color(hex: "4F46E5")
                                            )
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(hex: "F8FAFC"))
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color(hex: "E2E8F0"),
                                    lineWidth: 1.5
                                )
                        )

                        Text("Ask your professor for the course code")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "94A3B8"))
                    }
                    .padding(.horizontal, 20)

                    if let course = foundCourse {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Course Found")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "10B981"))
                                .padding(.horizontal, 20)

                            HStack(spacing: 14) {

                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: course.color))
                                        .frame(width: 52, height: 52)

                                    Text(course.initial)
                                        .font(
                                            .system(
                                                size: 22,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundStyle(.white)
                                }

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {
                                    Text(course.title)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(
                                            Color(hex: "1E293B")
                                        )

                                    Text(course.courseCode)
                                        .font(.caption)
                                        .foregroundStyle(
                                            Color(hex: "64748B")
                                        )

                                    if let description =
                                        course.description {

                                        Text(description)
                                            .font(.caption)
                                            .foregroundStyle(
                                                Color(hex: "94A3B8")
                                            )
                                            .lineLimit(2)
                                    }
                                }

                                Spacer()

                                Image(
                                    systemName:
                                        "checkmark.circle.fill"
                                )
                                .foregroundStyle(Color(hex: "10B981"))
                                .font(.title2)
                            }
                            .padding(16)
                            .background(.white)
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(
                                color: Color.black.opacity(0.04),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                            .padding(.horizontal, 20)
                        }
                    }

                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(
                                systemName:
                                    "exclamationmark.circle.fill"
                            )
                            .foregroundStyle(.red)

                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)

                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(.horizontal, 20)
                    }

                    Button {
                        Task {
                            await joinCourse()
                        }
                    } label: {
                        HStack {
                            if isJoining {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(
                                    systemName: "person.badge.plus"
                                )

                                Text("Join Course")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            foundCourse != nil && !isJoining
                            ? Color(hex: "059669")
                            : Color(hex: "94A3B8")
                        )
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(foundCourse == nil || isJoining)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "64748B"))
                }
            }
        }
    }

    func searchCourse() async {
        guard !courseCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        foundCourse = nil
        defer { isSearching = false }
        
        do {
            // Hit the search endpoint directly with the course code
            let course: Course = try await APIClient.shared.request(
                endpoint: "/courses/search?code=\(courseCode.uppercased())",
                method: "GET"
            )
            foundCourse = course
        } catch {
            errorMessage = "No course found with code \"\(courseCode.uppercased())\". Check with your professor."
        }
    }
    func joinCourse() async {
        guard let course = foundCourse else { return }

        isJoining = true
        errorMessage = nil

        defer { isJoining = false }

        do {
            let _: EnrollmentResponse =
                try await APIClient.shared.request(
                    endpoint: "/courses/\(course.id)/enroll",
                    method: "POST"
                )

            onJoined()
            dismiss()

        } catch {
            if error.localizedDescription.contains(
                "Already enrolled"
            ) {
                errorMessage =
                    "You're already enrolled in this course."
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct EnrollmentResponse: Codable {
    let id: String
    let studentId: String
    let courseId: String
    let enrolledAt: String
}

#Preview {
    JoinCourseView(onJoined: {})
}
