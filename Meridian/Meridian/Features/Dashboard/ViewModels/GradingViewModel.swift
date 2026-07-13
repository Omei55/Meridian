//
//  GradingViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 26/06/26.
//

// GradingViewModel.swift
// Fetches all courses and their submissions
// Calculates stats and builds the grading items list
// Used by GradingTabView

import Foundation
import Observation

// Represents one assignment that has submissions
// Contains the assignment, course name, and submission counts
struct GradingItem: Identifiable {
    let id: String
    let assignment: Assignment
    let courseName: String
    let totalCount: Int
    let ungradedCount: Int
}

@Observable class GradingViewModel {
    
    // List of assignments that have at least one submission
    var assignmentsWithSubmissions: [GradingItem] = []
    
    // Stats
    var totalSubmissions = 0
    var pendingCount = 0
    var gradedCount = 0
    
    var isLoading = false
    var errorMessage: String?
    
    // Fetch all data needed for the grading tab
    // Flow: get courses → get assignments for each course
    // → get submissions for each assignment
    // → build GradingItems for assignments that have submissions
    func fetchGradingData() async {
        isLoading = true
        errorMessage = nil
        assignmentsWithSubmissions = []
        totalSubmissions = 0
        pendingCount = 0
        gradedCount = 0
        defer { isLoading = false }
        
        do {
            // Step 1 — fetch all professor's courses
            let courses: [Course] = try await APIClient.shared.request(
                endpoint: "/courses",
                method: "GET"
            )
            
            // Step 2 — fetch assignments and submissions concurrently
            // for all courses at the same time
            var gradingItems: [GradingItem] = []
            
            await withTaskGroup(of: [GradingItem].self) { group in
                for course in courses {
                    group.addTask {
                        await self.fetchItemsForCourse(course)
                    }
                }
                
                // Collect results from all tasks
                for await items in group {
                    gradingItems.append(contentsOf: items)
                }
            }
            
            // Sort by ungraded count — most urgent first
            assignmentsWithSubmissions = gradingItems
                .filter { $0.totalCount > 0 }
                .sorted { $0.ungradedCount > $1.ungradedCount }
            
            // Calculate totals
            totalSubmissions = gradingItems.reduce(0) { $0 + $1.totalCount }
            pendingCount = gradingItems.reduce(0) { $0 + $1.ungradedCount }
            gradedCount = totalSubmissions - pendingCount
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Fetch all assignments for a course
    // then fetch submissions for each assignment
    // Returns GradingItems for that course
    private func fetchItemsForCourse(_ course: Course) async -> [GradingItem] {
        do {
            // Get assignments for this course
            let assignments: [Assignment] = try await APIClient.shared.request(
                endpoint: "/courses/\(course.id)/assignments",
                method: "GET"
            )
            
            var items: [GradingItem] = []
            
            // Get submissions for each assignment
            for assignment in assignments {
                let submissions: [SubmissionWithStudent] = (try? await APIClient.shared.request(
                    endpoint: "/courses/\(course.id)/assignments/\(assignment.id)/submissions",
                    method: "GET"
                )) ?? []
                
                let ungradedCount = submissions.filter { $0.status == "submitted" }.count
                
                items.append(GradingItem(
                    id: assignment.id,
                    assignment: assignment,
                    courseName: course.title,
                    totalCount: submissions.count,
                    ungradedCount: ungradedCount
                ))
            }
            
            return items
            
        } catch {
            return []
        }
    }
}
