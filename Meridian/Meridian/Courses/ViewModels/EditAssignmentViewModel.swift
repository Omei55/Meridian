//
//  EditAssignmentViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 04/07/26.
//

// EditAssignmentViewModel.swift
// Handles logic for editing an existing assignment
// Pre-populates form with existing assignment data
// Handles optional PDF replacement with re-ingestion

import Foundation
import Observation
import FirebaseStorage

@Observable class EditAssignmentViewModel {
    
    // Pre-populated from existing assignment
    var title: String
    var description: String
    var dueDate: Date
    
    // New PDF file if professor wants to replace
    var newSelectedFileURL: URL?
    var newFileName: String?
    var newFileURL: String?
    
    // Upload state
    var isUploading = false
    var uploadProgress: Double = 0
    
    // Loading and error states
    var isLoading = false
    var errorMessage: String?
    var assignmentUpdated = false
    
    // The assignment being edited
    private let assignment: Assignment
    
    // Form validation
    var isFormValid: Bool {
        return !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(assignment: Assignment) {
        self.assignment = assignment
        
        // Pre-populate form with existing values
        self.title = assignment.title
        self.description = assignment.description ?? ""
        
        // Parse existing due date
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.dueDate = formatter.date(from: assignment.dueDate) ?? Date()
    }
    
    // Upload new PDF to Firebase Storage
    func uploadNewFile() async {
        guard let fileURL = newSelectedFileURL else { return }
        
        isUploading = true
        uploadProgress = 0
        defer { isUploading = false }
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            
            let storage = Storage.storage()
            let ref = storage.reference().child("assignments/\(UUID().uuidString).pdf")
            
            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            
            _ = try await ref.putDataAsync(fileData, metadata: metadata) { progress in
                if let progress = progress {
                    self.uploadProgress = progress.fractionCompleted
                }
            }
            
            let downloadURL = try await ref.downloadURL()
            newFileURL = downloadURL.absoluteString
            
        } catch {
            errorMessage = "File upload failed: \(error.localizedDescription)"
        }
    }
    
    // Update the assignment on the backend
    func updateAssignment() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Build update body — only send changed fields
            var body: [String: Any] = [
                "title": title,
                "description": description,
                "dueDate": ISO8601DateFormatter().string(from: dueDate)
            ]
            
            // Include new file URL if PDF was replaced
            if let fileURL = newFileURL {
                body["fileUrl"] = fileURL
            }
            
            let _: Assignment = try await APIClient.shared.request(
                endpoint: "/courses/\(assignment.courseId)/assignments/\(assignment.id)",
                method: "PATCH",
                body: body
            )
            
            // If PDF was replaced re-trigger Sage ingestion
            // So Sage has the latest PDF content
            if newFileURL != nil {
                struct IngestResponse: Codable {
                    let success: Bool
                    let chunksIngested: Int
                }
                let _: IngestResponse? = try? await APIClient.shared.request(
                    endpoint: "/ai/ingest/\(assignment.id)",
                    method: "POST"
                )
            }
            
            assignmentUpdated = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
