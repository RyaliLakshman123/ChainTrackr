//
//  AuthenticationManager.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import SwiftUI
import LocalAuthentication

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showPasscodeSetup = false
    @Published var showPasscodeEntry = false
    @Published var showAuthenticationScreen = false
    
    private let passcodeKey = "app_passcode"
    private let biometricEnabledKey = "biometric_enabled"
    private let passcodeEnabledKey = "app_passcode_enabled"
    
    init() {
        // Don't auto-check on init, let the app control when to authenticate
    }
    
    func checkAuthenticationNeeded() {
        let biometricEnabled = UserDefaults.standard.bool(forKey: biometricEnabledKey)
        let passcodeEnabled = UserDefaults.standard.bool(forKey: passcodeEnabledKey)
        
        if biometricEnabled || passcodeEnabled {
            print("🔐 Authentication required - Face ID: \(biometricEnabled), Passcode: \(passcodeEnabled)")
            isAuthenticated = false
            showAuthenticationScreen = true
            
            // Try Face ID first if enabled
            if biometricEnabled {
                attemptBiometricAuth()
            } else {
                showPasscodeEntry = true
            }
        } else {
            print("✅ No authentication required")
            isAuthenticated = true
            showAuthenticationScreen = false
        }
    }
    
    func attemptBiometricAuth() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
              UserDefaults.standard.bool(forKey: biometricEnabledKey) else {
            print("❌ Face ID not available, showing passcode")
            showPasscodeEntry = true
            return
        }
        
        print("🔍 Attempting Face ID authentication...")
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                              localizedReason: "Unlock ChainTrackr with Face ID") { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Face ID authentication successful!")
                    self?.isAuthenticated = true
                    self?.showPasscodeEntry = false
                    self?.showAuthenticationScreen = false
                } else {
                    print("❌ Face ID failed, showing passcode fallback")
                    // Show passcode as fallback
                    self?.showPasscodeEntry = true
                }
            }
        }
    }
    
    func hasPasscodeSet() -> Bool {
        return UserDefaults.standard.string(forKey: passcodeKey) != nil
    }
    
    func setPasscode(_ passcode: String) {
        UserDefaults.standard.set(passcode, forKey: passcodeKey)
        UserDefaults.standard.set(true, forKey: passcodeEnabledKey)
        print("✅ Passcode set successfully")
    }
    
    func verifyPasscode(_ enteredPasscode: String) -> Bool {
        let storedPasscode = UserDefaults.standard.string(forKey: passcodeKey)
        if enteredPasscode == storedPasscode {
            isAuthenticated = true
            showPasscodeEntry = false
            showAuthenticationScreen = false
            print("✅ Passcode authentication successful!")
            return true
        }
        print("❌ Incorrect passcode")
        return false
    }
    
    func removePasscode() {
        UserDefaults.standard.removeObject(forKey: passcodeKey)
        UserDefaults.standard.set(false, forKey: passcodeEnabledKey)
        print("❌ Passcode removed")
    }
    
    func isPasscodeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: passcodeEnabledKey) && hasPasscodeSet()
    }
    
    func lockApp() {
        isAuthenticated = false
        showAuthenticationScreen = false
        showPasscodeEntry = false
    }
}
