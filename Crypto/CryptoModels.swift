//
//  CryptoModels.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import Foundation

// MARK: - Core Data Models
struct CryptoPriceData: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let price: Double
    let volume: Double?
    
    init(timestamp: Date, price: Double, volume: Double?) {
        self.timestamp = timestamp
        self.price = price
        self.volume = volume
    }
}

struct CryptoAsset: Identifiable, Codable {
    let id: String
    let name: String
    let symbol: String
    let currentPrice: Double
    let priceChange24h: Double
    let priceChangePercentage24h: Double
    let marketCap: Double
    let volume24h: Double
    let circulatingSupply: Double
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double
    let athDate: String
    let atl: Double
    let atlDate: String
    let rank: Int
    let sparkline7d: [Double]?
    
    // For compatibility with HomeView
    let priceData: [CryptoPriceData]
    let icon: String
    
    init(id: String, name: String, symbol: String, currentPrice: Double, priceChange24h: Double, priceChangePercentage24h: Double, marketCap: Double, volume24h: Double, circulatingSupply: Double, totalSupply: Double?, maxSupply: Double?, ath: Double, athDate: String, atl: Double, atlDate: String, rank: Int, sparkline7d: [Double]?) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.currentPrice = currentPrice
        self.priceChange24h = priceChange24h
        self.priceChangePercentage24h = priceChangePercentage24h
        self.marketCap = marketCap
        self.volume24h = volume24h
        self.circulatingSupply = circulatingSupply
        self.totalSupply = totalSupply
        self.maxSupply = maxSupply
        self.ath = ath
        self.athDate = athDate
        self.atl = atl
        self.atlDate = atlDate
        self.rank = rank
        self.sparkline7d = sparkline7d
        
        // Generate price data from sparkline
        self.priceData = CryptoAsset.generatePriceData(from: sparkline7d, currentPrice: currentPrice)
        self.icon = CryptoAsset.getIconName(for: id)
    }
    
    // Compatibility initializer for HomeView
    init(id: String, name: String, symbol: String, currentPrice: Double, priceChange24h: Double, priceData: [CryptoPriceData], icon: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.currentPrice = currentPrice
        self.priceChange24h = priceChange24h
        self.priceChangePercentage24h = priceChange24h
        self.marketCap = 0
        self.volume24h = 0
        self.circulatingSupply = 0
        self.totalSupply = nil
        self.maxSupply = nil
        self.ath = 0
        self.athDate = ""
        self.atl = 0
        self.atlDate = ""
        self.rank = 0
        self.sparkline7d = nil
        self.priceData = priceData
        self.icon = icon
    }
    
    private static func getIconName(for coinId: String) -> String {
        switch coinId {
        case "bitcoin": return "bitcoin"
        case "ethereum": return "ethereum"
        case "binancecoin": return "binance"
        case "cardano": return "cardano"
        case "solana": return "solana"
        case "xrp": return "xrp"
        case "polkadot": return "polkadot"
        case "dogecoin": return "dogecoin"
        case "avalanche-2": return "avalanche"
        case "chainlink": return "chainlink"
        case "matic-network": return "polygon"
        default: return "bitcoin"
        }
    }
    
    private static func generatePriceData(from sparkline: [Double]?, currentPrice: Double) -> [CryptoPriceData] {
        guard let sparkline = sparkline, !sparkline.isEmpty else {
            return generateSamplePriceData(currentPrice: currentPrice)
        }
        
        return sparkline.enumerated().map { index, price in
            CryptoPriceData(
                timestamp: Date().addingTimeInterval(TimeInterval(-sparkline.count + index) * 3600),
                price: price,
                volume: nil
            )
        }
    }
    
    private static func generateSamplePriceData(currentPrice: Double) -> [CryptoPriceData] {
        var data: [CryptoPriceData] = []
        let numberOfPoints = 24
        
        for i in 0..<numberOfPoints {
            let timestamp = Date().addingTimeInterval(TimeInterval(-numberOfPoints + i) * 3600)
            let variation = Double.random(in: -0.05...0.05)
            let price = currentPrice * (1 + variation)
            
            data.append(CryptoPriceData(
                timestamp: timestamp,
                price: price,
                volume: nil
            ))
        }
        
        return data
    }
    
    var formattedPrice: String {
        if currentPrice < 0.01 {
            return String(format: "$%.6f", currentPrice)
        } else if currentPrice < 1 {
            return String(format: "$%.4f", currentPrice)
        } else {
            return String(format: "$%.2f", currentPrice)
        }
    }
    
    var formattedMarketCap: String {
        if marketCap >= 1_000_000_000_000 {
            return String(format: "$%.1fT", marketCap / 1_000_000_000_000)
        } else if marketCap >= 1_000_000_000 {
            return String(format: "$%.1fB", marketCap / 1_000_000_000)
        } else if marketCap >= 1_000_000 {
            return String(format: "$%.1fM", marketCap / 1_000_000)
        } else {
            return String(format: "$%.0f", marketCap)
        }
    }
}

// MARK: - API Response Models
struct CoinGeckoResponse: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let fullyDilutedValuation: Double?
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?
    let priceChange24h: Double?
    let priceChangePercentage24h: Double?
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: String?
    let roi: ROI?
    let lastUpdated: String?
    let sparklineIn7d: SparklineData?
    
    struct ROI: Codable {
        let times: Double?
        let currency: String?
        let percentage: Double?
    }
    
    struct SparklineData: Codable {
        let price: [Double]?
    }
}
