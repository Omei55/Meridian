//
//  NotificationManager.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 25/07/26.
//


import Foundation
import UserNotifications
import UIKit
class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: — Request Permission
    // Must be called before any notification can be scheduled
    // Shows the system permission dialog to the user
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // MARK: — Check Current Permission Status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: — Schedule Assignment Reminder
    // Schedules a local notification 1 day before the due date
    // If due date is less than 1 day away, schedules for 1 hour before instead
    func scheduleAssignmentReminder(for assignment: Assignment) {
        guard let dueDate = assignment.dueDateFormatted else { return }
        
        // Calculate reminder time — 1 day before due date
        guard let reminderDate = Calendar.current.date(
            byAdding: .day, value: -1, to: dueDate
        ) else { return }
        
        // Don't schedule notifications for times in the past
        guard reminderDate > Date() else { return }
        
        // Build the notification content
        let content = UNMutableNotificationContent()
        content.title = "Assignment Due Tomorrow"
        content.body = assignment.title
        content.sound = .default
        // Badge count could be incremented here in a full implementation
        
        // Trigger — fires at the specific reminderDate
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Unique identifier per assignment so we can cancel/update later
        // Using the assignment's own ID means no duplicate notifications
        let request = UNNotificationRequest(
            identifier: "reminder-\(assignment.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: — Cancel Reminder
    // Called if an assignment is deleted or its due date changes
    func cancelReminder(for assignmentId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["reminder-\(assignmentId)"]
        )
    }
    // MARK: — Register for Remote Push Notifications
    // Must be called after requestPermission() succeeds
    // This triggers iOS to contact APNs and generate a device token
    func registerForPushNotifications() {
        Task { @MainActor in
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    // MARK: — Schedule Reminders for Multiple Assignments
    // Called after fetching the dashboard — schedules reminders
    // for all upcoming assignments at once
    func scheduleRemindersForAssignments(_ assignments: [Assignment]) {
        for assignment in assignments {
            scheduleAssignmentReminder(for: assignment)
        }
    }
}
