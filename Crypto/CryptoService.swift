//
//  CryptoService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import Foundation
import Combine

// MARK: - Enhanced Crypto Service for WatchlistView
class EnhancedCryptoService: ObservableObject {
    @Published var cryptoAssets: [CryptoAsset] = []
    @Published var isLoading = false
    @Published var totalMarketCap: Double = 0
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSampleData()
    }
    
    func fetchAllCoins() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true&price_change_percentage=24h") else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Error fetching coins: \(error)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let coinData = try decoder.decode([CoinGeckoResponse].self, from: data)
                    
                    self?.cryptoAssets = coinData.map { coin in
                        CryptoAsset(
                            id: coin.id,
                            name: coin.name,
                            symbol: coin.symbol,
                            currentPrice: coin.currentPrice ?? 0,
                            priceChange24h: coin.priceChange24h ?? 0,
                            priceChangePercentage24h: coin.priceChangePercentage24h ?? 0,
                            marketCap: coin.marketCap ?? 0,
                            volume24h: coin.totalVolume ?? 0,
                            circulatingSupply: coin.circulatingSupply ?? 0,
                            totalSupply: coin.totalSupply,
                            maxSupply: coin.maxSupply,
                            ath: coin.ath ?? 0,
                            athDate: coin.athDate ?? "",
                            atl: coin.atl ?? 0,
                            atlDate: coin.atlDate ?? "",
                            rank: coin.marketCapRank ?? 0,
                            sparkline7d: coin.sparklineIn7d?.price
                        )
                    }
                    
                    self?.totalMarketCap = coinData.compactMap { $0.marketCap }.reduce(0, +)
                    print("✅ Successfully fetched \(coinData.count) coins")
                    
                } catch {
                    print("❌ Error decoding coins: \(error)")
                }
            }
        }.resume()
    }
    
    func startRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchAllCoins()
        }
    }
    
    func stopRealTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func loadSampleData() {
        cryptoAssets = [
            CryptoAsset(
                id: "bitcoin",
                name: "Bitcoin",
                symbol: "btc",
                currentPrice: 43250.50,
                priceChange24h: 1250.30,
                priceChangePercentage24h: 2.97,
                marketCap: 847500000000,
                volume24h: 25000000000,
                circulatingSupply: 19600000,
                totalSupply: 21000000,
                maxSupply: 21000000,
                ath: 69000,
                athDate: "2021-11-10",
                atl: 67.81,
                atlDate: "2013-07-06",
                rank: 1,
                sparkline7d: generateSampleSparkline()
            ),
            CryptoAsset(
                id: "ethereum",
                name: "Ethereum",
                symbol: "eth",
                currentPrice: 2650.75,
                priceChange24h: 85.20,
                priceChangePercentage24h: 3.32,
                marketCap: 318500000000,
                volume24h: 15000000000,
                circulatingSupply: 120000000,
                totalSupply: nil,
                maxSupply: nil,
                ath: 4878,
                athDate: "2021-11-10",
                atl: 0.43,
                atlDate: "2015-10-20",
                rank: 2,
                sparkline7d: generateSampleSparkline()
            ),
            CryptoAsset(
                id: "solana",
                name: "Solana",
                symbol: "sol",
                currentPrice: 98.75,
                priceChange24h: 5.60,
                priceChangePercentage24h: 6.01,
                marketCap: 43200000000,
                volume24h: 2100000000,
                circulatingSupply: 437000000,
                totalSupply: 570000000,
                maxSupply: nil,
                ath: 259.96,
                athDate: "2021-11-06",
                atl: 0.50,
                atlDate: "2020-05-11",
                rank: 4,
                sparkline7d: generateSampleSparkline()
            ),
            CryptoAsset(
                id: "cardano",
                name: "Cardano",
                symbol: "ada",
                currentPrice: 0.48,
                priceChange24h: 0.02,
                priceChangePercentage24h: 4.32,
                marketCap: 17200000000,
                volume24h: 890000000,
                circulatingSupply: 35800000000,
                totalSupply: 45000000000,
                maxSupply: 45000000000,
                ath: 3.09,
                athDate: "2021-09-02",
                atl: 0.018,
                atlDate: "2020-03-13",
                rank: 8,
                sparkline7d: generateSampleSparkline()
            ),
            CryptoAsset(
                id: "matic-network",
                name: "Polygon",
                symbol: "matic",
                currentPrice: 0.89,
                priceChange24h: 0.04,
                priceChangePercentage24h: 4.71,
                marketCap: 8900000000,
                volume24h: 430000000,
                circulatingSupply: 10000000000,
                totalSupply: 10000000000,
                maxSupply: 10000000000,
                ath: 2.92,
                athDate: "2021-12-27",
                atl: 0.0031,
                atlDate: "2019-05-10",
                rank: 15,
                sparkline7d: generateSampleSparkline()
            )
        ]
        
        totalMarketCap = cryptoAssets.reduce(0) { $0 + $1.marketCap }
    }
    
    private func generateSampleSparkline() -> [Double] {
        var data: [Double] = []
        let basePrice = Double.random(in: 50...100)
        
        for i in 0..<168 {
            let variation = Double.random(in: -5...5)
            let price = max(basePrice + variation + sin(Double(i) * 0.1) * 10, 0.01)
            data.append(price)
        }
        
        return data
    }
}


