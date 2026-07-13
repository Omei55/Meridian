

import SwiftUI
import QuickLook

struct AssignmentDetailView: View {
    

    @State private var viewModel: AssignmentDetailViewModel
    
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var previewURL: URL?
    @State private var showPDFPreview = false
    @State private var showSage = false
    @State private var showEditAssignment = false
    
    init(assignment: Assignment) {
        _viewModel = State(initialValue: AssignmentDetailViewModel(assignment: assignment))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: — Header
                
                ZStack(alignment: .bottomLeading) {
                    
               
                    Color(hex: viewModel.assignment.deadlineColor)
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top)
                    
                    
//                    Text("A")
//                        .font(.system(size: 140, weight: .black))
//                        .foregroundStyle(.white.opacity(0.1))
//                        .offset(x: 180, y: 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        
                        Text(viewModel.assignment.relativeDeadline)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 20))
                        
                        
                        Text(viewModel.assignment.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(3)
                    }
                    .padding(20)
                    .padding(.bottom, 8)
                }
                
                // MARK: — Content
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: — Description
                    if let description = viewModel.assignment.description,
                       !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "64748B"))
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text(description)
                                .font(.body)
                                .foregroundStyle(Color(hex: "1E293B"))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    }
                    
                    // MARK: — Due Date Card
                    HStack(spacing: 14) {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: viewModel.assignment.deadlineColor).opacity(0.12))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "calendar")
                                .foregroundStyle(Color(hex: viewModel.assignment.deadlineColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Due Date")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "64748B"))
                       
                            if let date = viewModel.assignment.dueDateFormatted {
                                Text(date.formatted(date: .long, time: .shortened))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "1E293B"))
                            }
                        }
                        
                        Spacer()
                        
                        // Relative deadline pill
                        Text(viewModel.assignment.relativeDeadline)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: viewModel.assignment.deadlineColor).opacity(0.12))
                            .foregroundStyle(Color(hex: viewModel.assignment.deadlineColor))
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .padding(16)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 14))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    
                    // MARK: — PDF Attachment
                    
                    if let fileUrl = viewModel.assignment.fileUrl,
                       !fileUrl.isEmpty {
                        
                        Button {
                            
                            if let url = URL(string: fileUrl) {
                                previewURL = url
                                showPDFPreview = true
                            }
                        } label: {
                            HStack(spacing: 14) {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "0891B2").opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "doc.fill")
                                        .foregroundStyle(Color(hex: "0891B2"))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Assignment PDF")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(hex: "1E293B"))
                                    
                                    Text("Tap to view")
                                        .font(.caption)
                                        .foregroundStyle(Color(hex: "64748B"))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundStyle(Color(hex: "0891B2"))
                            }
                            .padding(16)
                            .background(.white)
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                    }
                    
                    if authManager.isProfessor {
                        
               
                        NavigationLink {
                            // SubmissionsListView — building next
                            SubmissionsListView(assignment: viewModel.assignment)
                                .environment(AuthManager.shared)
                        } label: {
                            HStack {
                                Image(systemName: "tray.fill")
                                Text("View Submissions")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(.white)
                            .foregroundStyle(Color(hex: "4F46E5"))
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                        
                    } else {
                        
                      
                        if viewModel.isLoading {
                            
                            
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F1F5F9"))
                                .frame(height: 80)
                                .redacted(reason: .placeholder)
                            
                        } else if let submission = viewModel.submission {
                            
                            
                            VStack(alignment: .leading, spacing: 12) {
                                
                                HStack {
                                    Text("Your Submission")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(hex: "64748B"))
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                    
                                    Spacer()
                                    
                                    // Status badge — Submitted or Graded
                                    Text(submission.statusDisplay)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: submission.statusColor).opacity(0.12))
                                        .foregroundStyle(Color(hex: submission.statusColor))
                                        .clipShape(.rect(cornerRadius: 20))
                                }
                                
                                // Submitted at time
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(hex: "10B981"))
                                    Text(submission.submittedAtFormatted)
                                        .font(.subheadline)
                                        .foregroundStyle(Color(hex: "1E293B"))
                                }
                                
                                // Grade if available
                                if let grade = submission.grade {
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(Color(hex: "F59E0B"))
                                        Text("Grade: \(grade)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color(hex: "1E293B"))
                                    }
                                }
                            }
                            .padding(16)
                            .background(.white)
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            
                        } else {
                            // Ask Sage button — appears above submit button
                            Button {
                                showSage = true
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Ask Sage")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(hex: "4F46E5").opacity(0.1))
                                .foregroundStyle(Color(hex: "4F46E5"))
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "4F46E5").opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            
                            // Not submitted yet — show submit button
                            Button {
                                viewModel.showSubmitSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.doc.fill")
                                    Text("Submit Assignment")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(hex: "4F46E5"))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 14))
                            }
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
                // Edit button — professors only
               
            }
            if authManager.isProfessor {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditAssignment = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(Color(hex: "4F46E5"))
                    }
                }
            }
        }
        // Fetch student's submission when screen appears
        .task {
            if !authManager.isProfessor {
                await viewModel.fetchMySubmission()
            }
        }
        .navigationDestination(isPresented: $showSage) {
            SageChatView(assignment: viewModel.assignment)
                .environment(AuthManager.shared)
        }
        .quickLookPreview($previewURL)
        .sheet(isPresented: $showEditAssignment) {
            EditAssignmentView(assignment: viewModel.assignment) {
                // Refresh after edit
                // For now just dismiss — assignment detail already has the data
            }
        }
        // Submit assignment sheet — building next
        .sheet(isPresented: $viewModel.showSubmitSheet) {
            SubmitAssignmentView(assignment: viewModel.assignment) {
                Task {
                    await viewModel.fetchMySubmission()
                }
            }        }
    }
}

#Preview {
    NavigationStack {
        AssignmentDetailView(assignment: Assignment(
            id: "123",
            courseId: "456",
            title: "Assignment 1 — Variables and Loops",
            description: "Write a program demonstrating variables and loops in Swift.",
            fileUrl: nil,
            dueDate: "2026-07-01T23:59:00Z",
            createdAt: ""
        ))
        .environment(AuthManager.shared)
    }
}
