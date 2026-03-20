//
//  NotificationSettingsView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = EnhancedNotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        testNotificationSection
                        marketUpdatesSection
                        majorMovementsSection
                        newsSection
                        scheduledSection
                        statusSection
                        apiStatusSection
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            //.navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            // Custom back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .alert("Notification", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            print("📱 Notification Settings View appeared")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.waveform.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Notification Center")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Stay updated with crypto markets and news")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Test Notification Section
    private var testNotificationSection: some View {
        VStack(spacing: 12) {
            Text("🧪 Test Notifications")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                forceTestButton
                fullTestSuiteButton
                
                HStack(spacing: 8) {
                    marketSummaryTestButton
                    newsTestButton
                }
                
                HStack(spacing: 8) {
                    movementTestButton
                    apiTestButton
                }
                
                HStack(spacing: 8) {
                    clearAllButton
                    checkStatusButton
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Test Buttons
    private var forceTestButton: some View {
        Button(action: {
            notificationManager.sendForceTestNotification()
            alertMessage = "Force test notification sent! Check your notification center."
            showingAlert = true
        }) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16))
                Text("Send Force Test Notification")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.yellow)
            .cornerRadius(12)
        }
        .padding(.top, 10)
    }
    
    private var fullTestSuiteButton: some View {
        Button(action: {
            Task {
                await notificationManager.sendImmediateTestSuite()
                alertMessage = "Full test suite completed! Check console and notifications."
                showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "testtube.2")
                    .font(.system(size: 16))
                Text("Run Full Test Suite")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.purple)
            .cornerRadius(12)
        }
        .padding(.top, 10)
    }
    
    private var marketSummaryTestButton: some View {
        Button(action: {
            Task {
                await notificationManager.sendMarketSummaryNotification()
                alertMessage = "Test market summary sent!"
                showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 14))
                Text("Market Summary")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.cyan)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.cyan.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    private var newsTestButton: some View {
        Button(action: {
            Task {
                await notificationManager.fetchAndScheduleNewsNotifications()
                alertMessage = "Test news notification sent!"
                showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 14))
                Text("News Alert")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    private var movementTestButton: some View {
        Button(action: {
            Task {
                await notificationManager.checkForMajorPriceMovements()
                alertMessage = "Test movement alert sent!"
                showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 14))
                Text("Movement")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.green)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    private var apiTestButton: some View {
        Button(action: {
            Task {
                await testNewsAPI()
                alertMessage = "API key test completed! Check console for results."
                showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "key.fill")
                    .font(.system(size: 14))
                Text("Test API")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    private var clearAllButton: some View {
        Button(action: {
            notificationManager.clearAllNotifications()
            alertMessage = "All notifications cleared!"
            showingAlert = true
        }) {
            HStack {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 14))
                Text("Clear All")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    private var checkStatusButton: some View {
        Button(action: {
            Task {
                await notificationManager.checkNotificationStatus()
                alertMessage = "Notification status checked! See console for details."
                showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 14))
                Text("Check Status")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.green)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Notification Sections
    private var marketUpdatesSection: some View {
        notificationSection(
            title: "📊 Market Updates",
            description: "Daily summaries and market reports",
            isEnabled: notificationManager.notificationSettings.generalCryptoEnabled,
            toggle: {
                notificationManager.notificationSettings.generalCryptoEnabled.toggle()
                if notificationManager.notificationSettings.generalCryptoEnabled {
                    notificationManager.enableGeneralCryptoNotifications()
                } else {
                    print("❌ General crypto notifications disabled")
                }
                notificationManager.saveSettings()
                notificationManager.objectWillChange.send()
            }
        )
    }
    
    private var majorMovementsSection: some View {
        VStack(spacing: 16) {
            notificationSection(
                title: "🚀 Major Price Movements",
                description: "Get alerted for significant price changes",
                isEnabled: notificationManager.notificationSettings.majorMovementsEnabled,
                toggle: {
                    notificationManager.notificationSettings.majorMovementsEnabled.toggle()
                    if notificationManager.notificationSettings.majorMovementsEnabled {
                        print("✅ Major price movement alerts enabled")
                    } else {
                        print("❌ Major price movement alerts disabled")
                    }
                    notificationManager.saveSettings()
                    notificationManager.objectWillChange.send()
                }
            )
            
            if notificationManager.notificationSettings.majorMovementsEnabled {
                thresholdSliderSection
            }
        }
    }
    
    private var thresholdSliderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alert Threshold: \(String(format: "%.0f", notificationManager.notificationSettings.majorMovementThreshold))%")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Slider(
                value: Binding(
                    get: { notificationManager.notificationSettings.majorMovementThreshold },
                    set: { newValue in
                        notificationManager.notificationSettings.majorMovementThreshold = newValue
                        print("🎯 Major movement threshold set to: \(newValue)%")
                        notificationManager.saveSettings()
                    }
                ),
                in: 5...25,
                step: 1
            ) {
                Text("Threshold")
            } minimumValueLabel: {
                Text("5%")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            } maximumValueLabel: {
                Text("25%")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            .tint(.yellow)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private var newsSection: some View {
        notificationSection(
            title: "📰 Crypto News",
            description: "Breaking news and market updates",
            isEnabled: notificationManager.notificationSettings.newsEnabled,
            toggle: {
                notificationManager.notificationSettings.newsEnabled.toggle()
                if notificationManager.notificationSettings.newsEnabled {
                    notificationManager.enableNewsNotifications()
                } else {
                    print("❌ News notifications disabled")
                }
                notificationManager.saveSettings()
                notificationManager.objectWillChange.send()
            }
        )
    }
    
    // MARK: - UPDATED Scheduled Section with News Highlights
    private var scheduledSection: some View {
        VStack(spacing: 16) {
            Text("📅 Scheduled Notifications")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                morningToggleRow
                Divider().background(Color.white.opacity(0.1))
                middayNewsToggleRow
                Divider().background(Color.white.opacity(0.1))
                eveningToggleRow
                Divider().background(Color.white.opacity(0.1))
                eveningNewsToggleRow
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private var morningToggleRow: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.orange)
                    Text("Morning Summary")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text("Daily at 9:00 AM • Market overview & overnight changes")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { notificationManager.notificationSettings.dailySummaryEnabled },
                set: { newValue in
                    notificationManager.notificationSettings.dailySummaryEnabled = newValue
                    if newValue {
                        print("✅ Daily summary notifications enabled")
                    } else {
                        print("❌ Daily summary notifications disabled")
                    }
                    notificationManager.saveSettings()
                }
            ))
            .tint(.orange)
        }
        .padding(16)
    }
    
    // NEW: Midday News Toggle Row
    private var middayNewsToggleRow: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundColor(.purple)
                    Text("Midday News Highlights")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text("Daily at 1:00 PM • Top crypto stories and developments")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: {
                    // Use existing newsEnabled setting for now, or add new property to NotificationSettings
                    notificationManager.notificationSettings.newsEnabled
                },
                set: { newValue in
                    // For now, tie to newsEnabled. Later you can add middayNewsEnabled to NotificationSettings
                    notificationManager.notificationSettings.newsEnabled = newValue
                    if newValue {
                        print("✅ Midday news highlights enabled")
                    } else {
                        print("❌ Midday news highlights disabled")
                    }
                    notificationManager.saveSettings()
                }
            ))
            .tint(.purple)
        }
        .padding(16)
    }
    
    private var eveningToggleRow: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.blue)
                    Text("Evening Report")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text("Daily at 6:00 PM • Portfolio performance & day summary")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { notificationManager.notificationSettings.eveningReportEnabled },
                set: { newValue in
                    notificationManager.notificationSettings.eveningReportEnabled = newValue
                    if newValue {
                        print("✅ Evening report notifications enabled")
                    } else {
                        print("❌ Evening report notifications disabled")
                    }
                    notificationManager.saveSettings()
                }
            ))
            .tint(.blue)
        }
        .padding(16)
    }
    
    // NEW: Evening News Toggle Row
    private var eveningNewsToggleRow: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Evening News Highlights")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text("Daily at 9:00 PM • Latest breaking news & analysis")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: {
                    // Use existing newsEnabled setting for now
                    notificationManager.notificationSettings.newsEnabled
                },
                set: { newValue in
                    notificationManager.notificationSettings.newsEnabled = newValue
                    if newValue {
                        print("✅ Evening news highlights enabled")
                    } else {
                        print("❌ Evening news highlights disabled")
                    }
                    notificationManager.saveSettings()
                }
            ))
            .tint(.yellow)
        }
        .padding(16)
    }
    
    // MARK: - UPDATED Status Section
    private var statusSection: some View {
        VStack(spacing: 12) {
            Text("📊 Current Status")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                statusRow(title: "Market Updates", isEnabled: notificationManager.notificationSettings.generalCryptoEnabled)
                statusRow(title: "Price Movements (\(String(format: "%.0f", notificationManager.notificationSettings.majorMovementThreshold))%+)", isEnabled: notificationManager.notificationSettings.majorMovementsEnabled)
                statusRow(title: "Breaking News", isEnabled: notificationManager.notificationSettings.newsEnabled)
                statusRow(title: "Daily Summary (9 AM)", isEnabled: notificationManager.notificationSettings.dailySummaryEnabled)
                statusRow(title: "Midday News (1 PM)", isEnabled: notificationManager.notificationSettings.newsEnabled)
                statusRow(title: "Evening Report (6 PM)", isEnabled: notificationManager.notificationSettings.eveningReportEnabled)
                statusRow(title: "Evening News (9 PM)", isEnabled: notificationManager.notificationSettings.newsEnabled)
            }
            .padding(16)
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private var apiStatusSection: some View {
        VStack(spacing: 12) {
            Text("🔧 System Status")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                apiStatusRow(title: "CryptoCompare API", status: "Active", color: .green)
                apiStatusRow(title: "NewsData.io API", status: "Updated", color: .green)
                apiStatusRow(title: "Real-time Data", status: "Live", color: .blue)
                apiStatusRow(title: "Notification System", status: "Ready", color: .green)
            }
            .padding(16)
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Functions
    private func testNewsAPI() async {
        print("🧪 Testing NewsData.io API key...")
        
        let newsAPIKey = "pub_619ba3a7731642d0bd0275498a68a10a"
        let testURL = "https://newsdata.io/api/1/news?apikey=\(newsAPIKey)&q=bitcoin&language=en&size=1"
        
        guard let url = URL(string: testURL) else {
            print("❌ Invalid test URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 NewsData.io API Response Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("✅ NewsData.io API key is working!")
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let firstResult = results.first,
                       let title = firstResult["title"] as? String {
                        print("📰 Sample article: \(title)")
                    }
                } else {
                    print("❌ NewsData.io API returned status: \(httpResponse.statusCode)")
                }
            }
            
        } catch {
            print("❌ NewsData.io API test failed: \(error)")
        }
    }
    
    // MARK: - Helper Views
    private func notificationSection(title: String, description: String, isEnabled: Bool, toggle: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: toggle) {
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isEnabled ? .yellow : .white.opacity(0.3))
                }
            }
            .padding(20)
        }
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private func statusRow(title: String, isEnabled: Bool) -> some View {
        HStack {
            Circle()
                .fill(isEnabled ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(isEnabled ? "Active" : "Inactive")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isEnabled ? .green : .red)
        }
    }
    
    private func apiStatusRow(title: String, status: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(status)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
        }
    }
}

#Preview {
    NotificationSettingsView()
}
