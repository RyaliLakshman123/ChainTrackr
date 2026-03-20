//
//  PasscodeSetupView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import SwiftUI

struct PasscodeSetupView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var enteredPasscode = ""
    @State private var confirmPasscode = ""
    @State private var isConfirming = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text(isConfirming ? "Confirm Passcode" : "Set Passcode")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(isConfirming ? "Enter your passcode again" : "Create a 4-digit passcode to secure ChainTrackr")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Passcode dots
                    HStack(spacing: 20) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < currentPasscode.count ? Color.orange : Color.white.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .scaleEffect(index < currentPasscode.count ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPasscode.count)
                        }
                    }
                    
                    // Number pad
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(1...9, id: \.self) { number in
                            PasscodeButton(number: "\(number)") {
                                addDigit("\(number)")
                            }
                        }
                        
                        // Empty space
                        Color.clear
                            .frame(height: 80)
                        
                        PasscodeButton(number: "0") {
                            addDigit("0")
                        }
                        
                        Button(action: deleteDigit) {
                            Image(systemName: "delete.left.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(height: 80)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                if isConfirming {
                    // Reset to first step
                    enteredPasscode = ""
                    confirmPasscode = ""
                    isConfirming = false
                }
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var currentPasscode: String {
        isConfirming ? confirmPasscode : enteredPasscode
    }
    
    private func addDigit(_ digit: String) {
        if isConfirming {
            if confirmPasscode.count < 4 {
                confirmPasscode += digit
                triggerHaptic()
                
                if confirmPasscode.count == 4 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        validatePasscodes()
                    }
                }
            }
        } else {
            if enteredPasscode.count < 4 {
                enteredPasscode += digit
                triggerHaptic()
                
                if enteredPasscode.count == 4 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isConfirming = true
                    }
                }
            }
        }
    }
    
    private func deleteDigit() {
        triggerHaptic()
        
        if isConfirming {
            if !confirmPasscode.isEmpty {
                confirmPasscode.removeLast()
            }
        } else {
            if !enteredPasscode.isEmpty {
                enteredPasscode.removeLast()
            }
        }
    }
    
    private func validatePasscodes() {
        if enteredPasscode == confirmPasscode {
            authManager.setPasscode(enteredPasscode)
            triggerSuccessHaptic()
            dismiss()
        } else {
            errorMessage = "Passcodes don't match. Please try again."
            showError = true
            triggerErrorHaptic()
        }
    }
    
    private func triggerHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    private func triggerErrorHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred()
        }
    }
}

struct PasscodeButton: View {
    let number: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            Text(number)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(isPressed ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2), value: isPressed)
    }
}

#Preview {
    PasscodeSetupView(authManager: AuthenticationManager())
}
