import SwiftUI
import SwiftData

struct StudentDashboardView: View {
    
    @State private var viewModel = DashboardViewModel()
    @Environment(AuthManager.self) private var authManager
    @State private var showJoinCourse = false
    @Environment(\.modelContext) private var modelContext
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: — Cached Data Banner
                    // Shows when displaying cached data due to network error
                    if viewModel.isShowingCachedData && viewModel.errorMessage != nil {
                        HStack(spacing: 10) {
                            Image(systemName: "wifi.slash")
                                .foregroundStyle(Color(hex: "F59E0B"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Showing cached data")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "1E293B"))
                                Text("Pull down to retry")
                                    .font(.caption2)
                                    .foregroundStyle(Color(hex: "64748B"))
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await viewModel.fetchDashboardData(context: modelContext)
                                }
                            } label: {
                                Text("Retry")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "F59E0B").opacity(0.15))
                                    .foregroundStyle(Color(hex: "F59E0B"))
                                    .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "FEF9C3"))
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text(greeting)
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "64748B"))
                            
                            Text(
                                authManager.currentUser?
                                    .fullName
                                    .components(separatedBy: " ")
                                    .first ?? "Student"
                            )
                            .font(
                                .system(
                                    size: 28,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(Color(hex: "1E293B"))
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "4F46E5"))
                                .frame(width: 44, height: 44)
                            
                            Text(
                                authManager.currentUser?.fullName.prefix(1)
                                ?? "S"
                            )
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if !viewModel.upcomingAssignments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "1E293B"))
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.upcomingAssignments.filter {
                                        // Only show assignments due within the next 7 days on the strip
                                        // Past due and further assignments show in the Tasks tab
                                        guard let date = $0.dueDateFormatted else { return false }
                                        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
                                        return days >= 0 && days <= 7
                                    }.prefix(10), id: \.id) { assignment in
                                        DeadlineCard(assignment: assignment)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("My Courses")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "1E293B"))
                            
                            Spacer()
                            
                            Button {
                                showJoinCourse = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    
                                    Text("Join")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Color(hex: "4F46E5").opacity(0.1)
                                )
                                .foregroundStyle(Color(hex: "4F46E5"))
                                .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.isLoading {
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<4, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "F1F5F9"))
                                        .frame(height: 140)
                                        .redacted(reason: .placeholder)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                        }  else if viewModel.courses.isEmpty && !viewModel.isLoading {
                            VStack(spacing: 12) {
                                Image(systemName: viewModel.errorMessage != nil ? "wifi.slash" : "books.vertical")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                
                                Text(viewModel.errorMessage != nil ? "Unable to load courses" : "No courses yet")
                                    .font(.headline)
                                    .foregroundStyle(Color(hex: "1E293B"))
                                
                                Text(viewModel.errorMessage != nil
                                     ? "Check your connection and try again"
                                     : "Join a course using a course code from your professor")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "64748B"))
                                .multilineTextAlignment(.center)
                                
                                if viewModel.errorMessage != nil {
                                    Button {
                                        Task {
                                            await viewModel.fetchDashboardData(context: modelContext)
                                        }
                                    } label: {
                                        Text("Try Again")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(Color(hex: "4F46E5"))
                                            .foregroundStyle(.white)
                                            .clipShape(.rect(cornerRadius: 12))
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }else {
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.courses) { course in
                                    NavigationLink(destination: CourseDetailView(course: course)
                                        .environment(AuthManager.shared)) {
                                            CourseCard(course: course)
                                        }
                                        .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "F8FAFC"))
            .refreshable {
                await viewModel.fetchDashboardData(context: modelContext)
            }
            .task {
                await viewModel.fetchDashboardData(context: modelContext)
            }
            .sheet(isPresented: $showJoinCourse) {
                JoinCourseView {
                    Task {
                        await viewModel.fetchDashboardData(context: modelContext)
                    }
                }
            }
        }
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 { return "Good morning 👋" }
        if hour < 17 { return "Good afternoon 👋" }
        
        return "Good evening 👋"
    }
    
}
    struct DeadlineCard: View {
        let assignment: Assignment
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                
                Text(assignment.relativeDeadline)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Color(hex: assignment.deadlineColor).opacity(0.15)
                    )
                    .foregroundStyle(Color(hex: assignment.deadlineColor))
                    .clipShape(.rect(cornerRadius: 6))
                
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1E293B"))
                    .lineLimit(2)
                
            }
            .padding(14)
            .frame(width: 160)
            .background(.white)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }
    
    struct CourseCard: View {
        let course: Course
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                
                ZStack(alignment: .topLeading) {
                    Color(hex: course.color)
                    
                    Text(course.initial)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(12)
                }
                .frame(height: 70)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "1E293B"))
                        .lineLimit(2)
                    
                    Text(course.courseCode)
                        .font(.caption)
                        .foregroundStyle(Color(hex: "94A3B8"))
                }
                .padding(10)
            }
            .background(.white)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }
    
    #Preview {
        StudentDashboardView()
            .environment(AuthManager.shared)
    }

