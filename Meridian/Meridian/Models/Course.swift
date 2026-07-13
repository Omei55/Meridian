//
//  Course.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 12/06/26.
//

import Foundation

struct Course: Codable, Identifiable {

    let id: String
    let professorId: String
    let title: String
    let description: String?
    let courseCode: String
    let isActive: Bool
    let createdAt: String

    var color: String {
        let colors = [
            "4F46E5",
            "7C3AED",
            "0891B2",
            "059669",
            "DC2626",
            "D97706"
        ]

        let index = abs(courseCode.hashValue) % colors.count
        return colors[index]
    }

    var initial: String {
        String(title.prefix(1)).uppercased()
    }
}
