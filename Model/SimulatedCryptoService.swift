//
//  SimulatedCryptoService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import Foundation
import Combine

class SimulatedCryptoService: ObservableObject {
    @Published var cryptoAssets: [CryptoAsset] = []
    @Published var isLoading = false
    
    private var timer: Timer?
    private let startTime = Date()
    
    init() {
        isLoading = true
        updateCryptoData()
        startRealTimeUpdates()
        
        // Simulate initial loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    func startRealTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updateCryptoData()
        }
    }
    
    func fetchInitialData() {
        isLoading = true
        updateCryptoData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func stopRealTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCryptoData() {
        let timeElapsed = Date().timeIntervalSince(startTime)
        
        cryptoAssets = [
            generateAsset(
                id: "bitcoin",
                name: "Bitcoin",
                symbol: "BTC",
                basePrice: 45000,
                timeElapsed: timeElapsed,
                volatility: 0.02,
                icon: "bitcoin"
            ),
            generateAsset(
                id: "ethereum",
                name: "Ethereum",
                symbol: "ETH",
                basePrice: 3000,
                timeElapsed: timeElapsed,
                volatility: 0.03,
                icon: "ethereum"
            ),
            generateAsset(
                id: "solana",
                name: "Solana",
                symbol: "SOL",
                basePrice: 248,
                timeElapsed: timeElapsed,
                volatility: 0.05,
                icon: "solana"
            ),
            generateAsset(
                id: "cardano",
                name: "Cardano",
                symbol: "ADA",
                basePrice: 0.5,
                timeElapsed: timeElapsed,
                volatility: 0.04,
                icon: "cardano"
            ),
            generateAsset(
                id: "matic-network",
                name: "Polygon",
                symbol: "MATIC",
                basePrice: 1.2,
                timeElapsed: timeElapsed,
                volatility: 0.06,
                icon: "polygon"
            ),
            generateAsset(
                id: "binancecoin",
                name: "BNB",
                symbol: "BNB",
                basePrice: 320,
                timeElapsed: timeElapsed,
                volatility: 0.04,
                icon: "bnb"
            ),
            generateAsset(
                id: "ripple",
                name: "XRP",
                symbol: "XRP",
                basePrice: 0.65,
                timeElapsed: timeElapsed,
                volatility: 0.07,
                icon: "xrp"
            ),
            generateAsset(
                id: "dogecoin",
                name: "Dogecoin",
                symbol: "DOGE",
                basePrice: 0.08,
                timeElapsed: timeElapsed,
                volatility: 0.08,
                icon: "dogecoin"
            ),
            generateAsset(
                id: "avalanche-2",
                name: "Avalanche",
                symbol: "AVAX",
                basePrice: 35,
                timeElapsed: timeElapsed,
                volatility: 0.06,
                icon: "avalanche"
            ),
            generateAsset(
                id: "chainlink",
                name: "Chainlink",
                symbol: "LINK",
                basePrice: 15,
                timeElapsed: timeElapsed,
                volatility: 0.05,
                icon: "chainlink"
            )
        ]
        
        print("📈 Updated \(cryptoAssets.count) crypto assets - Time: \(Int(timeElapsed))s")
    }
    
    private func generateAsset(id: String, name: String, symbol: String, basePrice: Double, timeElapsed: TimeInterval, volatility: Double, icon: String) -> CryptoAsset {
        // Create realistic price movement using sine waves and random factors
        let dailyCycle = sin(timeElapsed / 86400 * 2 * .pi) * 0.05 // 5% daily cycle
        let hourlyCycle = sin(timeElapsed / 3600 * 2 * .pi) * 0.02 // 2% hourly cycle
        let minuteCycle = sin(timeElapsed / 300 * 2 * .pi) * 0.01 // 1% 5-minute cycle
        let randomWalk = (Double.random(in: -1...1) * volatility * 0.5)
        
        let priceMultiplier = 1 + dailyCycle + hourlyCycle + minuteCycle + randomWalk
        let currentPrice = basePrice * priceMultiplier
        
        // Calculate 24h change based on price 24 hours ago
        let yesterdayTime = timeElapsed - 86400
        let yesterdayDailyCycle = sin(yesterdayTime / 86400 * 2 * .pi) * 0.05
        let yesterdayPrice = basePrice * (1 + yesterdayDailyCycle)
        let change24h = ((currentPrice - yesterdayPrice) / yesterdayPrice) * 100
        
        return CryptoAsset(
            id: id,
            name: name,
            symbol: symbol,
            currentPrice: currentPrice,
            priceChange24h: change24h,
            priceData: generatePriceHistory(basePrice: basePrice, currentTime: timeElapsed, volatility: volatility),
            icon: icon
        )
    }
    
    private func generatePriceHistory(basePrice: Double, currentTime: TimeInterval, volatility: Double) -> [CryptoPriceData] {
        var priceData: [CryptoPriceData] = []
        let numberOfPoints = 24
        let timeInterval: TimeInterval = 3600 // 1 hour intervals
        
        for i in 0..<numberOfPoints {
            let pointTime = currentTime - Double(numberOfPoints - i) * timeInterval
            let timestamp = startTime.addingTimeInterval(pointTime)
            
            // Create smooth, realistic price movement
            let dailyCycle = sin(pointTime / 86400 * 2 * .pi) * 0.05
            let hourlyCycle = sin(pointTime / 3600 * 2 * .pi) * 0.02
            let noise = (Double.random(in: -1...1) * volatility * 0.3)
            
            // Add some trend based on position in the day
            let trendFactor = sin(pointTime / 43200 * .pi) * 0.02 // 12-hour trend
            
            let priceMultiplier = 1 + dailyCycle + hourlyCycle + trendFactor + noise
            let price = basePrice * priceMultiplier
            
            priceData.append(CryptoPriceData(
                timestamp: timestamp,
                price: max(price, basePrice * 0.7), // Don't go below 70% of base
                volume: Double.random(in: 1000000...10000000) // Random volume
            ))
        }
        
        return priceData
    }
    
    deinit {
        stopRealTimeUpdates()
    }
}
