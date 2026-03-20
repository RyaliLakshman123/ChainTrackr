//
//  CryptoCompareService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 24/07/25.
//

import Foundation
import Combine

class CryptoCompareService: ObservableObject {
    static let shared = CryptoCompareService()
    
    private let apiKey = ""
    private let baseURL = "https://min-api.cryptocompare.com/data"
    
    @Published var cryptoAssets: [CryptoAsset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var lastFetchTime: Date = Date.distantPast
    private let minimumFetchInterval: TimeInterval = 30 // 30 seconds between API calls
    
    private init() {}
    
    // MARK: - Main Data Fetching Methods
    
    /// Fetch real-time prices for multiple cryptocurrencies
    func fetchRealTimePrices() async throws -> [CryptoAsset] {
        // Rate limiting check
        let now = Date()
        guard now.timeIntervalSince(lastFetchTime) >= minimumFetchInterval else {
            print("⏱️ Rate limiting: Using cached data")
            return cryptoAssets
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let symbols = ["BTC", "ETH", "SOL", "ADA", "MATIC", "AVAX", "DOT", "LINK"]
        let urlString = "\(baseURL)/pricemultifull?fsyms=\(symbols.joined(separator: ","))&tsyms=USD&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw CryptoCompareError.invalidURL
        }
        
        print("🔍 CryptoCompare API URL: \(urlString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 CryptoCompare Response Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    throw CryptoCompareError.invalidResponse(httpResponse.statusCode)
                }
            }
            
            let priceResponse = try JSONDecoder().decode(CryptoComparePriceResponse.self, from: data)
            let assets = convertToCryptoAssets(from: priceResponse)
            
            await MainActor.run {
                self.cryptoAssets = assets
                self.isLoading = false
                self.lastFetchTime = now
                print("✅ Fetched \(assets.count) cryptocurrencies from CryptoCompare")
            }
            
            return assets
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                print("❌ CryptoCompare API Error: \(error)")
            }
            throw error
        }
    }
    
    /// Initialize with initial data fetch
    func fetchInitialData() {
        Task {
            do {
                _ = try await fetchRealTimePrices()
            } catch {
                print("❌ Failed to fetch initial data: \(error)")
            }
        }
    }
    
    /// Fetch historical data for price charts
    func fetchHistoricalData(symbol: String, days: Int = 30) async throws -> [CryptoPriceData] {
        let urlString = "\(baseURL)/v2/histoday?fsym=\(symbol)&tsym=USD&limit=\(days)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw CryptoCompareError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CryptoCompareHistoricalResponse.self, from: data)
        
        return response.Data.Data.map { histData in
            CryptoPriceData(
                timestamp: Date(timeIntervalSince1970: TimeInterval(histData.time)),
                price: histData.close,
                volume: histData.volumeto
            )
        }
    }
    
    /// Get market summary data
    func fetchMarketSummary() async throws -> MarketSummary {
        let symbols = ["BTC", "ETH", "SOL", "ADA", "MATIC"]
        let urlString = "\(baseURL)/pricemultifull?fsyms=\(symbols.joined(separator: ","))&tsyms=USD&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw CryptoCompareError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let priceResponse = try JSONDecoder().decode(CryptoComparePriceResponse.self, from: data)
        
        return generateMarketSummary(from: priceResponse)
    }
    
    /// Check for major price movements (>10% change)
    func checkForMajorMovements(threshold: Double = 10.0) async throws -> [MajorMovement] {
        let assets = try await fetchRealTimePrices()
        
        return assets.compactMap { asset in
            if abs(asset.priceChangePercentage24h) >= threshold {
                return MajorMovement(
                    coinId: asset.id,
                    coinName: asset.name,
                    symbol: asset.symbol,
                    currentPrice: asset.currentPrice,
                    priceChange: asset.priceChange24h,
                    percentageChange: asset.priceChangePercentage24h,
                    isExtremeMovement: abs(asset.priceChangePercentage24h) > 20
                )
            }
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func convertToCryptoAssets(from response: CryptoComparePriceResponse) -> [CryptoAsset] {
        return response.RAW.compactMap { (symbol, data) in
            guard let usd = data["USD"] else { return nil }
            
            // FIXED: Use your exact CryptoAsset initializer
            return CryptoAsset(
                id: symbol.lowercased(),
                name: getFullName(for: symbol),
                symbol: symbol.lowercased(),
                currentPrice: usd.PRICE,
                priceChange24h: usd.CHANGE24HOUR,
                priceChangePercentage24h: usd.CHANGEPCT24HOUR,
                marketCap: usd.MKTCAP,
                volume24h: usd.VOLUME24HOURTO,
                circulatingSupply: usd.SUPPLY,
                totalSupply: nil,
                maxSupply: nil,
                ath: usd.HIGH24HOUR,
                athDate: formatDate(from: usd.LASTUPDATE),
                atl: usd.LOW24HOUR,
                atlDate: formatDate(from: usd.LASTUPDATE),
                rank: getRank(for: symbol),
                sparkline7d: generateSparklineData(currentPrice: usd.PRICE)
            )
        }.sorted { abs($0.priceChangePercentage24h) > abs($1.priceChangePercentage24h) }
    }
    
    private func generateMarketSummary(from response: CryptoComparePriceResponse) -> MarketSummary {
        let assets = convertToCryptoAssets(from: response)
        let totalMarketCap = assets.reduce(0) { $0 + $1.marketCap }
        let averageChange = assets.reduce(0) { $0 + $1.priceChangePercentage24h } / Double(max(assets.count, 1))
        
        return MarketSummary(
            totalMarketCap: totalMarketCap,
            totalVolume24h: assets.reduce(0) { $0 + $1.volume24h },
            marketCapChange24h: averageChange,
            activeCryptocurrencies: assets.count,
            gainers: assets.filter { $0.priceChangePercentage24h > 0 }.count,
            losers: assets.filter { $0.priceChangePercentage24h < 0 }.count
        )
    }
    
    private func getFullName(for symbol: String) -> String {
        let nameMap = [
            "BTC": "Bitcoin",
            "ETH": "Ethereum",
            "SOL": "Solana",
            "ADA": "Cardano",
            "MATIC": "Polygon",
            "AVAX": "Avalanche",
            "DOT": "Polkadot",
            "LINK": "Chainlink"
        ]
        return nameMap[symbol] ?? symbol
    }
    
    private func getRank(for symbol: String) -> Int {
        let rankMap = [
            "BTC": 1,
            "ETH": 2,
            "SOL": 3,
            "ADA": 4,
            "MATIC": 5,
            "AVAX": 6,
            "DOT": 7,
            "LINK": 8
        ]
        return rankMap[symbol] ?? 999
    }
    
    private func generateSparklineData(currentPrice: Double) -> [Double] {
        // Generate 7 days of sample price data based on current price
        var sparkline: [Double] = []
        let basePrice = currentPrice
        
        for i in 0..<7 {
            let variation = Double.random(in: -0.1...0.1) // ±10% variation
            let price = basePrice * (1 + variation)
            sparkline.append(price)
        }
        
        return sparkline
    }
    
    private func formatDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - CryptoCompare API Models

struct CryptoComparePriceResponse: Codable {
    let RAW: [String: [String: CryptoComparePrice]]
    let DISPLAY: [String: [String: CryptoCompareDisplayPrice]]
}

struct CryptoComparePrice: Codable {
    let PRICE: Double
    let CHANGE24HOUR: Double
    let CHANGEPCT24HOUR: Double
    let VOLUME24HOUR: Double
    let VOLUME24HOURTO: Double
    let HIGH24HOUR: Double
    let LOW24HOUR: Double
    let MKTCAP: Double
    let SUPPLY: Double
    let LASTUPDATE: Double
}

struct CryptoCompareDisplayPrice: Codable {
    let PRICE: String
    let CHANGE24HOUR: String
    let CHANGEPCT24HOUR: String
    let VOLUME24HOURTO: String
    let MKTCAP: String
}

struct CryptoCompareHistoricalResponse: Codable {
    let Data: CryptoCompareHistoricalData
}

struct CryptoCompareHistoricalData: Codable {
    let Data: [CryptoCompareHistoricalPoint]
}

struct CryptoCompareHistoricalPoint: Codable {
    let time: Int
    let close: Double
    let high: Double
    let low: Double
    let open: Double
    let volumeto: Double?
}

// MARK: - Supporting Models

struct MarketSummary {
    let totalMarketCap: Double
    let totalVolume24h: Double
    let marketCapChange24h: Double
    let activeCryptocurrencies: Int
    let gainers: Int
    let losers: Int
}

struct MajorMovement {
    let coinId: String
    let coinName: String
    let symbol: String
    let currentPrice: Double
    let priceChange: Double
    let percentageChange: Double
    let isExtremeMovement: Bool
}

// MARK: - Errors

enum CryptoCompareError: LocalizedError {
    case invalidURL
    case invalidResponse(Int)
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse(let code):
            return "API returned status code: \(code)"
        case .noData:
            return "No data received from API"
        case .decodingError:
            return "Failed to decode API response"
        }
    }
}
