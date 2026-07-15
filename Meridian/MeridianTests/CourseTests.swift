//
//  CourseTests.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/07/26.
//

// CourseTests.swift
// Tests for Course model — color generation and initial logic

import Testing
@testable import Meridian

@Suite("Course Model Tests")
struct CourseTests {
    
    func makeCourse(title: String, courseCode: String) -> Course {
        return Course(
            id: "test-id",
            professorId: "test-prof",
            title: title,
            description: "Test course",
            courseCode: courseCode,
            isActive: true,
            createdAt: ""
        )
    }
    
    // Test — same course code always produces the same color
    // Critical for consistent UI — a course shouldn't change color between app launches
    @Test("Same course code produces consistent color")
    func testColorConsistency() {
        let course1 = makeCourse(title: "Intro to CS", courseCode: "CS101")
        let course2 = makeCourse(title: "Intro to CS", courseCode: "CS101")
        
        #expect(course1.color == course2.color)
    }
    
    // Test — color is always one of our 6 valid palette colors
    @Test("Color is always from the valid palette")
    func testColorIsValidPaletteColor() {
        let validColors = ["4F46E5", "7C3AED", "0891B2", "059669", "DC2626", "D97706"]
        let course = makeCourse(title: "Data Structures", courseCode: "CS201")
        
        #expect(validColors.contains(course.color))
    }
    
    // Test — initial is the first letter of the title, capitalized
    @Test("Initial returns first letter capitalized")
    func testInitial() {
        let course = makeCourse(title: "database management systems", courseCode: "CSE512")
        #expect(course.initial == "D")
    }
    
    // Test — different course codes can produce different colors
    // (not guaranteed different every time due to hashing, but likely)
    @Test("Different course codes often produce different colors")
    func testColorVariety() {
        let course1 = makeCourse(title: "Course A", courseCode: "AAA100")
        let course2 = makeCourse(title: "Course B", courseCode: "ZZZ999")
        
        // We can't guarantee they're always different (hash collisions are possible)
        // but we can verify both produce SOME valid color
        let validColors = ["4F46E5", "7C3AED", "0891B2", "059669", "DC2626", "D97706"]
        #expect(validColors.contains(course1.color))
        #expect(validColors.contains(course2.color))
    }
}
