//
//  SubmissionsListView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 24/06/26.
//


import SwiftUI

struct SubmissionsListView: View {
    
    let assignment: Assignment
    
    @State private var submissions: [SubmissionWithStudent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Controls the grading sheet
    @State private var selectedSubmission: SubmissionWithStudent?
    @State private var showGradingSheet = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: — Header
                ZStack(alignment: .bottomLeading) {
                    Color(hex: "1E293B")
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Submissions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text(assignment.title)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            // Total count
                            Text("\(submissions.count) submission\(submissions.count == 1 ? "" : "s")")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 20))
                            
                            // Pending count
                            let pending = submissions.filter { $0.status == "submitted" }.count
                            if pending > 0 {
                                Text("\(pending) ungraded")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "F59E0B").opacity(0.3))
                                    .foregroundStyle(Color(hex: "F59E0B"))
                                    .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 8)
                }
                
                // MARK: — Submissions List
                VStack(spacing: 12) {
                    
                    if isLoading {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F1F5F9"))
                                .frame(height: 90)
                                .redacted(reason: .placeholder)
                        }
                        
                    } else if submissions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundStyle(Color(hex: "94A3B8"))
                            
                            Text("No submissions yet")
                                .font(.headline)
                                .foregroundStyle(Color(hex: "1E293B"))
                            
                            Text("Students haven't submitted this assignment yet")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "64748B"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        
                    } else {
                        ForEach(submissions) { submission in
                            // Tap to open grading sheet
                            Button {
                                selectedSubmission = submission
                                showGradingSheet = true
                            } label: {
                                SubmissionRowView(submission: submission)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(hex: "F8FAFC"))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .task {
            await fetchSubmissions()
        }
        // Grading sheet
        .sheet(isPresented: $showGradingSheet) {
            if let submission = selectedSubmission {
                GradingSheetView(
                    submission: submission,
                    assignment: assignment
                ) {
                    // Refresh after grading
                    Task {
                        await fetchSubmissions()
                    }
                }
            }
        }
    }
    
    func fetchSubmissions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetched: [SubmissionWithStudent] = try await APIClient.shared.request(
                endpoint: "/courses/\(assignment.courseId)/assignments/\(assignment.id)/submissions",
                method: "GET"
            )
            submissions = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: — Submission Row View
struct SubmissionRowView: View {
    let submission: SubmissionWithStudent
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Student avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "4F46E5").opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(submission.fullName.prefix(1))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "4F46E5"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(submission.fullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1E293B"))
                
                Text(submission.submittedAtFormatted)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "64748B"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(submission.statusDisplay)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: submission.statusColor).opacity(0.12))
                    .foregroundStyle(Color(hex: submission.statusColor))
                    .clipShape(.rect(cornerRadius: 20))
                
                if let grade = submission.grade {
                    Text(grade)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "F59E0B"))
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(hex: "CBD5E1"))
        }
        .padding(14)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
