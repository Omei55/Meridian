//
//  Submission.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 19/06/26.
//

import Foundation

struct Submission: Codable, Identifiable {

    let id: String
    let assignmentId: String
    let studentId: String
    let fileUrl: String

    let status: String

    let grade: String?

    let submittedAt: String

    var submittedAtFormatted: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let date = isoFormatter.date(from: submittedAt) else {
            return "Submitted"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        return "Submitted " +
            formatter.localizedString(for: date, relativeTo: Date())
    }

    var statusColor: String {
        status == "graded" ? "10B981" : "4F46E5"
    }

    var statusDisplay: String {
        status.capitalized
    }
}
struct SubmissionWithStudent: Codable, Identifiable {
    let id: String
    let assignmentId: String
    let studentId: String
    let fileUrl: String
    let status: String
    let grade: String?
    let submittedAt: String
    
    // These come from the JOIN with users table
    let fullName: String
    let email: String
    
    // Reuse same computed properties as Submission
    var submittedAtFormatted: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: submittedAt) else { return "Submitted" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Submitted " + formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var statusColor: String {
        return status == "graded" ? "10B981" : "4F46E5"
    }
    
    var statusDisplay: String {
        return status.capitalized
    }
}
