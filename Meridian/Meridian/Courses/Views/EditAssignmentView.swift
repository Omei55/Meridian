//
//  EditAssignmentView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 04/07/26.
//

// EditAssignmentView.swift
// Allows professors to edit an existing assignment
// Can update title, description, due date
// Can replace the PDF attachment
// Re-triggers Sage ingestion if PDF is replaced

import SwiftUI
import UniformTypeIdentifiers
import FirebaseStorage

struct EditAssignmentView: View {
    
    let assignment: Assignment
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditAssignmentViewModel
    @State private var showDocumentPicker = false
    
    // Called after successful update
    var onUpdated: () -> Void
    
    init(assignment: Assignment, onUpdated: @escaping () -> Void) {
        self.assignment = assignment
        self.onUpdated = onUpdated
        _viewModel = State(initialValue: EditAssignmentViewModel(assignment: assignment))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: — Header
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0891B2"), Color(hex: "0E7490")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 120)
                        
                        HStack(spacing: 16) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.9))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Edit Assignment")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text("Update details or replace PDF")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // MARK: — Form
                    VStack(spacing: 16) {
                        
                        // Title field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Assignment Title")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))
                            
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .frame(width: 20)
                                TextField("Assignment title", text: $viewModel.title)
                                    .autocorrectionDisabled()
                            }
                            .padding(14)
                            .background(Color(hex: "F8FAFC"))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                            )
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description (optional)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))
                            
                            TextField("What should students do?",
                                     text: $viewModel.description,
                                     axis: .vertical)
                                .lineLimit(4...6)
                                .padding(14)
                                .background(Color(hex: "F8FAFC"))
                                .clipShape(.rect(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                                )
                        }
                        
                        // Due date picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Due Date")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))
                            
                            DatePicker(
                                "Due Date",
                                selection: $viewModel.dueDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.graphical)
                            .tint(Color(hex: "4F46E5"))
                            .padding(14)
                            .background(Color(hex: "F8FAFC"))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                            )
                        }
                        
                        // MARK: — PDF Section
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Assignment PDF")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))
                            
                            if let fileName = viewModel.newFileName {
                                // New file selected
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(hex: "0891B2"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(fileName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(hex: "1E293B"))
                                            .lineLimit(1)
                                        
                                        if viewModel.isUploading {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Uploading... \(Int(viewModel.uploadProgress * 100))%")
                                                    .font(.caption)
                                                    .foregroundStyle(Color(hex: "64748B"))
                                                ProgressView(value: viewModel.uploadProgress)
                                                    .tint(Color(hex: "0891B2"))
                                            }
                                        } else if viewModel.newFileURL != nil {
                                            HStack(spacing: 4) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(Color(hex: "10B981"))
                                                Text("Ready to save")
                                                    .font(.caption)
                                                    .foregroundStyle(Color(hex: "10B981"))
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if !viewModel.isUploading {
                                        Button {
                                            viewModel.newSelectedFileURL = nil
                                            viewModel.newFileName = nil
                                            viewModel.newFileURL = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(Color(hex: "94A3B8"))
                                        }
                                    }
                                }
                                .padding(14)
                                .background(Color(hex: "F8FAFC"))
                                .clipShape(.rect(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                                )
                                
                            } else if assignment.fileUrl != nil {
                                // Existing file
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.fill")
                                        .foregroundStyle(Color(hex: "0891B2"))
                                    
                                    Text("Current PDF attached")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(hex: "1E293B"))
                                    
                                    Spacer()
                                    
                                    Button {
                                        showDocumentPicker = true
                                    } label: {
                                        Text("Replace")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color(hex: "0891B2"))
                                    }
                                }
                                .padding(14)
                                .background(Color(hex: "F8FAFC"))
                                .clipShape(.rect(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                                )
                                
                            } else {
                                // No file — add one
                                Button {
                                    showDocumentPicker = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.up.doc")
                                            .foregroundStyle(Color(hex: "0891B2"))
                                        Text("Attach PDF")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(hex: "1E293B"))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(Color(hex: "CBD5E1"))
                                    }
                                    .padding(14)
                                    .background(Color(hex: "F8FAFC"))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "0891B2").opacity(0.3), lineWidth: 1.5)
                                    )
                                }
                            }
                        }
                        
                        // Error message
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.08))
                            .clipShape(.rect(cornerRadius: 10))
                        }
                        
                        // Save button
                        Button {
                            Task {
                                await viewModel.updateAssignment()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading || viewModel.isUploading {
                                    ProgressView()
                                        .tint(.white)
                                    Text(viewModel.isUploading ? "Uploading PDF..." : "Saving...")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Changes")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                viewModel.isFormValid
                                ? Color(hex: "4F46E5")
                                : Color(hex: "94A3B8")
                            )
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading || viewModel.isUploading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "64748B"))
                }
            }
            .onChange(of: viewModel.assignmentUpdated) { _, updated in
                if updated {
                    onUpdated()
                    dismiss()
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(
                    selectedFileURL: $viewModel.newSelectedFileURL,
                    selectedFileName: $viewModel.newFileName
                ) {
                    Task {
                        await viewModel.uploadNewFile()
                    }
                }
            }
        }
    }
}
