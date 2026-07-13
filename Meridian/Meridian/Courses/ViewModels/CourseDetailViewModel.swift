//
//  CourseDetailViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/06/26.
//

import Foundation
import Observation

@Observable
class CourseDetailViewModel {

    var course: Course

    var assignments: [Assignment] = []

    var isLoading = false
    var errorMessage: String?

    var showCreateAssignment = false

    init(course: Course) {
        self.course = course
    }

    func fetchAssignments() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let fetched: [Assignment] = try await APIClient.shared.request(
                endpoint: "/courses/\(course.id)/assignments",
                method: "GET"
            )

            assignments = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    // Delete an assignment
    // Calls backend DELETE endpoint then removes from local array
    func deleteAssignment(_ assignment: Assignment) async {
        do {
            // We need a simple empty response type for DELETE
            struct EmptyResponse: Codable {}
            
            let _: EmptyResponse = try await APIClient.shared.request(
                endpoint: "/courses/\(course.id)/assignments/\(assignment.id)",
                method: "DELETE"
            )
            
            // Remove from local array immediately
            // so UI updates without needing a refetch
            assignments.removeAll { $0.id == assignment.id }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
