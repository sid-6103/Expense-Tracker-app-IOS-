//
//  AppLockView.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import SwiftUI

struct AppLockView: View {
    @ObservedObject var securityManager: SecurityManager
    @State private var enteredPIN = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primary)
                    
                    Text("App Locked")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if securityManager.usePIN {
                        Text("Enter PIN to unlock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if securityManager.useFaceID {
                        Text("Authenticate to unlock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 60)
                
                // PIN Display (only show if PIN is enabled)
                if securityManager.usePIN {
                    HStack(spacing: 20) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(enteredPIN.count > index ? Color.primary : Color.secondary.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .animation(.easeInOut(duration: 0.2), value: enteredPIN.count)
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
                
                // PIN Keypad (only show if PIN is enabled)
                if securityManager.usePIN {
                    VStack(spacing: 20) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 20) {
                                ForEach(1..<4) { col in
                                    let number = row * 3 + col
                                    PINButton(number: "\(number)") {
                                        buttonTapped("\(number)")
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 20) {
                            // Empty space
                            Color.clear
                                .frame(width: 80, height: 80)
                            
                            // 0 Button
                            PINButton(number: "0") {
                                buttonTapped("0")
                            }
                            
                            // Delete Button
                            Button(action: deleteTapped) {
                                Image(systemName: "delete.left.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                                    .frame(width: 80, height: 80)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // Face ID Button (if available and enabled)
                if securityManager.isBiometricAvailable && securityManager.useFaceID {
                    Button(action: authenticateWithFaceID) {
                        HStack(spacing: 8) {
                            Image(systemName: "faceid")
                                .font(.title2)
                            Text("Unlock with Face ID")
                        }
                        .foregroundColor(.blue)
                        .padding()
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
    }
    
    private func buttonTapped(_ number: String) {
        HapticFeedback.light()
        
        if enteredPIN.count < 4 {
            enteredPIN += number
            
            if enteredPIN.count == 4 {
                checkPIN()
            }
        }
    }
    
    private func deleteTapped() {
        HapticFeedback.light()
        
        if !enteredPIN.isEmpty {
            enteredPIN.removeLast()
            showError = false
        }
    }
    
    private func checkPIN() {
        if securityManager.authenticateWithPIN(enteredPIN) {
            HapticFeedback.success()
            enteredPIN = ""
        } else {
            HapticFeedback.error()
            showError = true
            errorMessage = "Incorrect PIN. Try again."
            enteredPIN = ""
            
            // Clear error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showError = false
            }
        }
    }
    
    private func authenticateWithFaceID() {
        securityManager.authenticateWithFaceID { success, error in
            if !success {
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - PIN Button
struct PINButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 80, height: 80)
                .background(Color(.systemGray6))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AppLockView(securityManager: SecurityManager())
}
