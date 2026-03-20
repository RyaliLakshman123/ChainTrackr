//
//  SettingsView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 22/07/25.
//

import SwiftUI
import RevenueCat
import LocalAuthentication
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showPaywall = false
    @State private var showDeleteAlert = false
    @State private var showLogoutAlert = false
    @State private var notificationsEnabled = true
    @State private var faceIDEnabled = true
    @State private var darkModeEnabled = true
    @State private var selectedCurrency = "USD"
    @State private var autoRefresh = true
    @State private var hapticFeedback = true
    @State private var isPro = false
    @State private var biometricType: LABiometryType = .none
    // Add these at the top with your other @State properties
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showPasscodeSetup = false
    // Notifications
    @State private var showPriceAlerts = false
    @State private var showNotificationCenter = false
    
    // 🆕 NEW TOGGLE STATES
    @State private var appPasscodeEnabled = false
    @State private var privacyModeEnabled = false
    @State private var priceAlertsEnabled = true
    @State private var newsEnabled = true
    
    let currencies = ["USD", "EUR", "GBP", "JPY", "INR"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileSection
                        subscriptionSection
                        preferencesSection
                        securitySection
                        notificationSection
                        dataSection
                        supportSection
                        aboutSection
                        dangerZoneSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showPaywall) {
            MyPaywallView()
        }
        // Add these sheet modifiers to your body:
        .sheet(isPresented: $showNotificationCenter) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showPriceAlerts) {
            PriceAlertManagementView()
        }
        
        .sheet(isPresented: $showPasscodeSetup) {
            PasscodeSetupView(authManager: authManager)
                .onDisappear {
                    // Update the toggle state when setup is complete
                    appPasscodeEnabled = authManager.isPasscodeEnabled()
                }
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                handleAccountDeletion()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                handleSignOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            print("🔍 SettingsView appeared, checking systems...")
            debugInfoPlist()
            checkFaceIDConfiguration()
            // Add small delay to ensure everything is loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                checkSubscriptionStatus()
                checkBiometricAvailability()
                loadUserPreferences()
            }
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lakshman Ryali")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("adrenox2002@example.com")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    if isPro {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text("Pro Member")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    editProfile()
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(AppGradients.cardGradient)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Subscription")
            
            if isPro {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("ChainTrackr Pro")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("Active")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Next billing: Jan 15, 2025")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    }
                    
                    Button(action: {
                        manageSubscription()
                    }) {
                        Text("Manage Subscription")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(16)
                .background(AppGradients.cardGradient)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
            } else {
                Button(action: {
                    showPaywall = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upgrade to Pro")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Unlock premium features & AI insights")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                    }
                    .padding(16)
                    .background(AppGradients.primaryButton)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Demo toggle for testing
                Button(action: {
                    isPro.toggle()
                    triggerHapticFeedback(style: .light)
                }) {
                    Text("Demo: Toggle Pro Status")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.cyan)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Preferences")
            
            VStack(spacing: 0) {
                // Currency Selection
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Default Currency")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    
                    Menu {
                        ForEach(currencies, id: \.self) { currency in
                            Button(currency) {
                                selectedCurrency = currency
                                saveCurrencyPreference()
                                triggerHapticFeedback(style: .light)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedCurrency)
                                .foregroundColor(.white.opacity(0.7))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Auto Refresh
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.blue)
                    Text("Auto Refresh")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $autoRefresh)
                        .tint(.blue)
                        .onChange(of: autoRefresh) { newValue in
                            saveAutoRefreshPreference(enabled: newValue)
                            triggerHapticFeedback(style: .light)
                        }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Haptic Feedback
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(.purple)
                    Text("Haptic Feedback")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $hapticFeedback)
                        .tint(.purple)
                        .onChange(of: hapticFeedback) { newValue in
                            toggleHapticFeedback(enabled: newValue)
                        }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
// MARK: - Security Section (REAL FACE ID VERSION)
    private var securitySection: some View {
        VStack(spacing: 16) {
            sectionHeader("Security & Privacy")
            
            VStack(spacing: 0) {
                // Face ID / Touch ID - REAL VERSION
                HStack {
                    Image(systemName: biometricType == .faceID ? "faceid" :
                          biometricType == .touchID ? "touchid" : "lock.fill")
                        .foregroundColor(.cyan)
                    Text(biometricTypeText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $faceIDEnabled)
                        .tint(.cyan)
                        .onChange(of: faceIDEnabled) { newValue in
                            if newValue {
                                // Use real Face ID authentication
                                authenticateWithRealFaceID()
                            } else {
                                UserDefaults.standard.set(false, forKey: "biometric_enabled")
                                triggerHapticFeedback(style: .light)
                                print("❌ Face ID disabled")
                            }
                        }
                        .disabled(biometricType == .none)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                Divider().background(Color.white.opacity(0.1))
                
                // App Passcode Toggle
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.orange)
                    Text("App Passcode")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $appPasscodeEnabled)
                        .tint(.orange)
                        .onChange(of: appPasscodeEnabled) { newValue in
                            if newValue {
                                if !authManager.hasPasscodeSet() {
                                    // Show passcode setup
                                    showPasscodeSetup = true
                                } else {
                                    // Enable existing passcode
                                    UserDefaults.standard.set(true, forKey: "app_passcode_enabled")
                                    triggerHapticFeedback(style: .success)
                                    print("✅ App passcode enabled")
                                }
                            } else {
                                // Disable passcode
                                UserDefaults.standard.set(false, forKey: "app_passcode_enabled")
                                triggerHapticFeedback(style: .light)
                                print("❌ App passcode disabled")
                            }
                        }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                
                Divider().background(Color.white.opacity(0.1))
                
                // Privacy Mode Toggle
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.red)
                    Text("Privacy Mode")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $privacyModeEnabled)
                        .tint(.red)
                        .onChange(of: privacyModeEnabled) { newValue in
                            togglePrivacyMode(enabled: newValue)
                        }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
//                // Test Button
//                Button("Test Face ID Info.plist") {
//                    testFaceIDSetup()
//                }
//                .foregroundColor(.yellow)
                // .padding()
                
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }

    // Add this new function for real Face ID
    private func authenticateWithRealFaceID() {
        let context = LAContext()
        context.localizedFallbackTitle = "" // Remove passcode fallback
        
        let reason = "Use Face ID to enable secure authentication for ChainTrackr"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    UserDefaults.standard.set(true, forKey: "biometric_enabled")
                    self.triggerHapticFeedback(style: .success)
                    print("✅ Face ID authentication successful!")
                } else {
                    self.faceIDEnabled = false
                    self.triggerHapticFeedback(style: .error)
                    if let error = error {
                        print("❌ Face ID failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    

    // MARK: - Notifications Section
    private var notificationSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Notifications")
            
            VStack(spacing: 0) {
                // Push Notifications (Master Toggle)
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.yellow)
                    Text("Push Notifications")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(.yellow)
                        .onChange(of: notificationsEnabled) { newValue in
                            toggleNotifications(enabled: newValue)
                        }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Enhanced Notification Center
                Button(action: {
                    showNotificationCenter = true
                }) {
                    HStack {
                        Image(systemName: "bell.badge.waveform.fill")
                            .foregroundColor(.cyan)
                        Text("Notification Center")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.6)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Price Alerts Toggle
                HStack {
                    Image(systemName: "alarm.fill")
                        .foregroundColor(.red)
                    Text("Price Alerts")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $priceAlertsEnabled)
                        .tint(.red)
                        .onChange(of: priceAlertsEnabled) { newValue in
                            togglePriceAlerts(enabled: newValue)
                        }
                        .disabled(!notificationsEnabled)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .opacity(notificationsEnabled ? 1.0 : 0.6)
                
                Divider().background(Color.white.opacity(0.1))
                
                // News Notifications Toggle
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundColor(.blue)
                    Text("News Notifications")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $newsEnabled)
                        .tint(.blue)
                        .onChange(of: newsEnabled) { newValue in
                            toggleNewsNotifications(enabled: newValue)
                        }
                        .disabled(!notificationsEnabled)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .opacity(notificationsEnabled ? 1.0 : 0.6)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Manage Price Alerts
                Button(action: {
                    showPriceAlerts = true
                }) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.orange)
                        Text("Manage Price Alerts")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.6)
                
                // 🧪 NOTIFICATION TEST SECTION
                Divider().background(Color.white.opacity(0.1))
                
                VStack(spacing: 0) {
                    // Test Section Header
                    HStack {
                        Image(systemName: "testtube.2")
                            .foregroundColor(.cyan)
                        Text("Notification Testing")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.cyan)
                        Spacer()
                        Text("Debug")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.cyan.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // Force Test Button - Highest Priority
                    Button(action: {
                        EnhancedNotificationManager.shared.sendForceTestNotification()
                        triggerHapticFeedback(style: .heavy)
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.red)
                            Text("🚨 FORCE TEST NOTIFICATION")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)
                            Spacer()
                            Text("IMMEDIATE")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(3)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Full Test Suite Button
                    Button(action: {
                        Task {
                            await EnhancedNotificationManager.shared.sendImmediateTestSuite()
                        }
                        triggerHapticFeedback(style: .heavy)
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.purple)
                            Text("🧪 RUN FULL TEST SUITE")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.purple)
                            Spacer()
                            Text("4 TESTS")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.purple.opacity(0.8))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(3)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.purple.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Utility Buttons Row
                    HStack(spacing: 12) {
                        // Clear All Button
                        Button(action: {
                            EnhancedNotificationManager.shared.clearAllNotifications()
                            triggerHapticFeedback(style: .light)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                Text("CLEAR")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .cornerRadius(6)
                        .buttonStyle(PlainButtonStyle())
                        
                        // Reset Permissions Button
                        Button(action: {
                            Task {
                                await EnhancedNotificationManager.shared.resetNotificationPermissions()
                            }
                            triggerHapticFeedback(style: .light)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                Text("RESET")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .cornerRadius(6)
                        .buttonStyle(PlainButtonStyle())
                        
                        // Check Status Button
                        Button(action: {
                            Task {
                                await EnhancedNotificationManager.shared.checkNotificationStatus()
                            }
                            triggerHapticFeedback(style: .light)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                                Text("STATUS")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .cornerRadius(6)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    // Test Instructions
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text("Test Instructions:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("1.")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("Try FORCE TEST first - if this works, notifications are functional")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                            
                            HStack {
                                Text("2.")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("If no notifications appear, check Focus/Do Not Disturb mode")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                            
                            HStack {
                                Text("3.")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("Check console logs with STATUS button for detailed diagnostics")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }

    // MARK: - Data Section
    private var dataSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Data & Storage")
            
            VStack(spacing: 0) {
                Button(action: {
                    exportUserData()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                            .foregroundColor(.blue)
                        Text("Export Data")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider().background(Color.white.opacity(0.1))
                
                Button(action: {
                    clearAppCache()
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.orange)
                        Text("Clear Cache")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Text("45.2 MB")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Support & Feedback")
            
            VStack(spacing: 0) {
                Button(action: {
                    openHelpCenter()
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Help Center")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider().background(Color.white.opacity(0.1))
                
                Button(action: {
                    contactSupport()
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.blue)
                        Text("Contact Support")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider().background(Color.white.opacity(0.1))
                
                Button(action: {
                    rateApp()
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Rate ChainTrackr")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 16) {
            sectionHeader("About")
            
            VStack(spacing: 0) {
                Button(action: {
                    openTermsOfService()
                }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                        Text("Terms of Service")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider().background(Color.white.opacity(0.1))
                
                Button(action: {
                    openPrivacyPolicy()
                }) {
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.blue)
                        Text("Privacy Policy")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.gray)
                    Text("Version")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Text("1.0.0 (Build 1)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Danger Zone
    private var dangerZoneSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Account")
            
            VStack(spacing: 0) {
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .foregroundColor(.orange)
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider().background(Color.white.opacity(0.1))
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Delete Account")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
    }
    
    private var biometricTypeText: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                return "Secure Authentication"
            } else {
                return "Authentication Unavailable"
            }
        @unknown default:
            return "Biometric Auth"
        }
    }
    
    // MARK: - Initialization Functions
    private func checkSubscriptionStatus() {
        print("🔍 Checking subscription status...")
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print("❌ Device authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            biometricType = .none
            faceIDEnabled = false
            return
        }
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
            faceIDEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
            print("✅ Biometric type available: \(biometricType)")
        } else {
            biometricType = .none
            faceIDEnabled = false
            print("ℹ️ Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    private func loadUserPreferences() {
        if UserDefaults.standard.object(forKey: "biometric_enabled") != nil {
            faceIDEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
        } else {
            faceIDEnabled = false
        }
        
        if UserDefaults.standard.object(forKey: "haptic_feedback_enabled") != nil {
            hapticFeedback = UserDefaults.standard.bool(forKey: "haptic_feedback_enabled")
        } else {
            hapticFeedback = true
        }
        
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        autoRefresh = UserDefaults.standard.bool(forKey: "auto_refresh_enabled")
        selectedCurrency = UserDefaults.standard.string(forKey: "selected_currency") ?? "USD"
        isPro = UserDefaults.standard.bool(forKey: "is_pro_demo")
        
        appPasscodeEnabled = UserDefaults.standard.bool(forKey: "app_passcode_enabled")
        privacyModeEnabled = UserDefaults.standard.bool(forKey: "privacy_mode_enabled")
        priceAlertsEnabled = UserDefaults.standard.bool(forKey: "price_alerts_enabled")
        newsEnabled = UserDefaults.standard.bool(forKey: "news_notifications_enabled")
        
        print("📱 Loaded preferences - Face ID: \(faceIDEnabled), Haptic: \(hapticFeedback)")
    }
    
    // MARK: - Test Function
    private func testFaceIDSetup() {
        print("🧪 Testing Face ID setup...")
        
        if let value = Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription") as? String {
            print("✅ Face ID description found: \(value)")
            
            let context = LAContext()
            print("✅ LAContext created: \(context.biometryType.rawValue)")
            
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                print("✅ Can evaluate biometric policy")
            } else {
                print("❌ Cannot evaluate policy: \(error?.localizedDescription ?? "Unknown")")
            }
        } else {
            print("❌ Face ID description NOT found")
        }
    }
    
    // MARK: - Toggle Functions
    private func togglePrivacyMode(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "privacy_mode_enabled")
        triggerHapticFeedback(style: .light)
        
        if enabled {
            print("✅ Privacy mode enabled")
        } else {
            print("❌ Privacy mode disabled")
        }
    }
    
    private func toggleHapticFeedback(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "haptic_feedback_enabled")
        
        if enabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            print("✅ Haptic feedback enabled")
        } else {
            print("❌ Haptic feedback disabled")
        }
    }
    
    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard UserDefaults.standard.bool(forKey: "haptic_feedback_enabled") else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    private func toggleNotifications(enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        } else {
            UserDefaults.standard.set(false, forKey: "notifications_enabled")
            priceAlertsEnabled = false
            newsEnabled = false
            UserDefaults.standard.set(false, forKey: "price_alerts_enabled")
                        UserDefaults.standard.set(false, forKey: "news_notifications_enabled")
                        triggerHapticFeedback(style: .light)
                        print("❌ All notifications disabled")
                    }
                }
                
                private func requestNotificationPermission() {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        DispatchQueue.main.async {
                            if granted {
                                UserDefaults.standard.set(true, forKey: "notifications_enabled")
                                self.triggerHapticFeedback(style: .success)
                                print("✅ Notifications enabled")
                            } else {
                                self.notificationsEnabled = false
                                self.triggerHapticFeedback(style: .error)
                                print("❌ Notification permission denied")
                            }
                        }
                    }
                }
                
                private func togglePriceAlerts(enabled: Bool) {
                    guard notificationsEnabled else {
                        priceAlertsEnabled = false
                        return
                    }
                    
                    UserDefaults.standard.set(enabled, forKey: "price_alerts_enabled")
                    triggerHapticFeedback(style: .light)
                    
                    if enabled {
                        print("✅ Price alerts enabled")
                    } else {
                        print("❌ Price alerts disabled")
                    }
                }
                
                private func toggleNewsNotifications(enabled: Bool) {
                    guard notificationsEnabled else {
                        newsEnabled = false
                        return
                    }
                    
                    UserDefaults.standard.set(enabled, forKey: "news_notifications_enabled")
                    triggerHapticFeedback(style: .light)
                    
                    if enabled {
                        print("✅ News notifications enabled")
                    } else {
                        print("❌ News notifications disabled")
                    }
                }
                
                private func saveCurrencyPreference() {
                    UserDefaults.standard.set(selectedCurrency, forKey: "selected_currency")
                    print("💱 Currency changed to: \(selectedCurrency)")
                }
                
                private func saveAutoRefreshPreference(enabled: Bool) {
                    UserDefaults.standard.set(enabled, forKey: "auto_refresh_enabled")
                    print("🔄 Auto refresh: \(enabled ? "enabled" : "disabled")")
                }
                
                private func editProfile() {
                    triggerHapticFeedback(style: .light)
                    print("✏️ Edit profile tapped")
                }
                
                private func manageSubscription() {
                    triggerHapticFeedback(style: .light)
                    print("👑 Manage subscription tapped")
                }
                
                private func exportUserData() {
                    triggerHapticFeedback(style: .medium)
                    print("📤 Export data tapped")
                }
                
                private func clearAppCache() {
                    triggerHapticFeedback(style: .medium)
                    print("🗑️ Clear cache tapped")
                }
                
                private func openHelpCenter() {
                    triggerHapticFeedback(style: .light)
                    print("❓ Help center tapped")
                    if let url = URL(string: "https://chaintrackr.com/help") {
                        UIApplication.shared.open(url)
                    }
                }
                
                private func contactSupport() {
                    triggerHapticFeedback(style: .light)
                    print("💬 Contact support tapped")
                    if let url = URL(string: "mailto:support@chaintrackr.com?subject=ChainTrackr Support&body=Hi ChainTrackr team,") {
                        UIApplication.shared.open(url)
                    }
                }
                
                private func rateApp() {
                    triggerHapticFeedback(style: .light)
                    print("⭐ Rate app tapped")
                    if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                }
                
                private func openTermsOfService() {
                    triggerHapticFeedback(style: .light)
                    print("📄 Terms of service tapped")
                    if let url = URL(string: "https://chaintrackr.com/terms") {
                        UIApplication.shared.open(url)
                    }
                }
                
                private func openPrivacyPolicy() {
                    triggerHapticFeedback(style: .light)
                    print("🛡️ Privacy policy tapped")
                    if let url = URL(string: "https://chaintrackr.com/privacy") {
                        UIApplication.shared.open(url)
                    }
                }
                
            private func handleSignOut() {
                    triggerHapticFeedback(style: .warning)
                    print("🚪 User signed out")
                    
                    // Clear authentication settings
                    UserDefaults.standard.removeObject(forKey: "biometric_enabled")
                    UserDefaults.standard.removeObject(forKey: "app_passcode_enabled")
                    UserDefaults.standard.removeObject(forKey: "app_passcode") // Also clear the passcode itself
                    UserDefaults.standard.removeObject(forKey: "privacy_mode_enabled")
                    UserDefaults.standard.removeObject(forKey: "price_alerts_enabled")
                    UserDefaults.standard.removeObject(forKey: "news_notifications_enabled")
                    UserDefaults.standard.removeObject(forKey: "is_pro_demo")
                    
                    // Reset authentication manager
                    authManager.lockApp()
                    
                    // Reset local state
                    isPro = false
                    appPasscodeEnabled = false
                    privacyModeEnabled = false
                    priceAlertsEnabled = false
                    newsEnabled = false
                    faceIDEnabled = false
                    
                    print("✅ User data cleared")
                }
                
                private func handleAccountDeletion() {
                    triggerHapticFeedback(style: .error)
                    print("🗑️ Account deletion requested")
                    print("⚠️ Account deletion process initiated")
                }
                
                private func debugInfoPlist() {
                    print("🔍 Debugging Info.plist contents:")
                    
                    if let value = Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription") as? String {
                        print("✅ NSFaceIDUsageDescription: \(value)")
                    } else {
                        print("❌ NSFaceIDUsageDescription: NOT FOUND")
                    }
                    
                    if let value = Bundle.main.object(forInfoDictionaryKey: "NSUserNotificationsUsageDescription") as? String {
                        print("✅ NSUserNotificationsUsageDescription: \(value)")
                    }
                    
                    do {
                        let context = LAContext()
                        print("✅ LAContext created successfully")
                        print("📱 Biometry type: \(context.biometryType.rawValue)")
                        
                        var error: NSError?
                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                            print("✅ Can evaluate biometric policy")
                        } else {
                            print("❌ Cannot evaluate biometric policy: \(error?.localizedDescription ?? "Unknown")")
                        }
                    } catch {
                        print("❌ Failed to create LAContext: \(error)")
                    }
                }
                
                private func checkFaceIDConfiguration() {
                    let context = LAContext()
                    var error: NSError?
                    
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        print("✅ Biometric authentication available")
                        print("📱 Biometry type: \(context.biometryType)")
                        
                        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                            print("✅ Device owner authentication available")
                        }
                    } else {
                        print("❌ Biometric authentication not available: \(error?.localizedDescription ?? "Unknown")")
                    }
                }
            }

            #Preview {
                SettingsView()
                    .environmentObject(PurchaseManager())
                    .environmentObject(AuthenticationManager())
            }

            // MARK: - Extensions
            extension UIImpactFeedbackGenerator.FeedbackStyle {
                static let success = UIImpactFeedbackGenerator.FeedbackStyle.heavy
                static let warning = UIImpactFeedbackGenerator.FeedbackStyle.medium
                static let error = UIImpactFeedbackGenerator.FeedbackStyle.heavy
            }

            extension SettingsView {
                static func isSettingEnabled(key: String) -> Bool {
                    return UserDefaults.standard.bool(forKey: key)
                }
                
                static func getCurrentCurrency() -> String {
                    return UserDefaults.standard.string(forKey: "selected_currency") ?? "USD"
                }
                
                static func triggerGlobalHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
                    guard UserDefaults.standard.bool(forKey: "haptic_feedback_enabled") else { return }
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: style)
                    impactFeedback.impactOccurred()
                }
            }
