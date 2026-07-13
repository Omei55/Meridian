//
//  SubmitAssignmentView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 23/06/26.
//

import SwiftUI
import UniformTypeIdentifiers
import FirebaseStorage

struct SubmitAssignmentView: View {

    let assignment: Assignment

    @Environment(\.dismiss) private var dismiss

    @State private var showDocumentPicker = false

    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String?

    @State private var isUploading = false
    @State private var isSubmitting = false
    @State private var uploadProgress: Double = 0
    @State private var errorMessage: String?

    var onSubmitted: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

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
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white.opacity(0.9))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Submit Assignment")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)

                                Text(assignment.title)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundStyle(
                                Color(hex: assignment.deadlineColor)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Deadline")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "64748B"))

                            if let date = assignment.dueDateFormatted {
                                Text(
                                    date.formatted(
                                        date: .long,
                                        time: .shortened
                                    )
                                )
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "1E293B"))
                            }
                        }

                        Spacer()

                        Text(assignment.relativeDeadline)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Color(hex: assignment.deadlineColor)
                                    .opacity(0.12)
                            )
                            .foregroundStyle(
                                Color(hex: assignment.deadlineColor)
                            )
                            .clipShape(.rect(cornerRadius: 20))
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Submission")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(hex: "64748B"))
                            .padding(.horizontal, 20)

                        if let fileName = selectedFileName {

                            HStack(spacing: 12) {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color(hex: "4F46E5"))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fileName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(
                                            Color(hex: "1E293B")
                                        )
                                        .lineLimit(1)

                                    if isUploading {
                                        VStack(
                                            alignment: .leading,
                                            spacing: 4
                                        ) {
                                            Text(
                                                "Uploading... \(Int(uploadProgress * 100))%"
                                            )
                                            .font(.caption)
                                            .foregroundStyle(
                                                Color(hex: "64748B")
                                            )

                                            ProgressView(
                                                value: uploadProgress
                                            )
                                            .tint(Color(hex: "4F46E5"))
                                        }
                                    } else {
                                        Text("Ready to submit")
                                            .font(.caption)
                                            .foregroundStyle(
                                                Color(hex: "10B981")
                                            )
                                    }
                                }

                                Spacer()

                                if !isUploading {
                                    Button {
                                        selectedFileURL = nil
                                        selectedFileName = nil
                                    } label: {
                                        Image(
                                            systemName: "xmark.circle.fill"
                                        )
                                        .foregroundStyle(
                                            Color(hex: "94A3B8")
                                        )
                                    }
                                }
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

                        } else {

                            Button {
                                showDocumentPicker = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                Color(hex: "4F46E5")
                                                    .opacity(0.1)
                                            )
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(
                                                Color(hex: "4F46E5")
                                            )
                                    }

                                    VStack(
                                        alignment: .leading,
                                        spacing: 2
                                    ) {
                                        Text("Choose PDF File")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(
                                                Color(hex: "1E293B")
                                            )

                                        Text(
                                            "Tap to browse your files"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(
                                            Color(hex: "94A3B8")
                                        )
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(
                                            Color(hex: "CBD5E1")
                                        )
                                }
                                .padding(16)
                                .background(.white)
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            Color(hex: "4F46E5")
                                                .opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(
                                    color: Color.black.opacity(0.04),
                                    radius: 6,
                                    x: 0,
                                    y: 2
                                )
                            }
                            .padding(.horizontal, 20)
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
                        .padding(.horizontal, 20)
                    }

                    Button {
                        Task {
                            await submitAssignment()
                        }
                    } label: {
                        HStack {
                            if isUploading || isSubmitting {
                                ProgressView()
                                    .tint(.white)

                                Text(
                                    isUploading
                                    ? "Uploading..."
                                    : "Submitting..."
                                )
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)

                            } else {
                                Image(systemName: "paperplane.fill")

                                Text("Submit Assignment")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            selectedFileName != nil &&
                            !isUploading &&
                            !isSubmitting
                            ? Color(hex: "4F46E5")
                            : Color(hex: "94A3B8")
                        )
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(
                        selectedFileName == nil ||
                        isUploading ||
                        isSubmitting
                    )
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
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(
                    selectedFileURL: $selectedFileURL,
                    selectedFileName: $selectedFileName
                ) {
                }
            }
        }
    }

    func submitAssignment() async {
        guard let fileURL = selectedFileURL else { return }

        isUploading = true
        errorMessage = nil

        do {
            let fileData = try Data(contentsOf: fileURL)

            let storage = Storage.storage()
            let ref = storage.reference()
                .child("submissions/\(UUID().uuidString).pdf")

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"

            _ = try await ref.putDataAsync(
                fileData,
                metadata: metadata
            ) { progress in
                if let progress = progress {
                    self.uploadProgress = progress.fractionCompleted
                }
            }

            let downloadURL = try await ref.downloadURL()

            isUploading = false
            isSubmitting = true

            let _: Submission = try await APIClient.shared.request(
                endpoint: "/courses/\(assignment.courseId)/assignments/\(assignment.id)/submissions",
                method: "POST",
                body: [
                    "fileUrl": downloadURL.absoluteString
                ]
            )

            isSubmitting = false

            onSubmitted()
            dismiss()

        } catch {
            isUploading = false
            isSubmitting = false
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SubmitAssignmentView(
        assignment: Assignment(
            id: "123",
            courseId: "456",
            title: "Assignment 1",
            description: nil,
            fileUrl: nil,
            dueDate: "2026-07-01T23:59:00Z",
            createdAt: ""
        ),
        onSubmitted: {}
    )
}
