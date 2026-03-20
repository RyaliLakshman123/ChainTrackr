//
//  AppUnlockView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import SwiftUI
import LocalAuthentication

struct AppUnlockView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var enteredPasscode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var biometricType: LABiometryType = .none
    
    var body: some View {
        ZStack {
            AppGradients.mainBackground
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // App Logo and Title
                VStack(spacing: 20) {
                    // Replace with your app icon
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("ChainTrackr")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Enter your passcode to continue")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Passcode dots (only show if passcode entry is active)
                if authManager.showPasscodeEntry {
                    HStack(spacing: 20) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < enteredPasscode.count ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .scaleEffect(index < enteredPasscode.count ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: enteredPasscode.count)
                        }
                    }
                    
                    // Number pad
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(1...9, id: \.self) { number in
                            PasscodeButton(number: "\(number)") {
                                addDigit("\(number)")
                            }
                        }
                        
                        // Face ID button (if Face ID is available)
                        Button(action: {
                            authManager.attemptBiometricAuth()
                        }) {
                            Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(height: 80)
                        .opacity(biometricType != .none ? 1.0 : 0.0)
                        
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
                } else {
                    // Show loading or Face ID prompt
                    VStack(spacing: 20) {
                        Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 60))
                            .foregroundColor(.cyan)
                        
                        Text("Authenticating...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button("Use Passcode Instead") {
                            authManager.showPasscodeEntry = true
                        }
                        .foregroundColor(.cyan)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            checkBiometricType()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkBiometricType() {
        let context = LAContext()
        biometricType = context.biometryType
    }
    
    private func addDigit(_ digit: String) {
        if enteredPasscode.count < 4 {
            enteredPasscode += digit
            triggerHaptic()
            
            if enteredPasscode.count == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    verifyPasscode()
                }
            }
        }
    }
    
    private func deleteDigit() {
        if !enteredPasscode.isEmpty {
            enteredPasscode.removeLast()
            triggerHaptic()
        }
    }
    
    private func verifyPasscode() {
        if authManager.verifyPasscode(enteredPasscode) {
            // Success - handled in AuthenticationManager
            triggerSuccessHaptic()
        } else {
            errorMessage = "Incorrect passcode. Please try again."
            showError = true
            enteredPasscode = ""
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

#Preview {
    AppUnlockView(authManager: AuthenticationManager())
}
