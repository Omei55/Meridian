// DashboardViewModel.swift
// Now with SwiftData caching
// Flow: load from cache immediately → fetch from API → update cache
// This means data is always visible instantly even offline

import Foundation
import Observation
import SwiftData

@Observable class DashboardViewModel {
    
    var courses: [Course] = []
    var upcomingAssignments: [Assignment] = []
    var isLoading = false
    var errorMessage: String?
    
    // Tracks whether we're showing cached or fresh data
    var isShowingCachedData = false
    var lastSyncedAt: Date?
    
    // MARK: — Fetch Dashboard Data
    func fetchDashboardData(context: ModelContext) async {
        
        // Step 1 — Load from cache immediately
        // User sees data instantly while API call is in flight
        loadFromCache(context: context)
        
        // Step 2 — Fetch fresh data from API
        isLoading = true
        errorMessage = nil
        upcomingAssignments = []
        defer { isLoading = false }
        
        do {
            let fetched: [Course] = try await APIClient.shared.request(
                endpoint: "/courses",
                method: "GET"
            )
            
            // Step 3 — Update UI with fresh data
            courses = fetched
            isShowingCachedData = false
            
            // Step 4 — Save to cache for next time
            saveCoursesToCache(fetched, context: context)
            
            // Step 5 — Fetch assignments concurrently
            await withTaskGroup(of: Void.self) { group in
                for course in courses {
                    group.addTask {
                        await self.fetchAssignments(
                            for: course.id,
                            context: context
                        )
                    }
                }
            }
            
            lastSyncedAt = Date()
            
        } catch {
            // API failed — we're already showing cached data
            // Just show an error message, don't clear the screen
            errorMessage = "Could not refresh. Showing cached data."
            isShowingCachedData = true
        }
    }
    
    // MARK: — Load from Cache
    // Called first before any API call
    // Gives user instant data on app launch
    private func loadFromCache(context: ModelContext) {
        do {
            let cachedCourses = try context.fetch(FetchDescriptor<CachedCourse>())
            if !cachedCourses.isEmpty {
                courses = cachedCourses.map { $0.toCourse() }
                isShowingCachedData = true
            }
            
            let cachedAssignments = try context.fetch(FetchDescriptor<CachedAssignment>())
            if !cachedAssignments.isEmpty {
                upcomingAssignments = cachedAssignments
                    .map { $0.toAssignment() }
                    .sorted { ($0.dueDateFormatted ?? Date()) < ($1.dueDateFormatted ?? Date()) }
            }
        } catch {
            print("Cache load error: \(error)")
        }
    }
    
    // MARK: — Save Courses to Cache
    private func saveCoursesToCache(_ courses: [Course], context: ModelContext) {
        do {
            // Delete existing cached courses
            let existing = try context.fetch(FetchDescriptor<CachedCourse>())
            existing.forEach { context.delete($0) }
            
            // Insert fresh data
            courses.forEach { course in
                context.insert(CachedCourse(from: course))
            }
            
            try context.save()
        } catch {
            print("Cache save error: \(error)")
        }
    }
    
    // MARK: — Fetch Assignments
    func fetchAssignments(for courseId: String, context: ModelContext) async {
        do {
            let fetched: [Assignment] = try await APIClient.shared.request(
                endpoint: "/courses/\(courseId)/assignments",
                method: "GET"
            )
            
            upcomingAssignments.append(contentsOf: fetched)
            upcomingAssignments.sort {
                ($0.dueDateFormatted ?? Date()) < ($1.dueDateFormatted ?? Date())
            }
            
            // Cache assignments
            saveAssignmentsToCache(fetched, context: context)
            
        } catch {
            print("Failed to fetch assignments for course \(courseId): \(error)")
        }
    }
    
    // MARK: — Save Assignments to Cache
    private func saveAssignmentsToCache(_ assignments: [Assignment], context: ModelContext) {
        do {
            assignments.forEach { assignment in
                // Check if already cached
                let id = assignment.id
                let existing = try? context.fetch(
                    FetchDescriptor<CachedAssignment>(
                        predicate: #Predicate { $0.id == id }
                    )
                )
                
                if let existingItem = existing?.first {
                    // Update existing
                    existingItem.title = assignment.title
                    existingItem.dueDate = assignment.dueDate
                    existingItem.lastSyncedAt = Date()
                } else {
                    // Insert new
                    context.insert(CachedAssignment(from: assignment))
                }
            }
            try context.save()
        } catch {
            print("Assignment cache save error: \(error)")
        }
    }
    
    // MARK: — Fetch Courses Only (no assignments)
    func fetchCourses(context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetched: [Course] = try await APIClient.shared.request(
                endpoint: "/courses",
                method: "GET"
            )
            courses = fetched
            isShowingCachedData = false
            saveCoursesToCache(fetched, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
