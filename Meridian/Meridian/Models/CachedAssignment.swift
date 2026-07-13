//
//  CachedAssignment.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 08/07/26.
//

// CachedAssignment.swift
// SwiftData model for locally persisted assignments

import Foundation
import SwiftData

@Model
final class CachedAssignment {
    
    @Attribute(.unique) var id: String
    var courseId: String
    var title: String
    var assignmentDescription: String?
    var fileUrl: String?
    var dueDate: String
    var createdAt: String
    var lastSyncedAt: Date
    
    init(from assignment: Assignment) {
        self.id = assignment.id
        self.courseId = assignment.courseId
        self.title = assignment.title
        self.assignmentDescription = assignment.description
        self.fileUrl = assignment.fileUrl
        self.dueDate = assignment.dueDate
        self.createdAt = assignment.createdAt
        self.lastSyncedAt = Date()
    }
    
    func toAssignment() -> Assignment {
        return Assignment(
            id: id,
            courseId: courseId,
            title: title,
            description: assignmentDescription,
            fileUrl: fileUrl,
            dueDate: dueDate,
            createdAt: createdAt
        )
    }
}
