//
//  CreateCourseView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/06/26.
//
import SwiftUI

struct CreateCourseView: View {

    @State private var viewModel = CoursesViewModel()

    @Environment(\.dismiss) private var dismiss

    var onCourseCreated: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
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
                            .frame(height: 120)

                        HStack(spacing: 16) {
                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.9))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("New Course")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)

                                Text("Fill in the details below")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    VStack(spacing: 16) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Course Title")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            HStack {
                                Image(systemName: "book")
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .frame(width: 20)

                                TextField(
                                    "e.g. Introduction to Computer Science",
                                    text: $viewModel.title
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
                        }

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
                                    text: $viewModel.courseCode
                                )
                                .autocapitalization(.allCharacters)
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

                            Text(
                                "Students will use this code to join your course"
                            )
                            .font(.caption)
                            .foregroundStyle(Color(hex: "94A3B8"))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description (optional)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            TextField(
                                "What is this course about?",
                                text: $viewModel.description,
                                axis: .vertical
                            )
                            .lineLimit(4...6)
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
                        }

                        if let error = viewModel.errorMessage {
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
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            Task {
                                await viewModel.createCourse()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "plus.circle.fill")

                                    Text("Create Course")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                viewModel.isFormValid
                                ? Color(hex: "4F46E5")
                                : Color(hex: "94A3B8")
                            )
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .disabled(
                            !viewModel.isFormValid ||
                            viewModel.isLoading
                        )
                    }
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
                        viewModel.resetForm()
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "64748B"))
                }
            }
            .onChange(of: viewModel.courseCreated) { _, created in
                if created {
                    onCourseCreated()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CreateCourseView(onCourseCreated: {})
}
