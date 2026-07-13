//
//  CoursesViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/06/26.
//



import Foundation
import Observation

@Observable
class CoursesViewModel {

    var courses: [Course] = []

    var title = ""
    var description = ""
    var courseCode = ""

    var isLoading = false
    var errorMessage: String?

    var courseCreated = false

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !courseCode.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func fetchCourses() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let fetched: [Course] = try await APIClient.shared.request(
                endpoint: "/courses",
                method: "GET"
            )

            courses = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createCourse() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let _: Course = try await APIClient.shared.request(
                endpoint: "/courses",
                method: "POST",
                body: [
                    "title": title,
                    "description": description,
                    "courseCode": courseCode.uppercased()
                ]
            )

            courseCreated = true

            await fetchCourses()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        title = ""
        description = ""
        courseCode = ""
        errorMessage = nil
        courseCreated = false
    }
}
