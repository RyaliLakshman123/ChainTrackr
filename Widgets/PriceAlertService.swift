//
//  PriceAlertService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import Foundation
import UserNotifications
import Combine

struct CryptoPriceAlert: Identifiable, Codable {
    let id = UUID()
    let coinId: String
    let coinName: String
    let coinSymbol: String
    let targetPrice: Double
    let isAbove: Bool // true for "above", false for "below"
    let createdAt: Date
    var isActive: Bool = true
    var hasTriggered: Bool = false
    
    var conditionText: String {
        return isAbove ? "rises above" : "drops below"
    }
}

class PriceAlertService: ObservableObject {
    @Published var alerts: [CryptoPriceAlert] = []
    private var cancellables = Set<AnyCancellable>()
    private let cryptoService = CryptoDataService()
    private let apiKey = ""
    
    init() {
        loadAlerts()
        requestNotificationPermission()
        startMonitoring()
    }
    
    func addAlert(coinId: String, coinName: String, coinSymbol: String, targetPrice: Double, isAbove: Bool) {
        let alert = CryptoPriceAlert(
            coinId: coinId,
            coinName: coinName,
            coinSymbol: coinSymbol,
            targetPrice: targetPrice,
            isAbove: isAbove,
            createdAt: Date()
        )
        
        alerts.append(alert)
        saveAlerts()
        print("✅ Added price alert for \(coinName) at $\(targetPrice)")
    }
    
    func removeAlert(_ alert: CryptoPriceAlert) {
        alerts.removeAll { $0.id == alert.id }
        saveAlerts()
        
        // Cancel any pending notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alert.id.uuidString])
        print("❌ Removed price alert for \(alert.coinName)")
    }
    
    func toggleAlert(_ alert: CryptoPriceAlert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isActive.toggle()
            saveAlerts()
        }
    }
    
    private func startMonitoring() {
        // Monitor every 2 minutes for active alerts
        Timer.publish(every: 120, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.checkAlerts()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func checkAlerts() async {
        let activeAlerts = alerts.filter { $0.isActive && !$0.hasTriggered }
        guard !activeAlerts.isEmpty else { return }
        
        print("🔍 Checking \(activeAlerts.count) active price alerts...")
        
        for alert in activeAlerts {
            // Check with your existing crypto service first
            if let asset = cryptoService.cryptoAssets.first(where: { $0.id == alert.coinId }) {
                await checkAndTriggerAlert(alert, currentPrice: asset.currentPrice)
            } else {
                // Fallback to API call for specific coin
                await checkAlertWithAPI(alert)
            }
        }
    }
    
    private func checkAlertWithAPI(_ alert: CryptoPriceAlert) async {
        do {
            let price = try await fetchCoinPrice(coinId: alert.coinId)
            await checkAndTriggerAlert(alert, currentPrice: price)
        } catch {
            print("❌ Error fetching price for \(alert.coinName): \(error)")
        }
    }
    
    private func fetchCoinPrice(coinId: String) async throws -> Double {
        // Using CoinGecko API (free) as fallback
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinId)&vs_currencies=usd"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode([String: [String: Double]].self, from: data)
        
        guard let coinData = response[coinId],
              let price = coinData["usd"] else {
            throw URLError(.cannotParseResponse)
        }
        
        return price
    }
    
    @MainActor
    private func checkAndTriggerAlert(_ alert: CryptoPriceAlert, currentPrice: Double) async {
        let shouldTrigger = alert.isAbove ?
            currentPrice >= alert.targetPrice :
            currentPrice <= alert.targetPrice
        
        if shouldTrigger {
            await triggerAlert(alert, currentPrice: currentPrice)
            
            // Mark as triggered
            if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
                alerts[index].hasTriggered = true
                alerts[index].isActive = false
            }
            saveAlerts()
        }
    }
    
    private func triggerAlert(_ alert: CryptoPriceAlert, currentPrice: Double) async {
        let content = UNMutableNotificationContent()
        content.title = "🚨 Price Alert: \(alert.coinSymbol.uppercased())"
        
        let conditionText = alert.isAbove ? "above" : "below"
        let changeEmoji = alert.isAbove ? "📈" : "📉"
        
        content.body = "\(changeEmoji) \(alert.coinName) is now $\(String(format: "%.2f", currentPrice)) (\(conditionText) your target of $\(String(format: "%.2f", alert.targetPrice)))"
        
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "coinId": alert.coinId,
            "coinName": alert.coinName,
            "currentPrice": currentPrice,
            "targetPrice": alert.targetPrice
        ]
        
        // Add action buttons
        let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Details", options: .foreground)
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: [])
        
        let category = UNNotificationCategory(identifier: "PRICE_ALERT", actions: [viewAction, dismissAction], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "PRICE_ALERT"
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Price alert notification sent for \(alert.coinName)")
        } catch {
            print("❌ Failed to send notification: \(error)")
        }
    }
    
    func sendTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "🧪 Test Price Alert"
        content.body = "Price alert system is working correctly!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "test_price_alert", content: content, trigger: nil)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Test price alert sent")
        } catch {
            print("❌ Failed to send test price alert: \(error)")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Price alert notification permission granted")
                } else {
                    print("❌ Price alert notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func saveAlerts() {
        if let data = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(data, forKey: "crypto_price_alerts")
        }
    }
    
    private func loadAlerts() {
        if let data = UserDefaults.standard.data(forKey: "crypto_price_alerts"),
           let savedAlerts = try? JSONDecoder().decode([CryptoPriceAlert].self, from: data) {
            alerts = savedAlerts
        }
    }
}
