//
//  CreateAssignmentView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 15/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct CreateAssignmentView: View {

    let courseId: String

    @State private var viewModel = CreateAssignmentViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showDocumentPicker = false

    var onAssignmentCreated: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "0891B2"),
                                        Color(hex: "0E7490")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 120)

                        HStack(spacing: 16) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.9))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("New Assignment")
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
                            Text("Assignment Title")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .frame(width: 20)

                                TextField(
                                    "e.g. Assignment 1 — Variables and Loops",
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
                            Text("Description (optional)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            TextField(
                                "What should students do?",
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
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Attachment (optional)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            if let fileName = viewModel.selectedFileName {

                                HStack(spacing: 12) {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(hex: "0891B2"))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(fileName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(
                                                Color(hex: "1E293B")
                                            )
                                            .lineLimit(1)

                                        if viewModel.isUploading {
                                            VStack(
                                                alignment: .leading,
                                                spacing: 4
                                            ) {
                                                Text(
                                                    "Uploading... \(Int(viewModel.uploadProgress * 100))%"
                                                )
                                                .font(.caption)
                                                .foregroundStyle(
                                                    Color(hex: "64748B")
                                                )

                                                ProgressView(
                                                    value: viewModel.uploadProgress
                                                )
                                                .tint(Color(hex: "0891B2"))
                                            }
                                        } else if viewModel.uploadedFileURL != nil {
                                            HStack(spacing: 4) {
                                                Image(
                                                    systemName:
                                                        "checkmark.circle.fill"
                                                )
                                                .foregroundStyle(
                                                    Color(hex: "10B981")
                                                )

                                                Text(
                                                    "Uploaded successfully"
                                                )
                                                .font(.caption)
                                                .foregroundStyle(
                                                    Color(hex: "10B981")
                                                )
                                            }
                                        }
                                    }

                                    Spacer()

                                    Button {
                                        viewModel.selectedFileURL = nil
                                        viewModel.selectedFileName = nil
                                        viewModel.uploadedFileURL = nil
                                    } label: {
                                        Image(
                                            systemName: "xmark.circle.fill"
                                        )
                                        .foregroundStyle(
                                            Color(hex: "94A3B8")
                                        )
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

                            } else {

                                Button {
                                    showDocumentPicker = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.up.doc")
                                            .font(.system(size: 20))
                                            .foregroundStyle(
                                                Color(hex: "0891B2")
                                            )

                                        VStack(
                                            alignment: .leading,
                                            spacing: 2
                                        ) {
                                            Text("Attach PDF")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(
                                                    Color(hex: "1E293B")
                                                )

                                            Text("Tap to browse files")
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
                                    .padding(14)
                                    .background(Color(hex: "F8FAFC"))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color(hex: "0891B2")
                                                    .opacity(0.3),
                                                lineWidth: 1.5
                                            )
                                    )
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Due Date")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            DatePicker(
                                "Due Date",
                                selection: $viewModel.dueDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.graphical)
                            .tint(Color(hex: "4F46E5"))
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
                            Task {
                                await viewModel.createAssignment(
                                    courseId: courseId
                                )
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "plus.circle.fill")

                                    Text("Create Assignment")
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
                            viewModel.isLoading ||
                            viewModel.isUploading
                        )
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
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
            .onChange(of: viewModel.assignmentCreated) { _, created in
                if created {
                    onAssignmentCreated()
                    dismiss()
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(
                    selectedFileURL: $viewModel.selectedFileURL,
                    selectedFileName: $viewModel.selectedFileName
                ) {
                    Task {
                        await viewModel.uploadFile()
                    }
                }
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {

    @Binding var selectedFileURL: URL?
    @Binding var selectedFileName: String?

    var onFilePicked: () -> Void

    func makeUIViewController(
        context: Context
    ) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType.pdf]
        )

        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: Context
    ) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {

        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            guard let url = urls.first else { return }

            guard url.startAccessingSecurityScopedResource() else {
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            parent.selectedFileURL = url
            parent.selectedFileName = url.lastPathComponent
            parent.onFilePicked()
        }
    }
}

#Preview {
    CreateAssignmentView(
        courseId: "123",
        onAssignmentCreated: {}
    )
}
