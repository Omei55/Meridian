//
//  GradingSheetView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 26/06/26.
//

import SwiftUI
import QuickLook

struct GradingSheetView: View {

    let submission: SubmissionWithStudent
    let assignment: Assignment

    @Environment(\.dismiss) private var dismiss

    @State private var grade = ""

    @State private var isSaving = false
    @State private var errorMessage: String?

    @State private var previewURL: URL?

    var onGraded: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    HStack(spacing: 16) {

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
                                .frame(width: 60, height: 60)

                            Text(submission.fullName.prefix(1))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(submission.fullName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "1E293B"))

                            Text(submission.email)
                                .font(.caption)
                                .foregroundStyle(Color(hex: "64748B"))

                            Text(submission.submittedAtFormatted)
                                .font(.caption)
                                .foregroundStyle(Color(hex: "94A3B8"))
                        }

                        Spacer()

                        Text(submission.statusDisplay)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Color(hex: submission.statusColor)
                                    .opacity(0.12)
                            )
                            .foregroundStyle(
                                Color(hex: submission.statusColor)
                            )
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .padding(16)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 6,
                        x: 0,
                        y: 2
                    )

                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(Color(hex: "4F46E5"))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Assignment")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "64748B"))

                            Text(assignment.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "1E293B"))
                        }

                        Spacer()
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

                    Button {
                        if let url = URL(string: submission.fileUrl) {
                            previewURL = url
                        }
                    } label: {
                        HStack(spacing: 12) {

                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        Color(hex: "0891B2")
                                            .opacity(0.12)
                                    )
                                    .frame(width: 44, height: 44)

                                Image(systemName: "doc.fill")
                                    .foregroundStyle(Color(hex: "0891B2"))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("View Submission")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "1E293B"))

                                Text("Tap to open PDF")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "64748B"))
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(Color(hex: "0891B2"))
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
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grade")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(hex: "64748B"))

                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color(hex: "F59E0B"))
                                .frame(width: 20)

                            TextField(
                                submission.grade ?? "e.g. A, B+, 95/100",
                                text: $grade
                            )
                            .autocorrectionDisabled()
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

                        if let existingGrade = submission.grade {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: "10B981"))

                                Text("Current grade: \(existingGrade)")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "10B981"))
                            }
                        }
                    }

                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)

                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)

                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .clipShape(.rect(cornerRadius: 10))
                    }

                    Button {
                        Task {
                            await saveGrade()
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")

                                Text("Save Grade")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            !grade.isEmpty
                            ? Color(hex: "4F46E5")
                            : Color(hex: "94A3B8")
                        )
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(grade.isEmpty || isSaving)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Grade Submission")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "64748B"))
                }
            }
            .quickLookPreview($previewURL)
        }
    }

    func saveGrade() async {
        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        do {
            let _: Submission = try await APIClient.shared.request(
                endpoint: "/courses/\(assignment.courseId)/assignments/\(assignment.id)/submissions/\(submission.id)",
                method: "PATCH",
                body: [
                    "status": "graded",
                    "grade": grade
                ]
            )

            onGraded()
            dismiss()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
