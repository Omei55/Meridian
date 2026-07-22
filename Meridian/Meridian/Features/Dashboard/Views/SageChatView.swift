//
//  SageChatView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 02/07/26.
//


import SwiftUI

struct SageChatView: View {
    
    let assignment: Assignment
    
    @State private var viewModel: SageViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(assignment: Assignment) {
        self.assignment = assignment
        _viewModel = State(initialValue: SageViewModel(assignment: assignment))
    }
    
    let suggestedQuestions = [
        "What is this assignment about?",
        "When is it due?",
        "Help me plan my approach",
        "Explain the requirements",
        "What are the key concepts?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "4F46E5").opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(Color(hex: "4F46E5"))
                        .font(.system(size: 14))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(assignment.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "1E293B"))
                        .lineLimit(1)
                    
                    Text(assignment.relativeDeadline)
                        .font(.caption)
                        .foregroundStyle(Color(hex: assignment.deadlineColor))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "4F46E5"))
                    Text("Sage")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "4F46E5"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "4F46E5").opacity(0.1))
                .clipShape(.rect(cornerRadius: 20))
            }
            .padding(14)
            .background(.white)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        
                        if viewModel.isSummarizing {
                            HStack(spacing: 12) {
                                SageAvatar()
                                
                                HStack(spacing: 6) {
                                    Text("Sage is reading your assignment")
                                        .font(.caption)
                                        .foregroundStyle(Color(hex: "64748B"))
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                                .padding(12)
                                .background(Color.white)
                                .clipShape(.rect(cornerRadius: 14))
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                
                                Spacer()
                            }
                        }
                        
                        ForEach(viewModel.messages) { message in
                            SageMessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isLoading {
                            HStack(spacing: 12) {
                                SageAvatar()
                                SageTypingIndicator()
                                Spacer()
                            }
                        }
                        
                        if viewModel.messages.isEmpty && !viewModel.isSummarizing {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Try asking Sage:")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .padding(.leading, 4)
                                
                                ForEach(suggestedQuestions, id: \.self) { question in
                                    Button {
                                        Task {
                                            await viewModel.sendSuggestedQuestion(question)
                                        }
                                    } label: {
                                        HStack {
                                            Text(question)
                                                .font(.subheadline)
                                                .foregroundStyle(Color(hex: "4F46E5"))
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .font(.caption)
                                                .foregroundStyle(Color(hex: "4F46E5"))
                                        }
                                        .padding(12)
                                        .background(Color(hex: "4F46E5").opacity(0.06))
                                        .clipShape(.rect(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "4F46E5").opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        
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
                        
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(16)
                }
                .scrollIndicators(.hidden)
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.isLoading) { _, _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            
            SageInputBar(
                text: $viewModel.inputText,
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .background(Color(hex: "F8FAFC"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "4F46E5"))
                }
            }
            
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color(hex: "4F46E5"))
                    Text("Ask Sage")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "1E293B"))
                }
            }
        }
        .task {
            await viewModel.fetchSummary()
        }
    }
}

struct SageAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            
            Image(systemName: "sparkles")
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
    }
}

struct SageMessageBubble: View {
    let message: SageMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isFromUser {
                Spacer()
                
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Color(hex: "4F46E5"))
                    .clipShape(.rect(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 4,
                        topTrailingRadius: 16
                    ))
                    .frame(maxWidth: 280, alignment: .trailing)
                
            } else {
                SageAvatar()
                
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "1E293B"))
                    .padding(12)
                    .background(.white)
                    .clipShape(.rect(
                        topLeadingRadius: 4,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16,
                        topTrailingRadius: 16
                    ))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: 280, alignment: .leading)
                
                Spacer()
            }
        }
    }
}

struct SageTypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "94A3B8"))
                    .frame(width: 8, height: 8)
                    .offset(y: animating ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .onAppear { animating = true }
        .onDisappear { animating = false }
    }
}

struct SageInputBar: View {
    @Binding var text: String
    let isLoading: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask Sage anything about this assignment...", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(.rect(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                )
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onSend()
            } label: {                Image(systemName: isLoading ? "hourglass" : "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        text.trimmingCharacters(in: .whitespaces).isEmpty || isLoading
                        ? Color(hex: "94A3B8")
                        : Color(hex: "4F46E5")
                    )
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
    }
}

#Preview {
    NavigationStack {
        SageChatView(assignment: Assignment(
            id: "4f828cca-8292-415d-862c-8f635119c498",
            courseId: "26b8e172-4911-489e-b5af-953d93e4887d",
            title: "Assignment 2",
            description: "Test assignment",
            fileUrl: nil,
            dueDate: "2026-07-23T06:24:00Z",
            createdAt: ""
        ))
        .environment(AuthManager.shared)
    }
}
