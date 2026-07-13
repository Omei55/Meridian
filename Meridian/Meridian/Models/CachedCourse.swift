//
//  CachedCourse.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 08/07/26.
//

// CachedCourse.swift
// SwiftData model for locally persisted courses
// Separate from the Course struct which is used for API decoding
// Why separate? — SwiftData @Model classes have different requirements
// than Codable structs. Keeping them separate avoids conflicts.

import Foundation
import SwiftData

@Model
final class CachedCourse {
    
    // @Attribute(.unique) prevents duplicate entries
    // If we try to insert a course that already exists
    // SwiftData updates it instead of creating a duplicate
    @Attribute(.unique) var id: String
    var professorId: String
    var title: String
    var courseDescription: String?
    var courseCode: String
    var isActive: Bool
    var createdAt: String
    
    // When this cache entry was last updated
    // Used to show "Last updated X minutes ago"
    var lastSyncedAt: Date
    
    init(from course: Course) {
        self.id = course.id
        self.professorId = course.professorId
        self.title = course.title
        self.courseDescription = course.description
        self.courseCode = course.courseCode
        self.isActive = course.isActive
        self.createdAt = course.createdAt
        self.lastSyncedAt = Date()
    }
    
    // Convert back to Course struct for use in existing views
    // Views use Course structs — this bridges the gap
    func toCourse() -> Course {
        return Course(
            id: id,
            professorId: professorId,
            title: title,
            description: courseDescription,
            courseCode: courseCode,
            isActive: isActive,
            createdAt: createdAt
        )
    }
}
