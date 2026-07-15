//
//  Assignment.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 12/06/26.
//

import Foundation

struct Assignment: Codable, Identifiable {

    let id: String
    let courseId: String
    let title: String
    let description: String?
    let fileUrl: String?
    let dueDate: String
    let createdAt: String
    var dueDateFormatted: Date? {
        
        // Try standard ISO8601 first
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dueDate) {
            return date
        }
        
        // Try without fractional seconds
        let isoFormatterBasic = ISO8601DateFormatter()
        isoFormatterBasic.formatOptions = [.withInternetDateTime]
        if let date = isoFormatterBasic.date(from: dueDate) {
            return date
        }
        
        // Try PostgreSQL default timestamp format as last resort
        let pgFormatter = DateFormatter()
        pgFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        pgFormatter.locale = Locale(identifier: "en_US_POSIX")
        return pgFormatter.date(from: dueDate)
    }
    var relativeDeadline: String {
        guard let date = dueDateFormatted else { return "No deadline" }
        
        // Compare calendar start-of-day, not exact timestamps
        // This ensures "tomorrow at 9am" is always "Due tomorrow"
        // regardless of what time it currently is
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDueDate = calendar.startOfDay(for: date)
        
        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfDueDate).day ?? 0
        
        if days < 0 { return "Past due" }
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "Due in \(days) days"
    }

    var deadlineColor: String {
        guard let date = dueDateFormatted else {
            return "94A3B8"
        }

        let days = Calendar.current
            .dateComponents([.day], from: .now, to: date)
            .day ?? 0

        if days < 0 { return "EF4444" }
        if days <= 2 { return "F59E0B" }

        return "10B981"
    }
}
