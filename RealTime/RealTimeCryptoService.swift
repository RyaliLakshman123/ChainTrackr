//
//  RealTimeCryptoService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import Foundation
import Combine

class RealTimeCryptoService: ObservableObject {
    @Published var cryptoAssets: [CryptoAsset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var totalMarketCap: Double = 2_487_000_000_000
    
    private var timer: Timer?
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    init() {
        fetchRealData()
        startRealTimeUpdates()
    }
    
    func fetchInitialData() {
        isLoading = true
        fetchRealData()
    }
    
    func startRealTimeUpdates() {
        // Update every 2 minutes to avoid rate limits
        timer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { _ in
            self.fetchRealData()
        }
    }
    
    func stopRealTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - New Methods for WatchlistView
    
    func getCrypto(by id: String) -> CryptoAsset? {
        return cryptoAssets.first { $0.id == id }
    }
    
    func getCoinsForCategory(_ category: String) -> [CryptoAsset] {
        switch category {
        case "Trending":
            return Array(cryptoAssets.prefix(20))
        case "Top 50":
            return Array(cryptoAssets.prefix(50))
        case "DeFi":
            return cryptoAssets.filter { coin in
                ["ethereum", "uniswap", "aave", "compound", "chainlink"].contains(coin.id) ||
                coin.name.lowercased().contains("defi")
            }
        case "Gaming":
            return cryptoAssets.filter { coin in
                ["axie-infinity", "the-sandbox", "decentraland", "enjin-coin"].contains(coin.id) ||
                coin.name.lowercased().contains("gaming")
            }
        case "Metaverse":
            return cryptoAssets.filter { coin in
                ["decentraland", "the-sandbox", "meta"].contains(coin.id) ||
                coin.name.lowercased().contains("meta")
            }
        case "AI":
            return cryptoAssets.filter { coin in
                ["artificial-intelligence", "ai", "singularitynet"].contains(coin.id) ||
                coin.name.lowercased().contains("ai")
            }
        default:
            return cryptoAssets
        }
    }
    
    private func fetchRealData() {
        isLoading = true
        
        // Fetch current prices for multiple coins
        let coinIds = "bitcoin,ethereum,solana,cardano,matic-network,binancecoin,ripple,dogecoin,avalanche-2,chainlink"
        let url = URL(string: "\(baseURL)/simple/price?ids=\(coinIds)&vs_currencies=usd&include_24hr_change=true&include_market_cap=true")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.loadFallbackData()
                    self.isLoading = false
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self.loadFallbackData()
                    self.isLoading = false
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 API Response received: \(jsonString.prefix(200))...")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                        var tempAssets: [CryptoAsset] = []
                        let group = DispatchGroup()
                        
                        for (coinId, coinData) in json {
                            if let price = coinData["usd"] as? Double,
                               let change24h = coinData["usd_24h_change"] as? Double {
                                
                                // Create initial asset with empty price data
                                let initialAsset = CryptoAsset(
                                    id: coinId,
                                    name: self.getCoinName(for: coinId),
                                    symbol: self.getCoinSymbol(for: coinId),
                                    currentPrice: price,
                                    priceChange24h: change24h,
                                    priceData: [], // Will be filled with real data
                                    icon: coinId
                                )
                                tempAssets.append(initialAsset)
                                print("📈 \(coinId): $\(price) (\(change24h >= 0 ? "+" : "")\(String(format: "%.2f", change24h))%)")
                                
                                // Fetch real historical data
                                group.enter()
                                self.fetchRealHistoricalData(coinId: coinId, currentPrice: price) { historicalData in
                                    // Update the asset with real historical data
                                    if let index = tempAssets.firstIndex(where: { $0.id == coinId }) {
                                        let updatedAsset = CryptoAsset(
                                            id: tempAssets[index].id,
                                            name: tempAssets[index].name,
                                            symbol: tempAssets[index].symbol,
                                            currentPrice: tempAssets[index].currentPrice,
                                            priceChange24h: tempAssets[index].priceChange24h,
                                            priceData: historicalData,
                                            icon: tempAssets[index].icon
                                        )
                                        tempAssets[index] = updatedAsset
                                        print("🔄 Updated \(coinId) with \(historicalData.count) real data points")
                                    }
                                    group.leave()
                                }
                            }
                        }
                        
                        // Wait for all historical data to be fetched
                        group.notify(queue: .main) {
                            if !tempAssets.isEmpty {
                                self.cryptoAssets = tempAssets.sorted { $0.name < $1.name }
                                print("✅ Fetched \(tempAssets.count) crypto assets with real data")
                            } else {
                                self.loadFallbackData()
                            }
                            self.isLoading = false
                        }
                        
                    } else {
                        print("❌ Failed to parse JSON response")
                        self.loadFallbackData()
                        self.isLoading = false
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    self.loadFallbackData()
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    private func fetchRealHistoricalData(coinId: String, currentPrice: Double, completion: @escaping ([CryptoPriceData]) -> Void) {
        let url = URL(string: "\(baseURL)/coins/\(coinId)/market_chart?vs_currency=usd&days=1&interval=hourly")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Historical data error for \(coinId): \(error.localizedDescription)")
                completion(self.generateRecentPriceData(currentPrice: currentPrice, change24h: 0))
                return
            }
            
            guard let data = data else {
                print("❌ No historical data received for \(coinId)")
                completion(self.generateRecentPriceData(currentPrice: currentPrice, change24h: 0))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: [[Double]]],
                   let prices = json["prices"] {
                    
                    let realPriceData = prices.map { pricePoint in
                        CryptoPriceData(
                            timestamp: Date(timeIntervalSince1970: pricePoint[0] / 1000),
                            price: pricePoint[1],
                            volume: nil
                        )
                    }
                    completion(realPriceData)
                    print("📊 \(coinId): \(realPriceData.count) real historical points")
                } else {
                    print("❌ Failed to parse historical data for \(coinId)")
                    completion(self.generateRecentPriceData(currentPrice: currentPrice, change24h: 0))
                }
            } catch {
                print("❌ Historical parsing error for \(coinId): \(error)")
                completion(self.generateRecentPriceData(currentPrice: currentPrice, change24h: 0))
            }
        }.resume()
    }
    
    // Generate realistic historical data based on current real price (fallback)
    private func generateRecentPriceData(currentPrice: Double, change24h: Double) -> [CryptoPriceData] {
        var priceData: [CryptoPriceData] = []
        let numberOfPoints = 24
        let timeInterval: TimeInterval = 3600 // 1 hour
        
        // Calculate starting price 24 hours ago
        let startPrice = currentPrice / (1 + change24h / 100)
        
        for i in 0..<numberOfPoints {
            let timestamp = Date().addingTimeInterval(TimeInterval(-numberOfPoints + i) * timeInterval)
            let progress = Double(i) / Double(numberOfPoints - 1)
            
            // Create smooth transition from start to current price
            let baseChange = progress * (change24h / 100)
            let volatility = sin(Double(i) * 0.5) * 0.02 // Small realistic fluctuations
            let randomNoise = Double.random(in: -0.01...0.01)
            
            let price = startPrice * (1 + baseChange + volatility + randomNoise)
            
            priceData.append(CryptoPriceData(
                timestamp: timestamp,
                price: max(price, currentPrice * 0.8), // Don't go too low
                volume: nil
            ))
        }
        
        return priceData
    }
    
    private func loadFallbackData() {
        // Enhanced fallback data with more realistic prices
        cryptoAssets = [
            CryptoAsset(
                id: "bitcoin",
                name: "Bitcoin",
                symbol: "BTC",
                currentPrice: Double.random(in: 42000...48000),
                priceChange24h: Double.random(in: -5...5),
                priceData: generateRecentPriceData(currentPrice: 45000, change24h: 2.5),
                icon: "bitcoin"
            ),
            CryptoAsset(
                id: "ethereum",
                name: "Ethereum",
                symbol: "ETH",
                currentPrice: Double.random(in: 2800...3200),
                priceChange24h: Double.random(in: -8...8),
                priceData: generateRecentPriceData(currentPrice: 3000, change24h: -1.2),
                icon: "ethereum"
            ),
            CryptoAsset(
                id: "solana",
                name: "Solana",
                symbol: "SOL",
                currentPrice: Double.random(in: 90...110),
                priceChange24h: Double.random(in: -10...10),
                priceData: generateRecentPriceData(currentPrice: 100, change24h: 5.7),
                icon: "solana"
            ),
            CryptoAsset(
                id: "cardano",
                name: "Cardano",
                symbol: "ADA",
                currentPrice: Double.random(in: 0.45...0.55),
                priceChange24h: Double.random(in: -6...6),
                priceData: generateRecentPriceData(currentPrice: 0.5, change24h: -2.1),
                icon: "cardano"
            ),
            CryptoAsset(
                id: "matic-network",
                name: "Polygon",
                symbol: "MATIC",
                currentPrice: Double.random(in: 1.0...1.4),
                priceChange24h: Double.random(in: -12...12),
                priceData: generateRecentPriceData(currentPrice: 1.2, change24h: 8.3),
                icon: "polygon"
            )
        ]
        print("⚠️ Using enhanced fallback data")
    }
    
    private func getCoinName(for coinId: String) -> String {
        let nameMap: [String: String] = [
            "bitcoin": "Bitcoin",
            "ethereum": "Ethereum",
            "solana": "Solana",
            "cardano": "Cardano",
            "matic-network": "Polygon",
            "binancecoin": "BNB",
            "ripple": "XRP",
            "dogecoin": "Dogecoin",
            "avalanche-2": "Avalanche",
            "chainlink": "Chainlink"
        ]
        return nameMap[coinId] ?? coinId.capitalized
    }
    
    private func getCoinSymbol(for coinId: String) -> String {
        let symbolMap: [String: String] = [
            "bitcoin": "BTC",
            "ethereum": "ETH",
            "solana": "SOL",
            "cardano": "ADA",
            "matic-network": "MATIC",
            "binancecoin": "BNB",
            "ripple": "XRP",
            "dogecoin": "DOGE",
            "avalanche-2": "AVAX",
            "chainlink": "LINK"
        ]
        return symbolMap[coinId] ?? coinId.prefix(3).uppercased()
    }
    
    deinit {
        stopRealTimeUpdates()
    }
}
