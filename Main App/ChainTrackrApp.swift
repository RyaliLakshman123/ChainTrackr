//
//  ChainTrackrApp.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI
import RevenueCat
import BackgroundTasks
import UserNotifications

@main
struct ChainTrackrApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var purchaseManager = PurchaseManager()
    
    init() {
        // Configure RevenueCat with your API key
        Purchases.logLevel = .debug // Remove this in production
        Purchases.configure(withAPIKey: "")
        
        // Optional: Set user ID if you have one
        Purchases.shared.logIn("user_id") { (customerInfo, created, error) in }
        
        // CRITICAL: Setup notification delegate immediately
        setupNotifications()
        
        // Register background tasks
        registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    // Your main app content
                    ContentView()
                        .environmentObject(purchaseManager)
                        .environmentObject(authManager)
                } else if authManager.showAuthenticationScreen {
                    // Show authentication screen
                    AppUnlockView(authManager: authManager)
                } else {
                    // App loading state
                    ZStack {
                        AppGradients.mainBackground
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text("ChainTrackr")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
            }
            .onAppear {
                // Check authentication when app appears
                authManager.checkAuthenticationNeeded()
                
                // Force check notification settings on app appear
                Task {
                    await EnhancedNotificationManager.shared.checkNotificationStatus()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Re-authenticate when app comes back from background
                if authManager.isAuthenticated {
                    authManager.checkAuthenticationNeeded()
                }
                
                // Check for pending notifications when app becomes active
                Task {
                    await EnhancedNotificationManager.shared.checkNotificationStatus()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                // Schedule background app refresh
                scheduleBackgroundAppRefresh()
            }
        }
    }
}

// MARK: - Notification Setup
private func setupNotifications() {
    print("🚀 Setting up notifications in App delegate...")
    
    // This is CRITICAL - must be set immediately in app launch
    UNUserNotificationCenter.current().delegate = EnhancedNotificationManager.shared
    
    // Request permissions immediately
    let options: UNAuthorizationOptions = [.alert, .sound, .badge, .criticalAlert, .carPlay]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
        DispatchQueue.main.async {
            if granted {
                print("✅ App-level notification permission granted")
            } else {
                print("❌ App-level notification permission denied: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }
}

// MARK: - Background Task Registration
private func registerBackgroundTasks() {
    // Register main notification task
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.chaintrackr.notifications",
        using: nil
    ) { task in
        handleBackgroundNotifications(task: task as! BGAppRefreshTask)
    }
    
    // Register background refresh task
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.chaintrackr.background-refresh",
        using: nil
    ) { task in
        handleBackgroundRefresh(task: task as! BGAppRefreshTask)
    }
}

// MARK: - Background Task Handlers
func handleBackgroundNotifications(task: BGAppRefreshTask) {
    print("🔄 Background notification task started")
    
    task.expirationHandler = {
        print("⏰ Background notification task expired")
        task.setTaskCompleted(success: false)
    }
    
    Task {
        do {
            // Only fetch news notifications in background to avoid API rate limits
            await EnhancedNotificationManager.shared.fetchAndScheduleNewsNotifications()
            
            // Send a market summary if it's the right time
            let hour = Calendar.current.component(.hour, from: Date())
            if hour == 9 || hour == 18 {
                await EnhancedNotificationManager.shared.sendMarketSummaryNotification()
            }
            
            // Schedule next background refresh
            scheduleBackgroundAppRefresh()
            
            print("✅ Background notification task completed successfully")
            task.setTaskCompleted(success: true)
            
        } catch {
            print("❌ Background notification task failed: \(error)")
            task.setTaskCompleted(success: false)
        }
    }
}

func handleBackgroundRefresh(task: BGAppRefreshTask) {
    print("🔄 Background refresh task started")
    
    task.expirationHandler = {
        print("⏰ Background refresh task expired")
        task.setTaskCompleted(success: false)
    }
    
    Task {
        // Force a notification test to keep the system alive
        EnhancedNotificationManager.shared.sendForceTestNotification()
        
        // Check for major price movements
        await EnhancedNotificationManager.shared.checkForMajorPriceMovements()
        
        print("✅ Background refresh task completed")
        task.setTaskCompleted(success: true)
    }
}

func scheduleBackgroundAppRefresh() {
    // Schedule notification task
    let notificationRequest = BGAppRefreshTaskRequest(identifier: "com.chaintrackr.notifications")
    notificationRequest.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
    
    // Schedule refresh task
    let refreshRequest = BGAppRefreshTaskRequest(identifier: "com.chaintrackr.background-refresh")
    refreshRequest.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // 30 minutes
    
    do {
        try BGTaskScheduler.shared.submit(notificationRequest)
        try BGTaskScheduler.shared.submit(refreshRequest)
        print("📅 Background tasks scheduled successfully")
    } catch {
        print("❌ Could not schedule background tasks: \(error)")
    }
}
