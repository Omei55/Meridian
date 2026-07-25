//
//  AppDelegate.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 25/07/26.
//

// AppDelegate.swift
// Bridges UIKit's push notification callbacks into our SwiftUI app
// SwiftUI apps don't have a traditional AppDelegate by default
// but push notifications still route through UIApplicationDelegate methods

import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set ourselves as the Firebase Messaging delegate
        // This lets us receive the FCM token via didReceiveRegistrationToken
        Messaging.messaging().delegate = self
        return true
    }
    
    // MARK: — APNs Device Token Received
    // Called by iOS once registerForRemoteNotifications() succeeds
    // We pass this raw APNs token to Firebase Messaging
    // Firebase converts it into an FCM token which is what our backend actually uses
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: — Registration Failed
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: — FCM Token Received
    // This fires whenever Firebase generates or refreshes our FCM token
    // This is the actual token we send to our backend and store in PostgreSQL
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM Token: \(token)")
        
        // Send this token to our backend so we can send this device pushes later
        Task {
            await DeviceTokenManager.shared.saveTokenToBackend(token)
        }
    }
}
