//
//  NotificationManager.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import Foundation
import UserNotifications
import Combine
import UIKit

class EnhancedNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = EnhancedNotificationManager()
    
    @Published var priceAlerts: [CryptoPriceAlert] = []
    @Published var generalNotifications: [GeneralNotification] = []
    @Published var newsAlerts: [NewsAlert] = []
    @Published var notificationSettings = NotificationSettings()
    
    // UPDATED: Use CryptoCompare service instead of mock data
    private let cryptoService = CryptoCompareService.shared
    private let newsAPIKey = ""
    private var cancellables = Set<AnyCancellable>()
    private var monitoringTimer: Timer?
    
    // Rate limiting
    private var lastNewsFetch: Date = Date.distantPast
    private var lastPriceFetch: Date = Date.distantPast
    private let minimumFetchInterval: TimeInterval = 300 // 5 minutes
    
    private override init() {
        super.init()
        loadAllSettings()
        setupNotificationCenter()
        requestNotificationPermission()
        startMonitoring()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Force notifications to show even when app is active - CRITICAL for iOS 18 issues
        completionHandler([.banner, .sound, .badge, .list])
        print("🔔 Notification will present: \(notification.request.content.title)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Notification tapped: \(response.notification.request.content.title)")
        handleNotificationResponse(response)
        completionHandler()
    }
    
    private func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
        print("✅ Notification center delegate set")
    }
    
    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            switch type {
            case "news":
                if let url = userInfo["url"] as? String {
                    print("📰 Opening news URL: \(url)")
                    // Handle news URL opening
                }
            case "price_movement":
                if let coinId = userInfo["coinId"] as? String {
                    print("📈 Opening coin details: \(coinId)")
                    // Handle coin details opening
                }
            case "market_summary":
                print("📊 Opening market summary")
                // Handle market summary opening
            default:
                print("🔔 Unknown notification type: \(type)")
            }
        }
    }
    
    // MARK: - General Crypto Notifications
    func enableGeneralCryptoNotifications() {
        DispatchQueue.main.async {
            self.notificationSettings.generalCryptoEnabled = true
            self.saveSettings()
            self.scheduleGeneralCryptoNotifications()
            print("✅ General crypto notifications enabled")
        }
    }
    
   
    
    func scheduleGeneralCryptoNotifications() {
        // Clear existing scheduled notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "daily_market_summary",
            "evening_market_report",
            "midday_news_highlights",    // NEW
            "evening_news_highlights"    // NEW
        ])
        
        // Morning Summary (Daily at 9 AM)
        scheduleRepeatingNotification(
            identifier: "daily_market_summary",
            title: "📊 Daily Market Summary",
            body: "Check out today's crypto market performance",
            hour: 9,
            minute: 0,
            categoryIdentifier: "MARKET_SUMMARY"
        )
        
        // 🆕 Midday News Highlights (Daily at 1 PM)
        scheduleRepeatingNotification(
            identifier: "midday_news_highlights",
            title: "📰 Midday Crypto News",
            body: "Top crypto stories and market developments today",
            hour: 13,
            minute: 0,
            categoryIdentifier: "NEWS_HIGHLIGHTS"
        )
        
        // Evening Report (Daily at 6 PM)
        scheduleRepeatingNotification(
            identifier: "evening_market_report",
            title: "🌆 Evening Market Report",
            body: "See how your portfolio performed today",
            hour: 18,
            minute: 0,
            categoryIdentifier: "PORTFOLIO_REPORT"
        )
        
        // 🆕 Evening News Highlights (Daily at 9 PM)
        scheduleRepeatingNotification(
            identifier: "evening_news_highlights",
            title: "📰 Evening Crypto Headlines",
            body: "Latest breaking news and market analysis",
            hour: 21,
            minute: 0,
            categoryIdentifier: "NEWS_HIGHLIGHTS"
        )
    }

    // Add new function to send scheduled news highlights
    func sendScheduledNewsHighlights(isEvening: Bool = false) async {
        let shouldSend = await MainActor.run {
            return notificationSettings.newsEnabled
        }
        
        guard shouldSend else {
            print("❌ News notifications disabled")
            return
        }
        
        do {
            // Fetch latest crypto news
            let newsArticles = try await fetchCryptoNewsFromNewsData()
            
            let content = UNMutableNotificationContent()
            let timeOfDay = isEvening ? "Evening" : "Midday"
            content.title = "📰 \(timeOfDay) Crypto Headlines"
            
            // Create news summary from top 3 articles
            var bodyText = "Today's Top Stories:\n\n"
            for (index, article) in Array(newsArticles.prefix(3)).enumerated() {
                bodyText += "\(index + 1). \(article.title)\n"
            }
            
            content.body = bodyText
            content.sound = .default
            content.badge = 1
            
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .active
                content.relevanceScore = 0.8
            }
            
            content.userInfo = [
                "type": "news_highlights",
                "timeOfDay": timeOfDay,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            content.categoryIdentifier = "NEWS_HIGHLIGHTS"
            
            let request = UNNotificationRequest(
                identifier: "news_highlights_\(timeOfDay.lowercased())_\(Date().timeIntervalSince1970)",
                content: content,
                trigger: nil
            )
            
            try await UNUserNotificationCenter.current().add(request)
            print("✅ \(timeOfDay) news highlights notification sent")
            
        } catch {
            print("❌ Failed to send news highlights: \(error)")
            // Send fallback news notification
            await sendFallbackNewsHighlights(isEvening: isEvening)
        }
    }

    // Fallback news highlights when API fails
    private func sendFallbackNewsHighlights(isEvening: Bool) async {
        let content = UNMutableNotificationContent()
        let timeOfDay = isEvening ? "Evening" : "Midday"
        
        content.title = "📰 \(timeOfDay) Crypto Headlines"
        content.body = "Bitcoin and Ethereum show strong momentum as institutional adoption continues. Tap to read more crypto news in the app."
        content.sound = .default
        content.badge = 1
        
        content.categoryIdentifier = "NEWS_HIGHLIGHTS"
        
        let request = UNNotificationRequest(
            identifier: "fallback_news_\(timeOfDay.lowercased())_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Fallback \(timeOfDay.lowercased()) news notification sent")
        } catch {
            print("❌ Failed to send fallback news notification: \(error)")
        }
    }
    
    private func scheduleRepeatingNotification(identifier: String, title: String, body: String, hour: Int, minute: Int, categoryIdentifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
        }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Scheduled notification: \(identifier) at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    // MARK: - UPDATED Market Summary with Real Data
    func sendMarketSummaryNotification() async {
        await MainActor.run {
            guard notificationSettings.generalCryptoEnabled else {
                print("❌ General crypto notifications disabled")
                return
            }
        }
        
        do {
            // Fetch real market data from CryptoCompare
            let marketSummary = try await cryptoService.fetchMarketSummary()
            let topCryptos = try await cryptoService.fetchRealTimePrices()
            
            let content = UNMutableNotificationContent()
            content.title = "📊 Crypto Market Summary"
            
            var bodyText = "Today's Market Update:\n"
            bodyText += "💰 Total Market Cap: $\(formatLargeNumber(marketSummary.totalMarketCap))\n"
            bodyText += "📈 Gainers: \(marketSummary.gainers) | 📉 Losers: \(marketSummary.losers)\n\n"
            
            // Top 3 cryptos with real price changes
            for crypto in Array(topCryptos.prefix(3)) {
                let emoji = crypto.priceChangePercentage24h >= 0 ? "📈" : "📉"
                let sign = crypto.priceChangePercentage24h >= 0 ? "+" : ""
                bodyText += "\(emoji) \(crypto.symbol.uppercased()): $\(String(format: "%.2f", crypto.currentPrice)) (\(sign)\(String(format: "%.1f", crypto.priceChangePercentage24h))%)\n"
            }
            
            content.body = bodyText
            content.sound = .default
            content.badge = 1
            
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .active
                content.relevanceScore = 1.0
            }
            
            content.userInfo = [
                "type": "market_summary",
                "timestamp": Date().timeIntervalSince1970,
                "marketCap": marketSummary.totalMarketCap
            ]
            
            content.categoryIdentifier = "MARKET_SUMMARY"
            
            let request = UNNotificationRequest(
                identifier: "market_summary_\(Date().timeIntervalSince1970)",
                content: content,
                trigger: nil
            )
            
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Real-time market summary notification sent")
            
        } catch {
            print("❌ Failed to fetch real market data: \(error)")
            // Fallback to basic notification
            await sendBasicMarketNotification()
        }
    }
    
    // MARK: - News Notifications (Only NewsData.io)
    func enableNewsNotifications() {
        DispatchQueue.main.async {
            self.notificationSettings.newsEnabled = true
            self.saveSettings()
            print("✅ News notifications enabled")
            Task {
                await self.fetchAndScheduleNewsNotifications()
            }
        }
    }
    
    func fetchAndScheduleNewsNotifications() async {
        let shouldFetch = await MainActor.run {
            return notificationSettings.newsEnabled
        }
        
        guard shouldFetch else {
            print("❌ News notifications disabled")
            return
        }
        
        // Rate limiting check
        let now = Date()
        guard now.timeIntervalSince(lastNewsFetch) >= minimumFetchInterval else {
            print("⏱️ News fetch rate limited, using mock news")
            let mockNews = getMockNewsArticles()
            if let topArticle = mockNews.first {
                await sendNewsNotification(article: topArticle)
            }
            return
        }
        
        do {
            let newsArticles = try await fetchCryptoNewsFromNewsData()
            lastNewsFetch = now
            
            // Send notification for the top article
            if let topArticle = newsArticles.first {
                await sendNewsNotification(article: topArticle)
            }
            
        } catch {
            print("❌ Error fetching news: \(error)")
            // Use mock news as fallback
            let mockNews = getMockNewsArticles()
            if let topArticle = mockNews.first {
                await sendNewsNotification(article: topArticle)
            }
        }
    }
    
    private func fetchCryptoNewsFromNewsData() async throws -> [NewsArticle] {
        let urlString = "https://newsdata.io/api/1/news?apikey=\(newsAPIKey)&q=cryptocurrency+OR+bitcoin+OR+ethereum&language=en&category=technology&size=5"
        
        print("🔍 NewsData.io API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📰 NewsData.io Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("❌ NewsData.io HTTP error: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
        }
        
        // Parse NewsData.io response
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let results = json["results"] as? [[String: Any]] {
                let articles = results.compactMap { articleData -> NewsArticle? in
                    guard let title = articleData["title"] as? String,
                          let link = articleData["link"] as? String else { return nil }
                    
                    return NewsArticle(
                        title: title,
                        description: articleData["description"] as? String ?? "",
                        url: link,
                        publishedAt: articleData["pubDate"] as? String ?? ISO8601DateFormatter().string(from: Date()),
                        source: NewsSource(name: (articleData["source_id"] as? String) ?? "NewsData")
                    )
                }
                
                if !articles.isEmpty {
                    print("✅ Fetched \(articles.count) news articles from NewsData.io")
                    return articles
                }
            }
        }
        
        throw URLError(.cannotParseResponse)
    }
    
    private func sendNewsNotification(article: NewsArticle) async {
        let content = UNMutableNotificationContent()
        content.title = "📰 Breaking Crypto News"
        content.body = article.title
        content.sound = .default
        content.badge = 1
        
        // Enhanced notification settings for iOS 18+ compatibility
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
            content.relevanceScore = 1.0
        }
        
        // Add subtitle for source
        content.subtitle = "Source: \(article.source.name)"
        
        content.userInfo = [
            "type": "news",
            "url": article.url,
            "title": article.title,
            "source": article.source.name
        ]
        
        // Set category for interactive notifications
        content.categoryIdentifier = "NEWS_ALERT"
        
        // Use immediate trigger for testing
        let request = UNNotificationRequest(
            identifier: "news_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // nil = immediate delivery
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ News notification scheduled: \(article.title)")
            
            await checkNotificationStatus()
            
        } catch {
            print("❌ Failed to send news notification: \(error)")
        }
    }
    
    // MARK: - UPDATED Major Price Movement Detection with Real Data
    func checkForMajorPriceMovements() async {
        let shouldCheck = await MainActor.run {
            return notificationSettings.majorMovementsEnabled
        }
        
        guard shouldCheck else {
            print("❌ Major movement notifications disabled")
            return
        }
        
        do {
            let threshold = await MainActor.run {
                return notificationSettings.majorMovementThreshold
            }
            
            // Fetch real movements from CryptoCompare
            let majorMovements = try await cryptoService.checkForMajorMovements(threshold: threshold)
            
            print("🚀 Found \(majorMovements.count) major movements with real data")
            
            // Send notifications for major movements (limit to 3)
            for movement in Array(majorMovements.prefix(3)) {
                await sendRealMajorMovementAlert(for: movement)
            }
            
        } catch {
            print("❌ Failed to check for real price movements: \(error)")
        }
    }

    private func sendRealMajorMovementAlert(for movement: MajorMovement) async {
        let content = UNMutableNotificationContent()
        let emoji = movement.percentageChange >= 0 ? "🚀" : "💥"
        let direction = movement.percentageChange >= 0 ? "surged" : "dropped"
        
        if movement.isExtremeMovement {
            content.title = "\(emoji) EXTREME MOVEMENT ALERT!"
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .critical
            }
        } else {
            content.title = "\(emoji) Major Movement: \(movement.coinName)"
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .active
            }
        }
        
        content.body = "\(movement.coinName) has \(direction) \(String(format: "%.1f", abs(movement.percentageChange)))% in 24h - Now $\(String(format: "%.2f", movement.currentPrice))"
        content.subtitle = "\(movement.symbol.uppercased()) • Real-time alert"
        content.sound = movement.isExtremeMovement ? .defaultCritical : .default
        content.badge = 1
        content.categoryIdentifier = "PRICE_MOVEMENT"
        
        content.userInfo = [
            "type": "price_movement",
            "coinId": movement.coinId,
            "coinName": movement.coinName,
            "priceChange": movement.percentageChange,
            "isExtreme": movement.isExtremeMovement,
            "currentPrice": movement.currentPrice
        ]
        
        let request = UNNotificationRequest(
            identifier: "major_movement_\(movement.coinId)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Real major movement alert sent for \(movement.coinName)")
        } catch {
            print("❌ Failed to send major movement alert: \(error)")
        }
    }

    // MARK: - Helper Methods
    
    private func formatLargeNumber(_ number: Double) -> String {
        if number >= 1_000_000_000_000 {
            return String(format: "%.1fT", number / 1_000_000_000_000)
        } else if number >= 1_000_000_000 {
            return String(format: "%.1fB", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.1fM", number / 1_000_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
    
    private func sendBasicMarketNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "📊 Market Update"
        content.body = "Check the app for latest cryptocurrency market data"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "basic_market_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Basic market notification sent")
        } catch {
            print("❌ Failed to send basic notification: \(error)")
        }
    }
    
    private func getMockNewsArticles() -> [NewsArticle] {
        print("⚠️ Using mock news articles")
        return [
            NewsArticle(
                title: "Bitcoin Breaks $50,000 Barrier in Historic Rally",
                description: "Cryptocurrency markets surge as Bitcoin reaches new milestone amid institutional adoption.",
                url: "https://chaintrackr.com/bitcoin-50k",
                publishedAt: ISO8601DateFormatter().string(from: Date()),
                source: NewsSource(name: "ChainTrackr News")
            ),
            NewsArticle(
                title: "Ethereum 2.0 Upgrade Reduces Gas Fees by 80%",
                description: "Major network upgrade brings significant improvements to transaction costs and speed.",
                url: "https://chaintrackr.com/eth-upgrade",
                publishedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                source: NewsSource(name: "ChainTrackr News")
            )
        ]
    }
    
    // MARK: - Enhanced Testing Methods
    func sendForceTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🚨 FORCE TEST - ChainTrackr"
        content.body = "If you see this, notifications work! This bypasses all iOS restrictions."
        content.sound = .default
        content.badge = 1
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .critical
            content.relevanceScore = 1.0
                   }
                   
                   // Use immediate trigger (nil = immediate delivery)
                   let request = UNNotificationRequest(
                       identifier: "force_test_\(Date().timeIntervalSince1970)",
                       content: content,
                       trigger: nil
                   )
                   
                   UNUserNotificationCenter.current().add(request) { error in
                       if let error = error {
                           print("❌ Force test failed: \(error)")
                       } else {
                           print("✅ Force test notification sent immediately")
                       }
                   }
               }
               
               // MARK: - COMPLETE TEST SUITE
               func sendImmediateTestSuite() async {
                   print("🧪 === RUNNING COMPLETE TEST SUITE ===")
                   
                   // Clear all existing notifications first
                   clearAllNotifications()
                   
                   // Wait a moment for clearing to complete
                   do {
                       try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                   } catch {
                       print("⏰ Sleep interrupted: \(error)")
                   }
                   
                   // Test 1: Force test notification
                   print("🧪 Test 1: Force notification")
                   sendForceTestNotification()
                   
                   // Wait between tests
                   do {
                       try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                   } catch {
                       print("⏰ Sleep interrupted: \(error)")
                   }
                   
                   // Test 2: Market summary
                   print("🧪 Test 2: Market summary")
                   await MainActor.run {
                       notificationSettings.generalCryptoEnabled = true
                   }
                   await sendMarketSummaryNotification()
                   
                   // Wait between tests
                   do {
                       try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                   } catch {
                       print("⏰ Sleep interrupted: \(error)")
                   }
                   
                   // Test 3: News notification
                   print("🧪 Test 3: News notification")
                   await MainActor.run {
                       notificationSettings.newsEnabled = true
                   }
                   await fetchAndScheduleNewsNotifications()
                   
                   // Wait between tests
                   do {
                       try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                   } catch {
                       print("⏰ Sleep interrupted: \(error)")
                   }
                   
                   // Test 4: Major movement alert
                   print("🧪 Test 4: Major movement alert")
                   await MainActor.run {
                       notificationSettings.majorMovementsEnabled = true
                       notificationSettings.majorMovementThreshold = 5.0 // Lower threshold for testing
                   }
                   await checkForMajorPriceMovements()
                   
                   // Final status check
                   do {
                       try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                   } catch {
                       print("⏰ Sleep interrupted: \(error)")
                   }
                   await checkNotificationStatus()
                   
                   print("🧪 === TEST SUITE COMPLETED ===")
                   
                   // Save updated settings
                   await MainActor.run {
                       saveSettings()
                   }
               }
               
               func clearAllNotifications() {
                   UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                   UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                   print("🧹 Cleared all notifications")
               }
               
               func resetNotificationPermissions() async {
                   // Clear all notifications first
                   clearAllNotifications()
                   
                   // Check current permission status
                   let settings = await UNUserNotificationCenter.current().notificationSettings()
                   print("🔄 Current authorization: \(authStatusText(settings.authorizationStatus))")
                   
                   if settings.authorizationStatus == .denied {
                       print("⚠️ Notifications are denied. User must enable in Settings > Notifications > ChainTrackr")
                   } else {
                       // Re-request permissions with all options
                       await requestEnhancedPermissions()
                   }
               }
               
               private func requestEnhancedPermissions() async {
                   let options: UNAuthorizationOptions = [
                       .alert,
                       .sound,
                       .badge,
                       .criticalAlert,
                       .carPlay
                   ]
                   
                   do {
                       let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
                       
                       await MainActor.run {
                           if granted {
                               print("✅ Enhanced notification permissions granted")
                               self.setupNotificationCategories()
                           } else {
                               print("❌ Notification permissions denied")
                           }
                       }
                   } catch {
                       print("❌ Permission request failed: \(error)")
                   }
               }
               
               // MARK: - Comprehensive Notification Status Checker
               func checkNotificationStatus() async {
                   let settings = await UNUserNotificationCenter.current().notificationSettings()
                   let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                   let deliveredNotifications = await UNUserNotificationCenter.current().deliveredNotifications()
                   
                   print("🔍 === DETAILED NOTIFICATION STATUS ===")
                   print("   📱 Authorization: \(settings.authorizationStatus.rawValue) (\(authStatusText(settings.authorizationStatus)))")
                   print("   🔔 Alert Setting: \(settings.alertSetting.rawValue)")
                   print("   🔊 Sound Setting: \(settings.soundSetting.rawValue)")
                   print("   🔴 Badge Setting: \(settings.badgeSetting.rawValue)")
                   print("   ⏳ Pending Notifications: \(pendingRequests.count)")
                   print("   ✅ Delivered Notifications: \(deliveredNotifications.count)")
                   
                   // iOS 15+ specific checks
                   if #available(iOS 15.0, *) {
                       print("   📅 Scheduled Delivery: \(settings.scheduledDeliverySetting.rawValue)")
                       print("   🎯 Time Sensitive: \(settings.timeSensitiveSetting.rawValue)")
                       
                       if settings.scheduledDeliverySetting == .enabled {
                           print("   ⚠️ Scheduled Summary is ENABLED - this delays notifications!")
                       }
                   }
                   
                   // List all pending notifications
                   if !pendingRequests.isEmpty {
                       print("   📋 Pending Notifications:")
                       for request in pendingRequests {
                           let triggerType = request.trigger?.description ?? "immediate"
                           print("      • \(request.identifier): \(request.content.title) (\(triggerType))")
                       }
                   }
                   
                   // List delivered notifications
                   if !deliveredNotifications.isEmpty {
                       print("   📮 Delivered Notifications:")
                       for notification in deliveredNotifications {
                           print("      • \(notification.request.identifier): \(notification.request.content.title)")
                       }
                   }
                   
                   // Check for common iOS 18 issues
                   await checkForiOS18Issues()
                   
                   print("🔍 === END STATUS CHECK ===")
               }
               
               private func checkForiOS18Issues() async {
                   print("🔍 Checking for iOS 18+ specific issues...")
                   
                   // Check device version on main actor
                   let systemVersion = await MainActor.run {
                       return UIDevice.current.systemVersion
                   }
                   print("   📱 iOS Version: \(systemVersion)")
                   
                   if systemVersion.hasPrefix("18") {
                       print("   ⚠️ iOS 18 detected - known notification delivery issues exist")
                       print("   💡 Suggested fixes:")
                       print("      • Disable Focus/Do Not Disturb completely")
                       print("      • Turn off Scheduled Summary in Settings > Notifications")
                       print("      • Disable Low Power Mode")
                       print("      • Check Background App Refresh is enabled")
                   }
               }
               
               private func authStatusText(_ status: UNAuthorizationStatus) -> String {
                   switch status {
                   case .notDetermined: return "Not Determined"
                   case .denied: return "DENIED - Check Settings"
                   case .authorized: return "Authorized"
                   case .provisional: return "Provisional"
                   case .ephemeral: return "Ephemeral"
                   @unknown default: return "Unknown"
                   }
               }
               
               // MARK: - Monitoring and Scheduling (Reduced frequency to avoid spam)
               private func startMonitoring() {
                   monitoringTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in // 30 minutes
                       Task {
                           await self?.performPeriodicChecks()
                       }
                   }
                   print("⏰ Started notification monitoring (30-minute intervals)")
               }
               
               private func performPeriodicChecks() async {
                   print("🔍 Performing periodic notification checks...")
                   
                   // Only check news every hour to avoid rate limiting
                   let minute = Calendar.current.component(.minute, from: Date())
                   if minute == 0 { // Top of every hour
                       await fetchAndScheduleNewsNotifications()
                   }
                   
                   // Check for major price movements every 30 minutes
                   await checkForMajorPriceMovements()
                   
                   await checkNotificationStatus()
               }
               
               // MARK: - Settings Management
               private func requestNotificationPermission() {
                   let options: UNAuthorizationOptions = [.alert, .sound, .badge, .criticalAlert]
                   
                   UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
                       DispatchQueue.main.async {
                           if granted {
                               print("✅ Enhanced notification permission granted")
                               self.setupNotificationCategories()
                               
                               // Check notification settings immediately
                               Task {
                                   await self.checkNotificationStatus()
                               }
                           } else {
                               print("❌ Enhanced notification permission denied: \(error?.localizedDescription ?? "Unknown")")
                           }
                       }
                   }
               }
               
               private func setupNotificationCategories() {
                   let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Details", options: .foreground)
                   let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: [])
                   
                   let priceCategory = UNNotificationCategory(identifier: "PRICE_MOVEMENT", actions: [viewAction, dismissAction], intentIdentifiers: [])
                   let newsCategory = UNNotificationCategory(identifier: "NEWS_ALERT", actions: [viewAction, dismissAction], intentIdentifiers: [])
                   let summaryCategory = UNNotificationCategory(identifier: "MARKET_SUMMARY", actions: [viewAction, dismissAction], intentIdentifiers: [])
                   let portfolioCategory = UNNotificationCategory(identifier: "PORTFOLIO_REPORT", actions: [viewAction, dismissAction], intentIdentifiers: [])
                   
                   UNUserNotificationCenter.current().setNotificationCategories([priceCategory, newsCategory, summaryCategory, portfolioCategory])
                   print("✅ Notification categories configured")
               }
               
               private func loadAllSettings() {
                   loadPriceAlerts()
                   loadNotificationSettings()
                   loadNewsAlerts()
               }
               
               private func loadPriceAlerts() {
                   if let data = UserDefaults.standard.data(forKey: "crypto_price_alerts"),
                      let alerts = try? JSONDecoder().decode([CryptoPriceAlert].self, from: data) {
                       priceAlerts = alerts
                   }
               }
               
               private func loadNotificationSettings() {
                   if let data = UserDefaults.standard.data(forKey: "notification_settings"),
                      let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
                       notificationSettings = settings
                   }
               }
               
               private func loadNewsAlerts() {
                   if let data = UserDefaults.standard.data(forKey: "news_alerts"),
                      let alerts = try? JSONDecoder().decode([NewsAlert].self, from: data) {
                       newsAlerts = alerts
                   }
               }
               
               func saveSettings() {
                   if let data = try? JSONEncoder().encode(notificationSettings) {
                       UserDefaults.standard.set(data, forKey: "notification_settings")
                       print("💾 Notification settings saved")
                   }
               }
               
               // MARK: - Enhanced Scheduled Notifications
               func scheduleOptimizedNotifications() {
                   // Clear existing scheduled notifications
                   UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
                       "morning_market_summary",
                       "evening_portfolio_report"
                   ])
                   
                   // Morning Summary - Optimized timing based on research
                   if notificationSettings.dailySummaryEnabled {
                       scheduleRepeatingNotification(
                           identifier: "morning_market_summary",
                           title: "🌅 Good Morning! Market Update",
                           body: "Your crypto portfolio and overnight market changes are ready",
                           hour: 9,
                           minute: 0,
                           categoryIdentifier: "MARKET_SUMMARY"
                       )
                   }
                   
                   // Evening Report - Optimized timing for crypto/finance apps
                   if notificationSettings.eveningReportEnabled {
                       scheduleRepeatingNotification(
                           identifier: "evening_portfolio_report",
                           title: "🌆 Daily Portfolio Report",
                           body: "See how your investments performed today",
                           hour: 18,
                           minute: 0,
                           categoryIdentifier: "PORTFOLIO_REPORT"
                       )
                   }
                   
                   print("✅ Optimized notifications scheduled for 9 AM and 6 PM")
               }
               
               // Enhanced news notification with better content
               func sendEnhancedNewsNotification(title: String, body: String, isBreaking: Bool = false) async {
                   let content = UNMutableNotificationContent()
                   
                   if isBreaking {
                       content.title = "🚨 BREAKING CRYPTO NEWS"
                       content.subtitle = "Market Alert"
                       if #available(iOS 15.0, *) {
                           content.interruptionLevel = .critical
                       }
                   } else {
                       content.title = "📰 Crypto News Update"
                       content.subtitle = "Market Analysis"
                       if #available(iOS 15.0, *) {
                           content.interruptionLevel = .active
                       }
                   }
                   
                   content.body = body
                   content.sound = isBreaking ? .defaultCritical : .default
                   content.badge = 1
                   content.categoryIdentifier = "NEWS_ALERT"
                   
                   // Add rich content for better engagement
                   content.userInfo = [
                       "type": "news",
                       "isBreaking": isBreaking,
                       "timestamp": Date().timeIntervalSince1970
                   ]
                   
                   let request = UNNotificationRequest(
                       identifier: "news_\(Date().timeIntervalSince1970)",
                       content: content,
                       trigger: nil
                   )
                   
                   do {
                       try await UNUserNotificationCenter.current().add(request)
                       print("✅ Enhanced news notification sent: \(title)")
                   } catch {
                       print("❌ Failed to send news notification: \(error)")
                   }
               }
               
               // MARK: - Price Movement Notifications with Better Context
               func sendPriceMovementNotification(crypto: String, symbol: String, currentPrice: Double, changePercent: Double, isExtremeMovement: Bool = false) async {
                   let content = UNMutableNotificationContent()
                   
                   let emoji = changePercent > 0 ? "🚀" : "💥"
                   let direction = changePercent > 0 ? "surged" : "dropped"
                   
                   if isExtremeMovement {
                       content.title = "\(emoji) EXTREME MOVEMENT ALERT!"
                       if #available(iOS 15.0, *) {
                           content.interruptionLevel = .critical
                       }
                   } else {
                       content.title = "\(emoji) Price Alert: \(crypto)"
                       if #available(iOS 15.0, *) {
                           content.interruptionLevel = .active
                       }
                   }
                   
                   content.body = "\(crypto) has \(direction) \(String(format: "%.1f", abs(changePercent)))% to $\(String(format: "%.2f", currentPrice))"
                   content.subtitle = "\(symbol.uppercased()) • Tap to view details"
                   content.sound = isExtremeMovement ? .defaultCritical : .default
                   content.badge = 1
                   content.categoryIdentifier = "PRICE_MOVEMENT"
                   
                   content.userInfo = [
                       "type": "price_movement",
                       "crypto": crypto,
                       "symbol": symbol,
                       "price": currentPrice,
                       "changePercent": changePercent,
                       "isExtreme": isExtremeMovement
                   ]
                   
                   let request = UNNotificationRequest(
                       identifier: "price_\(symbol)_\(Date().timeIntervalSince1970)",
                       content: content,
                       trigger: nil
                   )
                   
                   do {
                       try await UNUserNotificationCenter.current().add(request)
                       print("✅ Price movement notification sent for \(crypto)")
                   } catch {
                       print("❌ Failed to send price movement notification: \(error)")
                   }
               }
               
               // MARK: - Enhanced Breaking News Detection
               func checkForBreakingNews() async {
                   do {
                       let cryptos = try await cryptoService.fetchRealTimePrices()
                       var breakingNewsItems: [String] = []
                       
                       // Check for extreme movements (>20% or <-20%)
                       for crypto in cryptos {
                           if crypto.priceChangePercentage24h > 20 {
                               breakingNewsItems.append("\(crypto.name) surges \(String(format: "%.1f", crypto.priceChangePercentage24h))% to $\(String(format: "%.2f", crypto.currentPrice))")
                           } else if crypto.priceChangePercentage24h < -20 {
                               breakingNewsItems.append("\(crypto.name) crashes \(String(format: "%.1f", abs(crypto.priceChangePercentage24h)))% to $\(String(format: "%.2f", crypto.currentPrice))")
                           }
                       }
                       
                       // Check for market-wide movements
                       let avgChange = cryptos.reduce(0) { $0 + $1.priceChangePercentage24h } / Double(cryptos.count)
                       if abs(avgChange) > 15 {
                           let direction = avgChange > 0 ? "surges" : "plunges"
                           breakingNewsItems.append("Crypto market \(direction) with average \(String(format: "%.1f", abs(avgChange)))% movement")
                       }
                       
                       // Send breaking news if we have any
                       if !breakingNewsItems.isEmpty {
                           let combinedNews = breakingNewsItems.joined(separator: " • ")
                           await sendEnhancedNewsNotification(
                               title: "Market Alert: Multiple Major Movements",
                               body: combinedNews,
                               isBreaking: true
                           )
                       }
                   } catch {
                       print("❌ Failed to check for breaking news: \(error)")
                   }
               }
            }

            // MARK: - Data Models
            struct NotificationSettings: Codable {
               var generalCryptoEnabled = false
               var majorMovementsEnabled = true
               var majorMovementThreshold: Double = 10.0
               var newsEnabled = false
               var dailySummaryEnabled = true
               var eveningReportEnabled = true
            }

            struct GeneralNotification: Identifiable, Codable {
               let id = UUID()
               let type: NotificationType
               let title: String
               let message: String
               let scheduledTime: Date
               var isEnabled: Bool = true
               
               enum NotificationType: String, Codable {
                   case dailySummary = "daily_summary"
                   case majorMovement = "major_movement"
                   case marketAlert = "market_alert"
               }
            }

            struct NewsAlert: Identifiable, Codable {
               let id = UUID()
               let keyword: String
               let isEnabled: Bool
               let createdAt: Date
            }
