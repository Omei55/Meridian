//
//  MeridianApp.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 06/06/26.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct MeridianApp: App {

    @State private var authManager = AuthManager.shared
    let container: ModelContainer = {
           let schema = Schema([
               CachedCourse.self,
               CachedAssignment.self
           ])
           let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
           return try! ModelContainer(for: schema, configurations: [config])
       }()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                if authManager.isProfessor {
                    ProfessorTabView()
                } else {
                    StudentTabView()
                }
            } else {
                LoginView()
            }
        }
        .environment(authManager)
    }
}
