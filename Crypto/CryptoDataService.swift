//
//  CryptoDataService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import Foundation
import Combine

class CryptoDataService: ObservableObject {
    @Published var cryptoAssets: [CryptoAsset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    init() {
        fetchInitialData()
        startRealTimeUpdates()
    }
    
    func fetchInitialData() {
        isLoading = true
        fetchCryptoData()
    }
    
    func startRealTimeUpdates() {
        // Reduced frequency to avoid rate limits
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.fetchCryptoData()
        }
    }
    
    func stopRealTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchCryptoData() {
        // Use a single API call to get multiple coins
        let coinIds = "bitcoin,ethereum,solana,cardano,matic-network"
        let url = URL(string: "\(baseURL)/simple/price?ids=\(coinIds)&vs_currencies=usd&include_24hr_change=true&include_24hr_vol=true")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self.isLoading = false
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 API Response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                        var tempAssets: [CryptoAsset] = []
                        
                        for (coinId, coinData) in json {
                            if let price = coinData["usd"] as? Double,
                               let change24h = coinData["usd_24h_change"] as? Double {
                                
                                let asset = CryptoAsset(
                                    id: coinId,
                                    name: self.getCoinName(for: coinId),
                                    symbol: self.getCoinSymbol(for: coinId),
                                    currentPrice: price,
                                    priceChange24h: change24h,
                                    priceData: self.generateMockPriceData(currentPrice: price, change24h: change24h),
                                    icon: coinId
                                )
                                tempAssets.append(asset)
                                print("✅ \(coinId): $\(price) (\(change24h)%)")
                            }
                        }
                        
                        self.cryptoAssets = tempAssets.sorted { $0.name < $1.name }
                        self.isLoading = false
                        print("✅ Successfully fetched \(tempAssets.count) crypto assets with real prices")
                        
                    } else {
                        print("❌ Failed to parse JSON response")
                        self.isLoading = false
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    // Generate mock historical data based on current price and 24h change
    private func generateMockPriceData(currentPrice: Double, change24h: Double) -> [CryptoPriceData] {
        var priceData: [CryptoPriceData] = []
        let numberOfPoints = 20
        let timeInterval: TimeInterval = 3600 // 1 hour intervals
        
        let startPrice = currentPrice / (1 + change24h / 100) // Calculate starting price
        
        for i in 0..<numberOfPoints {
            let timestamp = Date().addingTimeInterval(TimeInterval(-numberOfPoints + i) * timeInterval)
            
            // Create realistic price movement
            let progress = Double(i) / Double(numberOfPoints - 1)
            let randomVariation = Double.random(in: -0.02...0.02) // ±2% random variation
            let trendFactor = progress * (change24h / 100) // Overall trend
            
            let price = startPrice * (1 + trendFactor + randomVariation)
            
            priceData.append(CryptoPriceData(
                timestamp: timestamp,
                price: max(price, 0.01), // Ensure price is never negative
                volume: nil
            ))
        }
        
        return priceData
    }
    
    private func getCoinName(for coinId: String) -> String {
        switch coinId {
        case "bitcoin": return "Bitcoin"
        case "ethereum": return "Ethereum"
        case "solana": return "Solana"
        case "cardano": return "Cardano"
        case "matic-network": return "Polygon"
        default: return coinId.capitalized
        }
    }
    
    private func getCoinSymbol(for coinId: String) -> String {
        switch coinId {
        case "bitcoin": return "BTC"
        case "ethereum": return "ETH"
        case "solana": return "SOL"
        case "cardano": return "ADA"
        case "matic-network": return "MATIC"
        default: return coinId.prefix(3).uppercased()
        }
    }
    
    deinit {
        stopRealTimeUpdates()
    }
}
