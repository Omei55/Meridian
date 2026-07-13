//
//  RegisterView.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 12/06/26.
//

import SwiftUI
import FirebaseCore

struct RegisterView: View {

    @State private var viewModel = RegisterViewModel()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea(edges: .top)

                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 180, height: 180)
                            .offset(x: -80, y: -40)

                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 130, height: 130)
                            .offset(x: 100, y: 40)

                        VStack(spacing: 8) {
                            Text("Create Account")
                                .padding(.top , 60)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Join Meridian today")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.75))
                        }
                        .padding(.vertical, 50)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 32,
                            bottomTrailingRadius: 32,
                            topTrailingRadius: 0
                        )
                    )
                    .padding(.bottom, 32)

                    VStack(spacing: 16) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            HStack {
                                Image(systemName: "person")
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .frame(width: 20)

                                TextField("Your full name", text: $viewModel.fullName)
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

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .frame(width: 20)

                                TextField("you@university.edu", text: $viewModel.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
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
                                        "Min. 6 characters",
                                        text: $viewModel.password
                                    )
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                } else {
                                    SecureField(
                                        "Min. 6 characters",
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
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "E2E8F0"), lineWidth: 1.5)
                            )
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                    .frame(width: 20)

                                if viewModel.isConfirmPasswordVisible {
                                    TextField(
                                        "Re-enter password",
                                        text: $viewModel.confirmPassword
                                    )
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                } else {
                                    SecureField(
                                        "Re-enter password",
                                        text: $viewModel.confirmPassword
                                    )
                                }

                                Button {
                                    viewModel.isConfirmPasswordVisible.toggle()
                                } label: {
                                    Image(
                                        systemName: viewModel.isConfirmPasswordVisible
                                        ? "eye.slash"
                                        : "eye"
                                    )
                                    .foregroundStyle(Color(hex: "94A3B8"))
                                }
                            }
                            .padding(14)
                            .background(Color(hex: "F8FAFC"))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        !viewModel.confirmPassword.isEmpty &&
                                        !viewModel.passwordsMatch
                                        ? Color.red.opacity(0.6)
                                        : Color(hex: "E2E8F0"),
                                        lineWidth: 1.5
                                    )
                            )

                            if !viewModel.confirmPassword.isEmpty &&
                                !viewModel.passwordsMatch {
                                Text("Passwords don't match")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("I am a...")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "64748B"))

                            HStack(spacing: 12) {
                                ForEach(UserRole.allCases, id: \.self) { role in
                                    Button {
                                        viewModel.selectedRole = role
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: role.icon)
                                                .font(.system(size: 14))

                                            Text(role.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(
                                            viewModel.selectedRole == role
                                            ? Color(hex: "4F46E5")
                                            : Color(hex: "F8FAFC")
                                        )
                                        .foregroundStyle(
                                            viewModel.selectedRole == role
                                            ? .white
                                            : Color(hex: "64748B")
                                        )
                                        .clipShape(.rect(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    viewModel.selectedRole == role
                                                    ? Color.clear
                                                    : Color(hex: "E2E8F0"),
                                                    lineWidth: 1.5
                                                )
                                        )
                                    }
                                }
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
                            .clipShape(.rect(cornerRadius: 10))
                        }

                        Button {
                            Task {
                                await viewModel.register()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
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
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.top, 8)

                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .foregroundStyle(Color(hex: "64748B"))

                                Text("Log In")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "4F46E5"))
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color(hex: "4F46E5"))
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environment(AuthManager.shared)
}
