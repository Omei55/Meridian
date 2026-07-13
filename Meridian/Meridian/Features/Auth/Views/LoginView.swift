//
//  LoginView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 07/06/26.
//

import SwiftUI

struct LoginView: View {
    
    @State private var viewModel = LoginViewModel()
    
    @Environment(AuthManager.self) private var authManager
    
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    VStack(spacing: 16) {
                        
                        // MARK: - Header
                        ZStack {
                            
                            LinearGradient(
                                colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea(edges: .top)
                            
                            Circle()
                                .fill(Color.white.opacity(0.06))
                                .frame(width: 220, height: 220)
                                .offset(x: -80, y: -60)
                            
                            Circle()
                                .fill(Color.white.opacity(0.06))
                                .frame(width: 160, height: 160)
                                .offset(x: 100, y: 60)
                            
                            VStack(spacing: 12) {
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 90, height: 90)
                                    
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 74, height: 74)
                                    
                                    Image("meridian-logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                }
                                
                                Text("Meridian")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                Text("Your courses, understood.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white.opacity(0.75))
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 32,
                                bottomTrailingRadius: 32,
                                topTrailingRadius: 0
                            )
                        )
                        .offset(y: -66)
                        .padding(.bottom, -30)
                        
                        // MARK: - Login Form
                        VStack(spacing: 16) {
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: "64748B"))
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundStyle(Color(hex: "94A3B8"))
                                        .frame(width: 20)
                                    
                                    TextField(
                                        "you@university.edu",
                                        text: $viewModel.email
                                    )
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                }
                                .padding(14)
                                .background(Color(hex: "F8FAFC"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(hex: "E2E8F0"),
                                            lineWidth: 1.5
                                        )
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: "64748B"))
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundStyle(Color(hex: "94A3B8"))
                                        .frame(width: 20)
                                    
                                    if viewModel.isPasswordVisible {
                                        TextField(
                                            "Enter your password",
                                            text: $viewModel.password
                                        )
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                    } else {
                                        SecureField(
                                            "Enter your password",
                                            text: $viewModel.password
                                        )
                                    }
                                    
                                    Button {
    viewModel.isPasswordVisible.toggle()
                                    } label: {
                                        Image(
                                            systemName: viewModel.isPasswordVisible
                                            ? "eye.slash"
                                            : "eye"
                                        )
                                        .foregroundStyle(Color(hex: "94A3B8"))
                                    }
                                }
                                .padding(14)
                                .background(Color(hex: "F8FAFC"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(hex: "E2E8F0"),
                                            lineWidth: 1.5
                                        )
                                }
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
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button {
                                Task {
                                    await viewModel.login()
                                }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Log In")
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
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 14)
                                )
                            }
                            .disabled(
                                !viewModel.isFormValid || viewModel.isLoading
                            )
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    VStack(spacing: 20) {
                        
                        HStack {
                            Rectangle()
                                .fill(Color(hex: "E2E8F0"))
                                .frame(height: 1)
                            
                            Text("or")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "94A3B8"))
                                .padding(.horizontal, 12)
                            
                            Rectangle()
                                .fill(Color(hex: "E2E8F0"))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 24)
                        
                        Button {
                            showRegister = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundStyle(Color(hex: "64748B"))
                                
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "4F46E5"))
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.top, 32)
                }
            }
            .scrollIndicators(.hidden)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView()
        .environment(AuthManager.shared)
}

