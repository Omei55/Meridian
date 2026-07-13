//
//  CreateAssignmentViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 15/06/26.
//

import Foundation
import Observation
import FirebaseStorage

@Observable
class CreateAssignmentViewModel {

    var title = ""
    var description = ""

    var dueDate = Date().addingTimeInterval(86400)

    var selectedFileURL: URL?
    var selectedFileName: String?

    var uploadedFileURL: String?

    var uploadProgress: Double = 0

    var isUploading = false

    var isLoading = false
    var errorMessage: String?
    var assignmentCreated = false

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func uploadFile() async {
        guard let fileURL = selectedFileURL else { return }

        isUploading = true
        uploadProgress = 0

        defer { isUploading = false }

        do {
            let fileData = try Data(contentsOf: fileURL)

            let storage = Storage.storage()
            let storageRef = storage.reference()

            let fileRef = storageRef.child(
                "assignments/\(UUID().uuidString).pdf"
            )

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"

            _ = try await fileRef.putDataAsync(
                fileData,
                metadata: metadata
            ) { progress in
                if let progress = progress {
                    self.uploadProgress = progress.fractionCompleted
                }
            }

            let downloadURL = try await fileRef.downloadURL()

            uploadedFileURL = downloadURL.absoluteString

        } catch {
            errorMessage = "File upload failed: \(error.localizedDescription)"
        }
    }

    func createAssignment(courseId: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            var body: [String: Any] = [
                "title": title,
                "description": description,
                "dueDate": ISO8601DateFormatter().string(from: dueDate)
            ]

            if let fileURL = uploadedFileURL {
                body["fileUrl"] = fileURL
            }

            let _: Assignment = try await APIClient.shared.request(
                endpoint: "/courses/\(courseId)/assignments",
                method: "POST",
                body: body
            )

            assignmentCreated = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        title = ""
        description = ""
        dueDate = Date().addingTimeInterval(86400)
        selectedFileURL = nil
        selectedFileName = nil
        uploadedFileURL = nil
        uploadProgress = 0
        errorMessage = nil
        assignmentCreated = false
    }
}
