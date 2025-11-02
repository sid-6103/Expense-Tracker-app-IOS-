//
//  PINSetupView.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import SwiftUI

struct PINSetupView: View {
    @ObservedObject var securityManager: SecurityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var step: SetupStep = .enter
    @State private var firstPIN = ""
    @State private var secondPIN = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum SetupStep {
        case enter
        case confirm
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(step == .enter ? "Create 4-Digit PIN" : "Confirm PIN")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(step == .enter ? "Enter a 4-digit PIN to secure your app" : "Re-enter your PIN to confirm")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // PIN Display
                HStack(spacing: 20) {
                    let currentPIN = step == .enter ? firstPIN : secondPIN
                    
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(currentPIN.count > index ? Color.blue : Color.secondary.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .animation(.easeInOut(duration: 0.2), value: currentPIN.count)
                    }
                }
                .padding(.vertical, 30)
                
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
                
                // PIN Keypad
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
                
                Spacer()
            }
            .navigationTitle("Setup PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func buttonTapped(_ number: String) {
        HapticFeedback.light()
        
        if step == .enter {
            if firstPIN.count < 4 {
                firstPIN += number
                
                if firstPIN.count == 4 {
                    withAnimation {
                        step = .confirm
                    }
                }
            }
        } else {
            if secondPIN.count < 4 {
                secondPIN += number
                
                if secondPIN.count == 4 {
                    checkPinsMatch()
                }
            }
        }
    }
    
    private func deleteTapped() {
        HapticFeedback.light()
        
        if step == .enter {
            if !firstPIN.isEmpty {
                firstPIN.removeLast()
                showError = false
            }
        } else {
            if !secondPIN.isEmpty {
                secondPIN.removeLast()
                showError = false
            }
        }
    }
    
    private func checkPinsMatch() {
        if firstPIN == secondPIN {
            // Save PIN
            securityManager.passcode = firstPIN
            securityManager.saveSettings()
            
            HapticFeedback.success()
            dismiss()
        } else {
            HapticFeedback.error()
            showError = true
            errorMessage = "PINs don't match. Try again."
            
            // Reset confirmation PIN
            secondPIN = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showError = false
            }
        }
    }
}

#Preview {
    PINSetupView(securityManager: SecurityManager())
}
