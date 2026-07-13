//
//  SageViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 02/07/26.
//

import Foundation
import Observation

struct SageMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

@Observable
class SageViewModel {

    var assignment: Assignment

    var messages: [SageMessage] = []

    var inputText = ""

    var isLoading = false
    var isSummarizing = false
    var errorMessage: String?

    private var conversationHistory: [[String: String]] = []

    init(assignment: Assignment) {
        self.assignment = assignment
    }

    func fetchSummary() async {
        isSummarizing = true

        defer {
            isSummarizing = false
        }

        do {
            let response: SageResponse =
                try await APIClient.shared.request(
                    endpoint: "/ai/summarize/\(assignment.id)",
                    method: "GET"
                )

            if let text = response.response {
                messages.append(
                    SageMessage(
                        text: text,
                        isFromUser: false
                    )
                )

                conversationHistory.append([
                    "role": "assistant",
                    "content": text
                ])
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendMessage() async {
        let question = inputText
            .trimmingCharacters(in: .whitespaces)

        guard !question.isEmpty else {
            return
        }

        messages.append(
            SageMessage(
                text: question,
                isFromUser: true
            )
        )

        conversationHistory.append([
            "role": "user",
            "content": question
        ])

        inputText = ""

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let response: SageResponse =
                try await APIClient.shared.request(
                    endpoint: "/ai/chat",
                    method: "POST",
                    body: [
                        "question": question,
                        "assignmentId": assignment.id,
                        "conversationHistory": Array(
                            conversationHistory.dropLast()
                        )
                    ]
                )

            if let text = response.response {
                messages.append(
                    SageMessage(
                        text: text,
                        isFromUser: false
                    )
                )

                conversationHistory.append([
                    "role": "assistant",
                    "content": text
                ])
            }

        } catch {
            errorMessage = error.localizedDescription

            messages.removeLast()
            conversationHistory.removeLast()
            inputText = question
        }
    }

    func sendSuggestedQuestion(
        _ question: String
    ) async {
        inputText = question
        await sendMessage()
    }
}

struct SageResponse: Codable {
    let response: String?
}
