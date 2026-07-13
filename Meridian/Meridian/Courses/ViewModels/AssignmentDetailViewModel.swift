//
//  AssignmentDetailViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 19/06/26.
//

import Foundation
import Observation

@Observable
class AssignmentDetailViewModel {

    var assignment: Assignment

    var submission: Submission?

    var isLoading = false
    var errorMessage: String?

    var showSubmitSheet = false

    init(assignment: Assignment) {
        self.assignment = assignment
    }

    func fetchMySubmission() async {
        isLoading = true

        defer { isLoading = false }

        do {
            let result: Submission? = try? await APIClient.shared.request(
                endpoint: "/courses/\(assignment.courseId)/assignments/\(assignment.id)/submissions/me",
                method: "GET"
            )

            submission = result
        }
    }
}
