//
//  SubmissionTests.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/07/26.
//

// SubmissionTests.swift
// Tests for Submission model computed properties
// Covers status display, status color, and relative time formatting

import Testing
@testable import Meridian
import Foundation

@Suite("Submission Model Tests")
struct SubmissionTests {
    
    // Helper to create a test submission with a given status and grade
    func makeSubmission(
        status: String,
        grade: String? = nil,
        submittedAt: String = ISO8601DateFormatter().string(from: Date())
    ) -> Submission {
        return Submission(
            id: "test-id",
            assignmentId: "test-assignment",
            studentId: "test-student",
            fileUrl: "https://example.com/test.pdf",
            status: status,
            grade: grade,
            submittedAt: submittedAt
        )
    }
    
    // Test — "submitted" status maps to indigo color
    @Test("Submitted status shows indigo color")
    func testSubmittedStatusColor() {
        let submission = makeSubmission(status: "submitted")
        #expect(submission.statusColor == "4F46E5")
    }
    
    // Test — "graded" status maps to green color
    @Test("Graded status shows green color")
    func testGradedStatusColor() {
        let submission = makeSubmission(status: "graded")
        #expect(submission.statusColor == "10B981")
    }
    
    // Test — statusDisplay capitalizes correctly
    @Test("Status display is capitalized correctly")
    func testStatusDisplay() {
        let submitted = makeSubmission(status: "submitted")
        let graded = makeSubmission(status: "graded")
        
        #expect(submitted.statusDisplay == "Submitted")
        #expect(graded.statusDisplay == "Graded")
    }
    
    // Test — grade is nil when not yet graded
    @Test("Ungraded submission has nil grade")
    func testUngradedHasNilGrade() {
        let submission = makeSubmission(status: "submitted", grade: nil)
        #expect(submission.grade == nil)
    }
    
    // Test — grade is preserved when set
    @Test("Graded submission preserves grade value")
    func testGradedHasGradeValue() {
        let submission = makeSubmission(status: "graded", grade: "A+")
        #expect(submission.grade == "A+")
    }
    
    // Test — submittedAtFormatted produces a non-empty string
    // for a valid ISO8601 date
    @Test("Submitted at formats to a readable relative time")
    func testSubmittedAtFormatted() {
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        let dateString = ISO8601DateFormatter().string(from: twoHoursAgo)
        let submission = makeSubmission(status: "submitted", submittedAt: dateString)
        
        // Verify it's not empty and not the fallback string
        // (exact wording varies by locale/formatter version)
        #expect(submission.submittedAtFormatted != "Submitted")
        #expect(submission.submittedAtFormatted.hasPrefix("Submitted "))
    }
    
    // Test — invalid date string falls back gracefully instead of crashing
    @Test("Invalid date string falls back to default text")
    func testInvalidDateFallback() {
        let submission = makeSubmission(status: "submitted", submittedAt: "not-a-real-date")
        #expect(submission.submittedAtFormatted == "Submitted")
    }
}
