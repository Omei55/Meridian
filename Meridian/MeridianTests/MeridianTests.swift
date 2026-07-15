//
//  MeridianTests.swift
//  MeridianTests
//
//  Created by Omkar Vilas Sapkal on 14/07/26.
//

// MeridianTests.swift
// Unit tests for Meridian's core models and logic
// Tests run independently of the UI, the network, or the database
// They verify pure logic — given an input, is the output correct?

import Testing
@testable import Meridian
import Foundation

// MARK: — Assignment Tests

@Suite("Assignment Model Tests")
struct AssignmentTests {
    
    // Helper to create a test assignment with a specific due date
    // This avoids repeating the same boilerplate in every test
    func makeAssignment(dueInDays: Int) -> Assignment {
        let date = Calendar.current.date(byAdding: .day, value: dueInDays, to: Date())!
        let formatter = ISO8601DateFormatter()
        let dueDateString = formatter.string(from: date)
        
        return Assignment(
            id: "test-id",
            courseId: "test-course",
            title: "Test Assignment",
            description: "Test description",
            fileUrl: nil,
            dueDate: dueDateString,
            createdAt: dueDateString
        )
    }
    
    // Test — assignment due today shows "Due today"
    @Test("Assignment due today shows correct label")
    func testDueToday() {
        let assignment = makeAssignment(dueInDays: 0)
        #expect(assignment.relativeDeadline == "Due today")
    }
    
    // Test — assignment due tomorrow shows "Due tomorrow"
    @Test("Assignment due tomorrow shows correct label")
    func testDueTomorrow() {
        let assignment = makeAssignment(dueInDays: 1)
        #expect(assignment.relativeDeadline == "Due tomorrow")
    }
    
    // Test — assignment due in 5 days shows "Due in 5 days"
    @Test("Assignment due in multiple days shows correct label")
    func testDueInMultipleDays() {
        let assignment = makeAssignment(dueInDays: 5)
        #expect(assignment.relativeDeadline == "Due in 5 days")
    }
    
    // Test — assignment overdue shows "Past due"
    @Test("Overdue assignment shows correct label")
    func testPastDue() {
        let assignment = makeAssignment(dueInDays: -3)
        #expect(assignment.relativeDeadline == "Past due")
    }
    
    // Test — deadline color logic
    // Green for far away, amber for soon, red for overdue
    @Test("Deadline color reflects urgency correctly")
    func testDeadlineColors() {
        let overdue = makeAssignment(dueInDays: -1)
        let dueSoon = makeAssignment(dueInDays: 2)
        let farAway = makeAssignment(dueInDays: 10)
        
        #expect(overdue.deadlineColor == "EF4444")   // red
        #expect(dueSoon.deadlineColor == "F59E0B")   // amber
        #expect(farAway.deadlineColor == "10B981")   // green
    }
}
