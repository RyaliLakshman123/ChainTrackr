//
//  PriceAlertView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import SwiftUI

struct PriceAlertManagementView: View {
    @StateObject private var alertService = PriceAlertService()
    @StateObject private var cryptoService = CryptoCompareService.shared
    //@StateObject private var cryptoService = RealTimeCryptoService() // Changed to match HomeView
    @StateObject private var notificationManager = EnhancedNotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddAlert = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = 0 // 0: Alerts, 1: Market Highlights, 2: News
    
    var body: some View {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header with Tabs
                    headerWithTabs
                    
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        // Tab 1: Price Alerts
                        priceAlertsTab
                            .tag(0)
                        
                        // Tab 2: Market Highlights
                        marketHighlightsTab
                            .tag(1)
                        
                        // Tab 3: News & Updates
                        newsUpdatesTab
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
        
        .sheet(isPresented: $showingAddAlert) {
            AddPriceAlertView(alertService: alertService, cryptoAssets: cryptoService.cryptoAssets)
        }
        .alert("Notification", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            cryptoService.fetchInitialData()
        }
    }
    
    // MARK: - Header with Tabs
    private var headerWithTabs: some View {
        VStack(spacing: 20) {
            // Main Header
            VStack(spacing: 12) {
                Image(systemName: selectedTab == 0 ? "bell.badge.fill" :
                        selectedTab == 1 ? "chart.line.uptrend.xyaxis" : "newspaper.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
                
                Text(selectedTab == 0 ? "Price Alerts" :
                        selectedTab == 1 ? "Market Highlights" : "News & Updates")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                
                Text(selectedTab == 0 ? "Get notified when crypto hits target prices" :
                        selectedTab == 1 ? "Major market movements and key metrics" : "Breaking news and market analysis")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Tab Selector
            HStack(spacing: 0) {
                tabButton(title: "Alerts", icon: "bell.fill", index: 0)
                tabButton(title: "Market", icon: "chart.bar.fill", index: 1)
                tabButton(title: "News", icon: "newspaper.fill", index: 2)
            }
            .padding(.horizontal, 4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = index
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? .black : .white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == index ? Color.yellow : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Price Alerts Tab
    private var priceAlertsTab: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Quick Actions
                quickActionsSection
                
                // Active Alerts
                if alertService.alerts.isEmpty {
                    emptyAlertsView
                } else {
                    activeAlertsSection
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            // Add Alert Button
            Button(action: {
                showingAddAlert = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Create New Alert")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.yellow)
                .cornerRadius(12)
            }
            
            .padding(.top, 30)
            
            HStack(spacing: 12) {
                // Test Notification Button
                Button(action: {
                    Task {
                        // Temporarily fix the alertService issue
                        notificationManager.sendForceTestNotification()
                        alertMessage = "Test notification sent!"
                        showingAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14))
                        Text("Test Alert")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Schedule Summary Button
                Button(action: {
                    Task {
                        await notificationManager.sendMarketSummaryNotification()
                        alertMessage = "Market summary sent!"
                        showingAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 14))
                        Text("Market Update")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
    
    private var emptyAlertsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Price Alerts")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Create your first alert to get notified when crypto prices change")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(AppGradients.cardGradient)
        .cornerRadius(16)
    }
    
    private var activeAlertsSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(alertService.alerts) { alert in
                AlertRow(alert: alert, alertService: alertService)
            }
        }
    }
    
    
    // MARK: - Market Highlights Tab
    private var marketHighlightsTab: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Breaking News Banner (if any major movements)
                breakingNewsSection
                    .padding(.top, 30)
                
                // Market Overview Cards
                marketOverviewSection
                
                // Major Price Movements
                majorMovementsSection
                
                // Fear & Greed Index
                fearGreedSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var breakingNewsSection: some View {
        VStack(spacing: 12) {
            // Check if we have any major movements
            let hasMajorMovements = cryptoService.cryptoAssets.contains { abs($0.priceChangePercentage24h) > 15 }
            
            if hasMajorMovements {
                BreakingNewsBanner(
                    title: "Major Market Movement! Multiple cryptocurrencies showing extreme volatility",
                    time: "Live"
                )
            }
            
            // Today's Highlights
            HStack {
                Text("📊 Today's Market Highlights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("Updated \(formatTime(Date()))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private var marketOverviewSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            MarketHighlightCard(
                title: "Total Market Cap",
                description: "24h change across all cryptocurrencies",
                value: "$2.1T",
                changePercentage: 8.5,
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            
            MarketHighlightCard(
                title: "Bitcoin Dominance",
                description: "BTC's share of total market cap",
                value: "52.3%",
                changePercentage: 2.1,
                icon: "bitcoinsign.circle.fill",
                color: .orange
            )
            
            MarketHighlightCard(
                title: "DeFi TVL",
                description: "Total value locked in DeFi protocols",
                value: "$85.2B",
                changePercentage: 12.7,
                icon: "lock.circle.fill",
                color: .blue
            )
            
            MarketHighlightCard(
                title: "24h Volume",
                description: "Total trading volume across markets",
                value: "$156.8B",
                changePercentage: 15.3,
                icon: "arrow.up.arrow.down.circle.fill",
                color: .purple
            )
        }
    }
    
    private var majorMovementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🚀 Major Price Movements (24h)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            if cryptoService.cryptoAssets.filter({ abs($0.priceChangePercentage24h) > 5 }).isEmpty {
                // Show placeholder when no major movements
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.flattrend.xyaxis")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No Major Movements Today")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Market is relatively stable with movements under 5%")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(30)
                .background(AppGradients.cardGradient)
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(cryptoService.cryptoAssets.filter { abs($0.priceChangePercentage24h) > 5 }.prefix(5)) { crypto in
                            PriceMovementAlertCard(
                                crypto: crypto.name,
                                symbol: crypto.symbol.uppercased(),
                                currentPrice: crypto.currentPrice,
                                priceChange: crypto.priceChange24h,
                                percentageChange: crypto.priceChangePercentage24h,
                                alertType: crypto.priceChangePercentage24h > 15 ? .extremeGain :
                                    crypto.priceChangePercentage24h < -15 ? .extremeLoss :
                                    crypto.priceChangePercentage24h > 10 ? .nearATH : .highVolume
                            )
                            .frame(width: 280)
                        }
                    }
                    .padding(.leading, 20)
                }
            }
        }
    }
    
    private var fearGreedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("😱 Fear & Greed Index")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // Fear & Greed Meter
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: 0.78) // 78 = Greed
                            .stroke(
                                LinearGradient(colors: [.red, .yellow, .green], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 120, height: 120)
                        
                        VStack {
                            Text("78")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("Greed")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Market Sentiment")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Extreme greed indicates potential market top. Consider taking profits.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 8, height: 8)
                        Text("Updated 2h ago")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(AppGradients.cardGradient)
            .cornerRadius(16)
        }
    }
    
    // MARK: - News & Updates Tab
    private var newsUpdatesTab: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Schedule Settings
                scheduleSettingsSection
                    .padding(.top, 30)
                
                // Recent News Updates
                recentNewsSection
                
                // Scheduled Notifications Status
                scheduledNotificationsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var scheduleSettingsSection: some View {
        VStack(spacing: 16) {
            Text("📅 Notification Schedule")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                // Morning Summary Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.orange)
                            Text("Morning Market Summary")
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
                                notificationManager.scheduleGeneralCryptoNotifications()
                            }
                            notificationManager.saveSettings()
                        }
                    ))
                    .tint(.orange)
                }
                .padding(16)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Evening Report Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                            Text("Evening Portfolio Report")
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
                                notificationManager.scheduleGeneralCryptoNotifications()
                            }
                            notificationManager.saveSettings()
                        }
                    ))
                    .tint(.blue)
                }
                .padding(16)
            }
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
    private var recentNewsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📰 Recent Market News")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: NewsView()) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.yellow)
                }
            }
            
            VStack(spacing: 12) {
                NewsHighlightCard(
                    title: "Bitcoin ETF Sees Record $2.1B Inflow",
                    summary: "Institutional investors pour money into Bitcoin ETFs as regulatory clarity improves",
                    time: "2h ago",
                    category: "Institutional",
                    impact: .high
                )
                
                NewsHighlightCard(
                    title: "Ethereum Layer 2 Solutions Hit New TVL Record",
                    summary: "Total value locked in L2 networks reaches $45B as scaling solutions gain adoption",
                    time: "4h ago",
                    category: "Technology",
                    impact: .medium
                )
                
                NewsHighlightCard(
                    title: "Major Bank Announces Crypto Custody Services",
                    summary: "Traditional finance continues crypto adoption with new institutional custody offering",
                    time: "6h ago",
                    category: "Banking",
                    impact: .high
                )
            }
        }
    }
    
    private var scheduledNotificationsSection: some View {
        VStack(spacing: 16) {
            Text("⏰ Notification Status")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                notificationStatusRow(
                    title: "Morning Summary (9 AM)",
                    isEnabled: notificationManager.notificationSettings.dailySummaryEnabled,
                    nextScheduled: getNextScheduledTime(hour: 9)
                )
                
                notificationStatusRow(
                    title: "Evening Report (6 PM)",
                    isEnabled: notificationManager.notificationSettings.eveningReportEnabled,
                    nextScheduled: getNextScheduledTime(hour: 18)
                )
                
                notificationStatusRow(
                    title: "Breaking News Alerts",
                    isEnabled: notificationManager.notificationSettings.newsEnabled,
                    nextScheduled: "As they happen"
                )
                
                notificationStatusRow(
                    title: "Major Price Movements",
                    isEnabled: notificationManager.notificationSettings.majorMovementsEnabled,
                    nextScheduled: "Real-time monitoring"
                )
            }
            .padding(16)
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Views and Functions
    private func notificationStatusRow(title: String, isEnabled: Bool, nextScheduled: String) -> some View {
        HStack {
            Circle()
                .fill(isEnabled ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                if isEnabled {
                    Text("Next: \(nextScheduled)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            Text(isEnabled ? "Active" : "Inactive")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isEnabled ? .green : .red)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Fixed getNextScheduledTime function
    private func getNextScheduledTime(hour: Int) -> String {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        // Create components for the target time today
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = 0
        components.second = 0
        
        guard var nextDate = calendar.date(from: components) else {
            return "Invalid date"
        }
        
        // If the time has passed today, schedule for tomorrow
        if currentHour >= hour {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: nextDate)
    }
}

// MARK: - News Highlight Card (same as before)
struct NewsHighlightCard: View {
    let title: String
    let summary: String
    let time: String
    let category: String
    let impact: NewsImpact
    
    enum NewsImpact {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            }
        }
        
        var text: String {
            switch self {
            case .high: return "HIGH IMPACT"
            case .medium: return "MEDIUM IMPACT"
            case .low: return "LOW IMPACT"
            }
        }
    }
    
    var body: some View {
        Button(action: {
            print("News article tapped: \(title)")
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(category.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(impact.text)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(impact.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(impact.color.opacity(0.2))
                        .cornerRadius(3)
                    
                    Text(time)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(summary)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Action indicator
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Read More")
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.yellow)
                }
            }
            .padding(16)
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(impact.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Existing Components (Keep these as they are)
struct AlertRow: View {
    let alert: CryptoPriceAlert
    let alertService: PriceAlertService
    
    var body: some View {
        HStack(spacing: 16) {
            // Crypto Icon
            Image(systemName: getCryptoIcon(for: alert.coinSymbol))
                .font(.system(size: 32))
                .foregroundColor(getCryptoColor(for: alert.coinSymbol))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.coinName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(alert.coinSymbol.uppercased()) \(alert.conditionText) $\(String(format: "%.2f", alert.targetPrice))")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 8) {
                    // Status indicator
                    Circle()
                        .fill(alert.hasTriggered ? Color.green : (alert.isActive ? Color.yellow : Color.gray))
                        .frame(width: 8, height: 8)
                    
                    Text(alert.hasTriggered ? "Triggered" : (alert.isActive ? "Active" : "Inactive"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(alert.hasTriggered ? .green : (alert.isActive ? .yellow : .gray))
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button(action: {
                    alertService.toggleAlert(alert)
                }) {
                    Image(systemName: alert.isActive ? "pause.circle" : "play.circle")
                        .font(.system(size: 20))
                        .foregroundColor(alert.isActive ? .orange : .green)
                }
                
                Button(action: {
                    alertService.removeAlert(alert)
                }) {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
    }
    
    private func getCryptoIcon(for symbol: String) -> String {
        switch symbol.uppercased() {
        case "BTC": return "bitcoinsign.circle.fill"
        case "ETH": return "e.circle.fill"
        case "SOL": return "s.circle.fill"
        case "ADA": return "a.circle.fill"
        case "MATIC": return "m.circle.fill"
        default: return "circle.fill"
        }
    }
    
    private func getCryptoColor(for symbol: String) -> Color {
        switch symbol.uppercased() {
        case "BTC": return .orange
        case "ETH": return .blue
        case "SOL": return .purple
        case "ADA": return .green
        case "MATIC": return .indigo
        default: return .gray
        }
    }
}

struct AddPriceAlertView: View {
    let alertService: PriceAlertService
    let cryptoAssets: [CryptoAsset]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCrypto: CryptoAsset?
    @State private var targetPrice = ""
    @State private var isAbove = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                            
                            Text("Create Price Alert")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Crypto Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Cryptocurrency")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Menu {
                                    ForEach(cryptoAssets, id: \.id) { crypto in
                                        Button("\(crypto.symbol.uppercased()) - \(crypto.name)") {
                                            selectedCrypto = crypto
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCrypto?.name ?? "Select Crypto")
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(16)
                                    .background(AppGradients.cardGradient)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Condition Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Alert Condition")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    Button("Drops Below") {
                                        isAbove = false
                                    }
                                    .buttonStyle(ConditionButtonStyle(isSelected: !isAbove))
                                    
                                    Button("Rises Above") {
                                        isAbove = true
                                    }
                                    .buttonStyle(ConditionButtonStyle(isSelected: isAbove))
                                }
                            }
                            
                            // Target Price
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Target Price (USD)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Text("$")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    TextField("0.00", text: $targetPrice)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .textFieldStyle(PlainTextFieldStyle())
                                }
                                .padding(16)
                                .background(AppGradients.cardGradient)
                                .cornerRadius(12)
                            }
                            
                            // Current Price Display
                            if let crypto = selectedCrypto {
                                HStack {
                                    Text("Current Price:")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Text("$\(String(format: "%.2f", crypto.currentPrice))")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(20)
                        .background(AppGradients.cardGradient)
                        .cornerRadius(16)
                        
                        // Create Button
                        Button(action: {
                            createAlert()
                        }) {
                            Text("Create Alert")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Color.yellow)
                                .cornerRadius(12)
                        }
                        .disabled(selectedCrypto == nil || targetPrice.isEmpty)
                        .opacity(selectedCrypto == nil || targetPrice.isEmpty ? 0.6 : 1.0)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("New Alert")
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
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("created") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createAlert() {
        guard let crypto = selectedCrypto,
              let price = Double(targetPrice),
              price > 0 else {
            alertMessage = "Please enter a valid price"
            showingAlert = true
            return
        }
        
        alertService.addAlert(
            coinId: crypto.id,
            coinName: crypto.name,
            coinSymbol: crypto.symbol,
            targetPrice: price,
            isAbove: isAbove
        )
        
        let conditionText = isAbove ? "rises above" : "drops below"
        alertMessage = "Alert created! You'll be notified when \(crypto.name) \(conditionText) $\(String(format: "%.2f", price))"
        showingAlert = true
    }
}

struct ConditionButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.yellow : Color.white.opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    PriceAlertManagementView()
}
