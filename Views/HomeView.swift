//
//  HomeView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI


// MARK: - Direct Web-Based Crypto Icon View
struct DirectWebCryptoIconView: View {
    let symbol: String
    let size: CGFloat
    @State private var loadFailed = false
    
    var body: some View {
        Group {
            if !loadFailed {
                AsyncImage(url: URL(string: getDirectIconUrl(for: symbol))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 2)
                        
                    case .failure(_):
                        fallbackSymbolView
                            .onAppear {
                                loadFailed = true
                            }
                        
                    case .empty:
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: size, height: size)
                            
                            ProgressView()
                                .scaleEffect(0.6)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        
                    @unknown default:
                        fallbackSymbolView
                    }
                }
            } else {
                fallbackSymbolView
            }
        }
    }
    
    private var fallbackSymbolView: some View {
        ZStack {
            Circle()
                .fill(getCryptoGradient(for: symbol))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(symbol.prefix(2).uppercased())
                .font(.system(size: size * 0.35, weight: .black))
                .foregroundColor(.white)
        }
    }
    
    // Web URLs for crypto icons
    private func getDirectIconUrl(for symbol: String) -> String {
        let symbolLower = symbol.lowercased()
        
        // Use multiple CDN sources for reliability
        switch symbolLower {
        case "btc", "bitcoin":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/btc.png"
        case "eth", "ethereum":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/eth.png"
        case "bnb":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/bnb.png"
        case "xrp":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/xrp.png"
        case "sol", "solana":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/sol.png"
        case "ada", "cardano":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/ada.png"
        case "doge", "dogecoin":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/doge.png"
        case "avax", "avalanche":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/avax.png"
        case "dot", "polkadot":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/dot.png"
        case "matic", "polygon":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/matic.png"
        case "trx", "tron":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/trx.png"
        case "link", "chainlink":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/link.png"
        case "uni", "uniswap":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/uni.png"
        case "ltc", "litecoin":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/ltc.png"
        case "atom", "cosmos":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/atom.png"
        case "algo", "algorand":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/algo.png"
        case "xlm", "stellar":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/xlm.png"
        case "usdt", "tether":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/usdt.png"
        case "usdc":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/usdc.png"
        case "shib":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/shib.png"
        case "near":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/near.png"
        case "ape", "apecoin":
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/ape.png"
        default:
            // Try generic URL for other cryptocurrencies
            return "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/128/color/\(symbolLower).png"
        }
    }
    
    private func getCryptoGradient(for symbol: String) -> LinearGradient {
        let colors = getCryptoColors(for: symbol)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func getCryptoColors(for symbol: String) -> [Color] {
        switch symbol.uppercased() {
        case "BTC": return [Color.orange, Color.yellow]
        case "ETH": return [Color.blue, Color.purple]
        case "BNB": return [Color.yellow, Color.orange]
        case "XRP": return [Color.blue, Color.cyan]
        case "SOL": return [Color.purple, Color.pink]
        case "ADA": return [Color.blue, Color.green]
        case "DOGE": return [Color.yellow, Color.orange]
        case "AVAX": return [Color.red, Color.orange]
        case "DOT": return [Color.pink, Color.purple]
        case "MATIC", "POL": return [Color.purple, Color.blue]
        case "TRX": return [Color.red, Color.pink]
        case "LINK": return [Color.blue, Color.cyan]
        case "UNI": return [Color.pink, Color.purple]
        case "LTC": return [Color.gray, Color.blue]
        case "ATOM": return [Color.purple, Color.blue]
        case "ALGO": return [Color.black, Color.gray]
        case "XLM": return [Color.blue, Color.cyan]
        case "USDT", "USDC": return [Color.green, Color.cyan]
        case "SHIB": return [Color.orange, Color.red]
        case "NEAR": return [Color.black, Color.gray]
        default: return [Color.gray, Color.gray.opacity(0.7)]
        }
    }
}

// MARK: - Real-Time Data Models (Add after existing models)
struct NetworkMetrics {
    let txVolume: String
    let activeAddresses: String
    let avgGasFee: String
    let lastUpdated: Date
}

struct MarketDominanceData {
    let btcDominance: Double
    let ethDominance: Double
    let totalMarketCap: Double
    let lastUpdated: Date
}

struct TopMarketCapResponse: Codable {
    let Data: [MarketCapCoin]
    let MetaData: MetaData
}

struct MarketCapCoin: Codable {
    let CoinInfo: CoinInfo
    let RAW: [String: [String: RawData]]?
}

struct CoinInfo: Codable {
    let Name: String
    let FullName: String
}

struct RawData: Codable {
    let MKTCAP: Double
    let PRICE: Double
    let CHANGEPCT24HOUR: Double
}

struct MetaData: Codable {
    let Count: Int
}

// MARK: - Real-Time Widgets Service
class RealTimeWidgetsService: ObservableObject {
    @Published var marketDominance: MarketDominanceData?
    @Published var networkMetrics: NetworkMetrics?
    @Published var isLoading = false
    
    private let apiKey = ""
    private var updateTimer: Timer?
    
    init() {
        startRealTimeUpdates()
    }
    
    deinit {
        stopUpdates()
    }
    
    // MARK: - 1. Fetch Market Dominance
    func fetchMarketDominance() async throws -> (btc: Double, eth: Double, totalCap: Double) {
        let urlString = "https://min-api.cryptocompare.com/data/top/mktcapfull?limit=50&tsym=USD&api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TopMarketCapResponse.self, from: data)
        
        var totalMarketCap: Double = 0
        var btcMarketCap: Double = 0
        var ethMarketCap: Double = 0
        
        for coin in response.Data {
            if let rawData = coin.RAW?["USD"] {
                let marketCap = rawData["USD"]?.MKTCAP ?? 0
                totalMarketCap += marketCap
                
                if coin.CoinInfo.Name.uppercased() == "BTC" {
                    btcMarketCap = marketCap
                } else if coin.CoinInfo.Name.uppercased() == "ETH" {
                    ethMarketCap = marketCap
                }
            }
        }
        
        let btcDominance = totalMarketCap > 0 ? (btcMarketCap / totalMarketCap) * 100 : 0
        let ethDominance = totalMarketCap > 0 ? (ethMarketCap / totalMarketCap) * 100 : 0
        
        return (btc: btcDominance, eth: ethDominance, totalCap: totalMarketCap)
    }
    
    // MARK: - 2. Fetch Network Metrics
    func fetchNetworkMetrics() async throws -> NetworkMetrics {
        // Fetch ETH gas fees
        let gasURL = "https://min-api.cryptocompare.com/data/blockchain/latest?fsym=ETH&api_key=\(apiKey)"
        
        // Fetch general market data for volume and activity
        let marketURL = "https://min-api.cryptocompare.com/data/top/mktcapfull?limit=10&tsym=USD&api_key=\(apiKey)"
        
        async let gasData = fetchGasData(from: gasURL)
        async let volumeData = fetchVolumeData(from: marketURL)
        
        let (gas, volume) = try await (gasData, volumeData)
        
        return NetworkMetrics(
            txVolume: formatVolume(volume.totalVolume),
            activeAddresses: formatNumber(volume.activeAddresses),
            avgGasFee: "\(gas)gwei",
            lastUpdated: Date()
        )
    }
    
    private func fetchGasData(from urlString: String) async throws -> Int {
        // For demo purposes, we'll simulate gas fees
        // In production, you'd use a service like Etherscan API
        return Int.random(in: 10...50)
    }
    
    private func fetchVolumeData(from urlString: String) async throws -> (totalVolume: Double, activeAddresses: Int) {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TopMarketCapResponse.self, from: data)
        
        var totalVolume: Double = 0
        
        for coin in response.Data.prefix(10) {
            if let rawData = coin.RAW?["USD"] {
                // Note: CryptoCompare doesn't have VOLUME24HOUR in this endpoint
                // We'll calculate based on market cap * estimated turnover
                let marketCap = rawData["USD"]?.MKTCAP ?? 0
                totalVolume += marketCap * 0.05 // Assume 5% daily turnover
            }
        }
        
        let activeAddresses = Int.random(in: 900_000...1_500_000) // Simulated for demo
        
        return (totalVolume: totalVolume, activeAddresses: activeAddresses)
    }
    
    // MARK: - 3. Start Real-Time Updates
    func startRealTimeUpdates() {
        // Initial fetch
        Task {
            await refreshAllData()
        }
        
        // Auto-refresh every 30 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                await self.refreshAllData()
            }
        }
        print("✅ Started real-time widgets updates")
    }
    
    func stopUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
        print("🛑 Stopped real-time widgets updates")
    }
    
    // MARK: - 4. Refresh All Data
    @MainActor
    func refreshAllData() async {
        isLoading = true
        
        do {
            // Fetch market dominance and total market cap
            let (btcDom, ethDom, totalCap) = try await fetchMarketDominance()
            
            // Fetch network metrics
            let networkData = try await fetchNetworkMetrics()
            
            // Update published properties
            self.marketDominance = MarketDominanceData(
                btcDominance: btcDom,
                ethDominance: ethDom,
                totalMarketCap: totalCap,
                lastUpdated: Date()
            )
            
            self.networkMetrics = networkData
            self.isLoading = false
            
            print("🔄 Widgets data refreshed - BTC: \(String(format: "%.1f", btcDom))%, ETH: \(String(format: "%.1f", ethDom))%")
            
        } catch {
            self.isLoading = false
            print("❌ Failed to refresh widgets data: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000_000 {
            return "$\(String(format: "%.1f", volume / 1_000_000_000))B"
        } else if volume >= 1_000_000 {
            return "$\(String(format: "%.1f", volume / 1_000_000))M"
        } else {
            return "$\(String(format: "%.0f", volume))"
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return "\(String(format: "%.1f", Double(number) / 1_000_000))M"
        } else if number >= 1_000 {
            return "\(String(format: "%.1f", Double(number) / 1_000))K"
        } else {
            return "\(number)"
        }
    }
}


struct HomeView: View {
    
    @StateObject private var cryptoService = CryptoCompareService.shared
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                mainScrollView
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showPaywall) {
            MyPaywallView()
        }
        .onAppear {
            print("🚀 HomeView appeared, fetching real crypto data...")
            Task {
                do {
                    _ = try await cryptoService.fetchRealTimePrices()
                } catch {
                    print("❌ Failed to fetch initial crypto data: \(error)")
                }
            }
        }
    }
    
    private var backgroundView: some View {
        AppGradients.primaryButton
            .ignoresSafeArea()
    }
    
    private var mainScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                HeaderView(showPaywall: $showPaywall)
                
                // Updated Balance Card with Bitcoin Price
                RealTimeBitcoinBalanceCardView(cryptoService: cryptoService)
                
                ActionButtonsView()
                
                // Updated Assets View (Top 10 Cryptos, No Plus Button)
                Top10AssetsView(cryptoService: cryptoService)
                
                // New Portfolio Performance Section (Replaces Widgets)
                PortfolioPerformanceSection(cryptoService: cryptoService)
                
                // Market alerts section (unchanged)
                marketAlertsPreviewSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .refreshable {
            Task {
                do {
                    _ = try await cryptoService.fetchRealTimePrices()
                } catch {
                    print("❌ Failed to refresh crypto data: \(error)")
                }
            }
        }
    }
    
    // MARK: - Market Alerts Preview Section (unchanged)
    private var marketAlertsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🚨 Market Alerts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: PriceAlertManagementView()) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.yellow)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if cryptoService.cryptoAssets.contains(where: { abs($0.priceChangePercentage24h) > 15 }) {
                let extremeMovements = cryptoService.cryptoAssets.filter { abs($0.priceChangePercentage24h) > 15 }
                let movementText = extremeMovements.map { "\($0.name) \(String(format: "%.1f", $0.priceChangePercentage24h))%" }.joined(separator: ", ")
                
                BreakingNewsBanner(
                    title: "LIVE: Extreme volatility detected - \(movementText)",
                    time: "Real-time"
                )
                .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cryptoService.cryptoAssets.filter { abs($0.priceChangePercentage24h) > 5 }.prefix(3)) { crypto in
                        NavigationLink(destination: CryptoDetailView(asset: crypto)) {
                            PriceMovementAlertCard(
                                crypto: crypto.name,
                                symbol: crypto.symbol.uppercased(),
                                currentPrice: crypto.currentPrice,
                                priceChange: crypto.priceChange24h,
                                percentageChange: crypto.priceChangePercentage24h,
                                alertType: abs(crypto.priceChangePercentage24h) > 15 ?
                                (crypto.priceChangePercentage24h > 0 ? .extremeGain : .extremeLoss) :
                                    (crypto.priceChangePercentage24h > 0 ? .nearATH : .highVolume)
                            )
                            .frame(width: 280)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h > 0 }.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    Text("Gainers")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h < 0 }.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.red)
                    Text("Losers")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    let avgChange = cryptoService.cryptoAssets.isEmpty ? 0.0 :
                    cryptoService.cryptoAssets.reduce(0) { $0 + $1.priceChangePercentage24h } / Double(cryptoService.cryptoAssets.count)
                    Text("\(avgChange >= 0 ? "+" : "")\(String(format: "%.1f", avgChange))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(avgChange >= 0 ? .green : .red)
                    Text("Avg Change")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(AppGradients.cardGradient)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Header View (unchanged)
struct HeaderView: View {
    @Binding var showPaywall: Bool
    
    var body: some View {
        HStack {
            profileSection
            Spacer()
            notificationButton
        }
        .padding(.top, 10)
    }
    
    private var profileSection: some View {
        HStack(spacing: 12) {
            Image("sameer")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome Back!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Lakshman Ryali")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var notificationButton: some View {
        Button(action: {
            showPaywall = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
            }
        }
    }
}


// MARK: - Action Buttons View (unchanged)
struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: WidgetsDashboardView()) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.cyan)
                    }
                    
                    Text("Widgets")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppGradients.primaryButton)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: MarketOverviewView()) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    Text("Market")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppGradients.primaryButton)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: PriceAlertManagementView()) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    
                    Text("Alerts")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppGradients.primaryButton)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: NewsView()) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "newspaper.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    
                    Text("News")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppGradients.primaryButton)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - NEW Top 10 Assets View (Replaces AssetsView)
struct Top10AssetsView: View {
    @ObservedObject var cryptoService: CryptoCompareService
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("TOP CRYPTOS")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if cryptoService.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                NavigationLink(destination: Top50CryptosView()) {
                    HStack(spacing: 4) {
                        Text("View all")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(cryptoService.cryptoAssets.prefix(10).enumerated()), id: \.element.id) { index, asset in
                    NavigationLink(destination: CryptoDetailView(asset: asset)) {
                        Top10CryptoChartBox(
                            rank: index + 1,
                            asset: asset
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - NEW Top 8 Crypto Chart Box (With Crypto Symbols)
struct Top10CryptoChartBox: View {
    let rank: Int
    let asset: CryptoAsset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text("#\(rank)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    // Show crypto symbol instead of just icon
                    HStack(spacing: 6) {
                        DirectWebCryptoIconView(symbol: asset.symbol, size: 20)
                        
                        Text(asset.symbol.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Show crypto name
                Text(asset.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("$\(formatPrice(asset.currentPrice))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(asset.priceChangePercentage24h >= 0 ? "+" : "")\(String(format: "%.2f", asset.priceChangePercentage24h))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(asset.priceChangePercentage24h >= 0 ? .green : .red)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 50)
                
                if !asset.priceData.isEmpty {
                    RealTimeChartView(
                        priceData: asset.priceData,
                        color: asset.priceChangePercentage24h >= 0 ? .green : .red,
                        showFill: true
                    )
                    .frame(height: 50)
                    .clipped()
                }
            }
        }
        .padding(12)
        .background(AppGradients.primaryButton)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price < 0.01 {
            return String(format: "%.6f", price)
        } else if price < 1 {
            return String(format: "%.4f", price)
        } else if price < 100 {
            return String(format: "%.2f", price)
        } else {
            return String(format: "%.0f", price)
        }
    }
}

//// MARK: - NEW Portfolio Performance Section (Replaces Widgets)
//struct PortfolioPerformanceSection: View {
//    @ObservedObject var cryptoService: CryptoCompareService
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("PORTFOLIO INSIGHTS")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.white.opacity(0.7))
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            LazyVGrid(columns: [
//                GridItem(.flexible(), spacing: 12),
//                GridItem(.flexible(), spacing: 12)
//            ], spacing: 12) {
//                PortfolioTotalValueWidget(cryptoService: cryptoService)
//                PortfolioDiversificationWidget(cryptoService: cryptoService)
//                Portfolio24hChangeWidget(cryptoService: cryptoService)
//                PortfolioTopPerformerWidget(cryptoService: cryptoService)
//            }
//        }
//    }
//}

// 📊 UPDATED CHART BOX COMPONENT - Like the reference image with real data
struct AssetChartBox: View {
    let name: String
    let symbol: String
    let price: String
    let change: String
    let changeColor: Color
    let chartColor: Color
    let icon: String
    let priceData: [CryptoPriceData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and add button
            HStack {
                HStack(spacing: 8) {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    print("Add \(name) to portfolio")
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Price and change
            VStack(alignment: .leading, spacing: 4) {
                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(change)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(changeColor)
            }
            
            // Chart area
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 60)
                
                if !priceData.isEmpty {
                    RealTimeChartView(
                        priceData: priceData,
                        color: chartColor,
                        showFill: true
                    )
                    .frame(height: 60)
                    .clipped()
                } else {
                    // Static chart path
                    Path { path in
                        let width: CGFloat = 120
                        let height: CGFloat = 60
                        let points: [CGFloat] = [0.8, 0.6, 0.4, 0.7, 0.3, 0.5, 0.2, 0.1]
                        
                        for (index, point) in points.enumerated() {
                            let x = (CGFloat(index) / CGFloat(points.count - 1)) * width
                            let y = height - (point * height)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(chartColor, lineWidth: 2)
                    .frame(height: 60)
                }
            }
        }
        .padding(16)
        .background(AppGradients.primaryButton)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// 🔥 NEW WIDGETS SECTION
struct HomeWidgetsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("QUICK WIDGETS")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                TrendingWidget()
                PortfolioPerformanceWidget()
                PriceAlertsWidget()
            }
        }
    }
}

// 📈 ENHANCED MARKET OVERVIEW VIEW - Top 10 Real-Time Cryptos
struct MarketOverviewView: View {
    @StateObject private var cryptoService = CryptoCompareService.shared
    @State private var refreshTimer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppGradients.mainBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("Top 10 Cryptocurrencies")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Real-time prices • Live rankings • Auto-refresh")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        // Live indicator
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(), value: UUID())
                            
                            Text("LIVE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Market Summary Stats
                    marketSummarySection
                    
                    // Top 10 Cryptocurrencies List
                    top10CryptosSection
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
        .onAppear {
            startRealTimeUpdates()
        }
        .onDisappear {
            stopRealTimeUpdates()
        }
        .refreshable {
            await refreshData()
        }
    }
    
    // MARK: - Market Summary Section
    private var marketSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Market Summary")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Updated \(formatTime(Date()))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MarketStatCard(
                    title: "Total Coins",
                    value: "\(cryptoService.cryptoAssets.count)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                MarketStatCard(
                    title: "Gainers",
                    value: "\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h > 0 }.count)",
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
                
                MarketStatCard(
                    title: "Losers",
                    value: "\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h < 0 }.count)",
                    icon: "arrow.down.circle.fill",
                    color: .red
                )
                
                MarketStatCard(
                    title: "Avg Change",
                    value: averageChangeText,
                    icon: "percent",
                    color: averageChangeColor
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Top 10 Cryptos Section
    private var top10CryptosSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🏆 Top 10 Cryptocurrencies")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if cryptoService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .padding(.horizontal, 20)
            
            // Real-time crypto list
            LazyVStack(spacing: 12) {
                ForEach(Array(sortedTop10Cryptos.enumerated()), id: \.element.id) { index, crypto in
                    Top10CryptoRow(
                        rank: index + 1,
                        crypto: crypto,
                        previousRank: getPreviousRank(for: crypto.id)
                    )
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.5), value: crypto.currentPrice)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var sortedTop10Cryptos: [CryptoAsset] {
        cryptoService.cryptoAssets
            .sorted { $0.marketCap > $1.marketCap } // Sort by market cap (real ranking)
            .prefix(10)
            .map { $0 }
    }
    
    private var averageChangeText: String {
        guard !cryptoService.cryptoAssets.isEmpty else { return "0.0%" }
        let avgChange = cryptoService.cryptoAssets.reduce(0) { $0 + $1.priceChangePercentage24h } / Double(cryptoService.cryptoAssets.count)
        return "\(avgChange >= 0 ? "+" : "")\(String(format: "%.1f", avgChange))%"
    }
    
    private var averageChangeColor: Color {
        guard !cryptoService.cryptoAssets.isEmpty else { return .orange }
        let avgChange = cryptoService.cryptoAssets.reduce(0) { $0 + $1.priceChangePercentage24h } / Double(cryptoService.cryptoAssets.count)
        return avgChange >= 0 ? .green : .red
    }
    
    // MARK: - Real-Time Updates
    private func startRealTimeUpdates() {
        // Initial fetch
        Task {
            await refreshData()
        }
        
        // Auto-refresh every 30 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                await refreshData()
            }
        }
        print("✅ Started real-time updates for Top 10 cryptos")
    }
    
    private func stopRealTimeUpdates() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        print("🛑 Stopped real-time updates")
    }
    
    @MainActor
    private func refreshData() async {
        do {
            _ = try await cryptoService.fetchRealTimePrices()
            print("🔄 Top 10 crypto data refreshed")
        } catch {
            print("❌ Failed to refresh Top 10 data: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func getPreviousRank(for coinId: String) -> Int? {
        // This would typically come from stored previous state
        // For now, return nil (you can enhance this later)
        return nil
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Top 10 Crypto Row Component (Updated with Better Symbol Display)
struct Top10CryptoRow: View {
    let rank: Int
    let crypto: CryptoAsset
    let previousRank: Int?
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank with change indicator
            VStack(spacing: 4) {
                Text("#\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // Rank change indicator (if available)
                if let prevRank = previousRank {
                    HStack(spacing: 2) {
                        Image(systemName: rank < prevRank ? "arrow.up" : rank > prevRank ? "arrow.down" : "minus")
                            .font(.system(size: 8))
                            .foregroundColor(rank < prevRank ? .green : rank > prevRank ? .red : .gray)
                    }
                }
            }
            .frame(width: 40)
            
            // Crypto icon, symbol, and name
            HStack(spacing: 12) {
                DirectWebCryptoIconView(symbol: crypto.symbol, size: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(crypto.symbol.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.cyan)
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text(crypto.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Price and change
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(formatPrice(crypto.currentPrice))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: crypto.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10))
                        .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
                    
                    Text("\(crypto.priceChangePercentage24h >= 0 ? "+" : "")\(String(format: "%.2f", crypto.priceChangePercentage24h))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((crypto.priceChangePercentage24h >= 0 ? Color.green : Color.red).opacity(0.15))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // Pulse animation for real-time updates
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.3), value: crypto.currentPrice)
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price < 0.01 {
            return String(format: "%.6f", price)
        } else if price < 1 {
            return String(format: "%.4f", price)
        } else if price < 100 {
            return String(format: "%.2f", price)
        } else {
            return String(format: "%.0f", price)
        }
    }
}

struct TrendingWidget: View {
    @ObservedObject var cryptoService = CryptoCompareService.shared
    
    var trendingCoins: [CryptoAsset] {
        cryptoService.cryptoAssets
            .sorted(by: { abs($0.priceChangePercentage24h) > abs($1.priceChangePercentage24h) })
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            ForEach(trendingCoins) { coin in
                HStack(spacing: 12) {
                    // Icon
                    DirectWebCryptoIconView(symbol: coin.symbol, size: 28)
                    
                    // Name + Price
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coin.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Text("$\(String(format: "%.2f", coin.currentPrice))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // % Change
                    Text("\(coin.priceChangePercentage24h > 0 ? "+" : "")\(String(format: "%.2f", coin.priceChangePercentage24h))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(coin.priceChangePercentage24h > 0 ? .green : .red)
                    
                    // Mini Sparkline
                    if !coin.priceData.isEmpty {
                        RealTimeChartView(
                            priceData: coin.priceData,
                            color: coin.priceChangePercentage24h > 0 ? .green : .red,
                            showFill: false
                        )
                        .frame(width: 50, height: 20)
                    }
                }
                if coin.id != trendingCoins.last?.id {
                    Divider().background(Color.white.opacity(0.1))
                }
            }
        }
    }
}

struct TrendingCoinRow: View {
    let name: String
    let change: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Text(change)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.green)
        }
    }
}



// MARK: - Network Metric Card Component
struct NetworkMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isVisible)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(delay + 0.2), value: isVisible)
            
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(delay + 0.4), value: isVisible)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Enhanced Pro Card Animation
extension View {
    func proCardAnimation() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
            .shadow(color: Color.cyan.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Updated ProWidgetCard with better styling
struct ProWidgetCard<Content: View>: View {
    let title: String
    let subtitle: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                            .shadow(color: color, radius: 4, x: 0, y: 0)
                        
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                        .padding(8)
                        .background(color.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            
            content()
        }
        .padding(20)
    }
}

struct PortfolioPerformanceWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.purple)
                Text("Performance")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("24h")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("+$1,234")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
                
                Text("+5.03%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(AppGradients.primaryButton)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PriceAlertsWidget: View {
    // Example mock alerts
    let alerts = [
        ("BTC", 42000.0, true),
        ("ETH", 3000.0, false),
        ("SOL", 120.0, true)
    ]
    
    var body: some View {
        VStack(spacing: 14) {
            ForEach(alerts, id: \.0) { alert in
                HStack {
                    Circle()
                        .fill(alert.2 ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text("\(alert.0) at $\(String(format: "%.0f", alert.1))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(alert.2 ? "Active" : "Paused")
                        .font(.system(size: 12))
                        .foregroundColor(alert.2 ? .green : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                }
                if alert.0 != alerts.last?.0 {
                    Divider().background(Color.white.opacity(0.1))
                }
            }
        }
    }
}


// MARK: NewsPreviewView
struct NewsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiService = TrackrAIService()
    @State private var newsArticles: [SimpleNewsArticle] = []
    @State private var isLoadingNews = false
    
    var body: some View {
        ZStack {
            // Add background
            AppGradients.mainBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Text("CRYPTO NEWS")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        NavigationLink(destination: NewsView()) {
                            HStack(spacing: 4) {
                                Text("View all")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    
                    if isLoadingNews {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(newsArticles.prefix(3)) { article in
                                SimpleNewsCardView(article: article)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Crypto News")
        .navigationBarTitleDisplayMode(.large)
        // ✅ UPDATED: Proper navigation modifiers
        .navigationBarBackButtonHidden(true)
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
        .onAppear {
            fetchCryptoNews()
        }
    }
    private func fetchCryptoNews() {
        isLoadingNews = true
        
        Task {
            do {
                let newsData = try await fetchNewsFromAPI()
                await MainActor.run {
                    self.newsArticles = newsData
                    self.isLoadingNews = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingNews = false
                    print("Failed to fetch news: \(error)")
                }
            }
        }
    }
    
    private func fetchNewsFromAPI() async throws -> [SimpleNewsArticle] {
        let apiKey = ""
        let urlString = "https://newsapi.org/v2/everything?q=cryptocurrency&apiKey=\(apiKey)&language=en&sortBy=publishedAt&pageSize=5"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let newsResponse = try JSONDecoder().decode(SimpleNewsResponse.self, from: data)
        
        return newsResponse.articles
    }
}

// 📰 Simple News Models (to avoid conflicts)
struct SimpleNewsArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let source: SimpleNewsSource
    
    private enum CodingKeys: String, CodingKey {
        case title, description, url, urlToImage, publishedAt, source
    }
}

struct SimpleNewsSource: Codable {
    let name: String
}

struct SimpleNewsResponse: Codable {
    let articles: [SimpleNewsArticle]
}

struct SimpleNewsCardView: View {
    let article: SimpleNewsArticle
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: article.urlToImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(article.source.name)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(timeAgo(from: article.publishedAt))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(12)
        .background(AppGradients.primaryButton)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onTapGesture {
            if let url = URL(string: article.url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func timeAgo(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "Now" }
        
        let timeInterval = Date().timeIntervalSince(date)
        
        if timeInterval < 3600 {
            return "\(Int(timeInterval / 60))m ago"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval / 3600))h ago"
        } else {
            return "\(Int(timeInterval / 86400))d ago"
        }
    }
}

// 📰 FULL NEWS VIEW - Shows all articles in a sheet
struct FullNewsView: View {
    @StateObject private var newsService = NewsService()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        if newsService.isLoading {
                            ProgressView("Loading latest crypto news...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .foregroundColor(.white)
                                .padding(.top, 50)
                        } else {
                            ForEach(newsService.articles) { article in
                                EnhancedNewsCard(article: article)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Crypto News")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                    .foregroundColor(.white)
            )
        }
        .onAppear {
            newsService.fetchCryptoNews()
        }
    }
}

// 📰 IMPROVED NEWS SERVICE - Gets more articles
class NewsService: ObservableObject {
    @Published var articles: [SimpleNewsArticle] = []
    @Published var isLoading = false
    
    func fetchCryptoNews() {
        isLoading = true
        
        Task {
            do {
                let newsData = try await fetchNewsFromAPI()
                await MainActor.run {
                    self.articles = newsData
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Failed to fetch news: \(error)")
                }
            }
        }
    }
    
    private func fetchNewsFromAPI() async throws -> [SimpleNewsArticle] {
        let apiKey = ""
        // 🔥 INCREASED pageSize to get more articles (was 5, now 20)
        let urlString = "https://newsapi.org/v2/everything?q=cryptocurrency OR bitcoin OR ethereum&apiKey=\(apiKey)&language=en&sortBy=publishedAt&pageSize=20"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let newsResponse = try JSONDecoder().decode(SimpleNewsResponse.self, from: data)
        
        return newsResponse.articles
    }
}

// 📰 NEWS VIEW - Full Screen with Navigation
struct NewsView: View {
    @StateObject private var newsService = EnhancedNewsService()  // 🔄 Changed name
    @State private var selectedCategory = "All"
    @Environment(\.dismiss) private var dismiss
    
    let categories = ["All", "Bitcoin", "Ethereum", "DeFi", "NFT"]
    
    var body: some View {
        ZStack {
            AppGradients.mainBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Category Selector
                categorySelector
                
                // News Content
                newsContent
            }
        }
        .navigationTitle("Crypto News")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
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
        .onAppear {
            newsService.fetchCryptoNews()
        }
        .refreshable {
            newsService.fetchCryptoNews()
        }
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        newsService.fetchNews(for: category)
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                if selectedCategory == category {
                                    AppGradients.primaryButton
                                } else {
                                    Color.white.opacity(0.1)
                                }
                            }
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
    }
    
    private var newsContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if newsService.isLoading {
                    loadingView
                } else if newsService.articles.isEmpty {
                    emptyStateView
                } else {
                    newsArticlesList
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            
            Text("Loading latest crypto news...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 50)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No news available")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Pull to refresh or try a different category")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 50)
    }
    
    private var newsArticlesList: some View {
        ForEach(newsService.articles) { article in
            NavigationLink(destination: NewsDetailView(article: article)) {
                EnhancedNewsCard(article: article)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// 📰 ENHANCED NEWS SERVICE with Categories - RENAMED to avoid conflicts
class EnhancedNewsService: ObservableObject {  // 🔄 New unique name
    @Published var articles: [SimpleNewsArticle] = []
    @Published var isLoading = false
    
    func fetchCryptoNews() {
        fetchNews(for: "All")
    }
    
    func fetchNews(for category: String) {
        isLoading = true
        
        Task {
            do {
                let newsData = try await fetchNewsFromAPI(category: category)
                await MainActor.run {
                    self.articles = newsData
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Failed to fetch news: \(error)")
                }
            }
        }
    }
    
    private func fetchNewsFromAPI(category: String) async throws -> [SimpleNewsArticle] {
        let apiKey = ""
        
        let query: String
        switch category {
        case "Bitcoin":
            query = "bitcoin"
        case "Ethereum":
            query = "ethereum"
        case "DeFi":
            query = "DeFi OR decentralized finance"
        case "NFT":
            query = "NFT OR non-fungible token"
        default:
            query = "cryptocurrency OR bitcoin OR ethereum"
        }
        
        let urlString = "https://newsapi.org/v2/everything?q=\(query)&apiKey=\(apiKey)&language=en&sortBy=publishedAt&pageSize=25"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let newsResponse = try JSONDecoder().decode(SimpleNewsResponse.self, from: data)
        
        return newsResponse.articles
    }
}

// 🚀 ENHANCED NEWS CARD
struct EnhancedNewsCard: View {
    let article: SimpleNewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with source and time
            HStack {
                Text(article.source.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(timeAgo(from: article.publishedAt))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Main content
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                
                AsyncImage(url: URL(string: article.urlToImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.4))
                        )
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
            }
            
            // Action buttons
            HStack {
                Button(action: {
                    // Add to bookmarks
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bookmark")
                        Text("Save")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Button(action: {
                    // Share article
                    shareArticle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                    Text("Read More")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.purple)
            }
        }
        .padding(16)
        .background(AppGradients.cardGradient)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func timeAgo(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "Now" }
        
        let timeInterval = Date().timeIntervalSince(date)
        
        if timeInterval < 3600 {
            return "\(Int(timeInterval / 60))m ago"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval / 3600))h ago"
        } else {
            return "\(Int(timeInterval / 86400))d ago"
        }
    }
    
    private func shareArticle() {
        guard let url = URL(string: article.url) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [article.title, url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// 📖 NEWS DETAIL VIEW
struct NewsDetailView: View {
    let article: SimpleNewsArticle
    
    var body: some View {
        ZStack {
            AppGradients.mainBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image
                    AsyncImage(url: URL(string: article.urlToImage ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
                    .clipped()
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Source and time
                        HStack {
                            Text(article.source.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.cyan)
                            
                            Spacer()
                            
                            Text(timeAgo(from: article.publishedAt))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Title
                        Text(article.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Description
                        if let description = article.description, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        
                        // Read full article button
                        Button(action: {
                            if let url = URL(string: article.url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Read Full Article")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "arrow.up.right")
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(AppGradients.primaryButton)
                            .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func timeAgo(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "Now" }
        
        let timeInterval = Date().timeIntervalSince(date)
        
        if timeInterval < 3600 {
            return "\(Int(timeInterval / 60))m ago"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval / 3600))h ago"
        } else {
            return "\(Int(timeInterval / 86400))d ago"
        }
    }
}


// MARK: - Updated WidgetsDashboardView
struct WidgetsDashboardView: View {
    @StateObject private var cryptoService = CryptoCompareService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppGradients.mainBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    HeroBanner()
                    
                    //StatCardsRow(cryptoService: cryptoService)
                    
                    // 🚀 NEW Real-Time Fear & Greed Widget
                    RealTimeFearGreedWidget()
                    
                    GlobalDominanceWidget(btcDominance: 55.4, ethDominance: 17.8)
                    
                    NetworkActivityWidget(
                        txVolume: "$2.4B",
                        activeAddresses: "1.2M",
                        avgGasFee: "15 gwei"
                    )
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
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
}


// MARK: - ULTRA PRO Hero Banner
struct HeroBanner: View {
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top section with animated elements
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 6, height: 6)
                            .scaleEffect(animateGradient ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(), value: animateGradient)
                        
                        Text("LIVE DASHBOARD")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.cyan)
                            .tracking(1)
                    }
                    
                    Text("Welcome back, Sameer")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Live market indicator
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    Text("Markets Open")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
            }
            
            // Main title with enhanced gradient
            Text("Your Crypto Dashboard")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            .cyan.opacity(0.9),
                            .blue.opacity(0.8),
                            .purple.opacity(0.7)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 0)
            
            // Subtitle with features
            HStack(spacing: 20) {
                FeaturePill(icon: "chart.bar.fill", text: "Real-time", color: .orange)
                FeaturePill(icon: "bell.fill", text: "Alerts", color: .red)
                FeaturePill(icon: "brain.head.profile", text: "AI Insights", color: .purple)
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.cyan.opacity(0.06),
                            Color.blue.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.cyan.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 12)
        .onAppear {
            animateGradient = true
        }
    }
}

// MARK: - ULTRA PRO Stat Card (Remove glass effects)
struct UltraProStatCard: View {
    let title: String
    let subtitle: String
    let value: String
    let change: Double
    let color: Color
    let sparklineData: [CryptoPriceData]?
    let animationDelay: Double
    
    @State private var isVisible = false
    @State private var pulseEffect = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(color)
                            .tracking(0.5)
                        
                        Text(subtitle)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Live indicator
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                        .scaleEffect(pulseEffect ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(), value: pulseEffect)
                }
                
                // Price and change
                VStack(alignment: .leading, spacing: 8) {
                    Text(value)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    HStack(spacing: 6) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text("\(change >= 0 ? "+" : "")\(String(format: "%.2f", change))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text("24h")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background((change >= 0 ? Color.green : Color.red).opacity(0.15))
                    .cornerRadius(8)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Chart section
            if let data = sparklineData, !data.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("24H CHART")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(0.5)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    RealTimeChartView(
                        priceData: data,
                        color: change >= 0 ? .green : .red,
                        showFill: true
                    )
                    .frame(height: 40)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Text("24H CHART")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(0.5)
                        Spacer()
                    }
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 180, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.06),
                            color.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            pulseEffect = true
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(animationDelay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Ultra Pro Widget Card Container (Remove glass effects)
struct UltraProWidgetCard<Content: View>: View {
    let title: String
    let subtitle: String
    let color: Color
    let content: () -> Content
    
    @State private var glowIntensity = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Enhanced header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        // Animated indicator
                        Circle()
                            .fill(color)
                            .frame(width: 10, height: 10)
                            .shadow(color: color, radius: glowIntensity ? 8 : 4, x: 0, y: 0)
                            .animation(.easeInOut(duration: 2).repeatForever(), value: glowIntensity)
                        
                        Text(title)
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, color.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .tracking(0.5)
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Enhanced action button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(color)
                    }
                }
            }
            
            content()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.08),
                            color.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .onAppear {
            glowIntensity = true
        }
    }
}

// MARK: - Ultra Pro Portfolio Card (Remove glass effects, fix alignment)
struct UltraProPortfolioCard: View {
    let title: String
    let value: String
    let change: Double
    let color: Color
    let icon: String
    let subtitle: String?
    
    init(title: String, value: String, change: Double, color: Color, icon: String, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.change = change
        self.color = color
        self.icon = icon
        self.subtitle = subtitle
    }
    
    @State private var isVisible = false
    @State private var iconPulse = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(color)
                        .tracking(0.5)
                    
                    if let sub = subtitle {
                        Text(sub)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                        .scaleEffect(iconPulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(), value: iconPulse)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .scaleEffect(isVisible ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isVisible)
                
                if change != 0.0 {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10))
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text("\(change >= 0 ? "+" : "")\(String(format: "%.1f", change))%")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: isVisible)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading) // Fix alignment
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            color.opacity(0.06),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        .onAppear {
            isVisible = true
            iconPulse = true
        }
    }
}

// MARK: - Fixed Portfolio Performance Section with proper alignment
struct PortfolioPerformanceSection: View {
    @ObservedObject var cryptoService: CryptoCompareService
    
    var body: some View {
        VStack(spacing: 16) {
            Text("PORTFOLIO INSIGHTS")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Fixed grid with proper spacing and alignment
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12, alignment: .top),
                GridItem(.flexible(), spacing: 12, alignment: .top)
            ], spacing: 12) {
                PortfolioTotalValueWidget(cryptoService: cryptoService)
                PortfolioDiversificationWidget(cryptoService: cryptoService)
                Portfolio24hChangeWidget(cryptoService: cryptoService)
                PortfolioTopPerformerWidget(cryptoService: cryptoService)
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - ULTRA PRO Stat Cards Row
struct StatCardsRow: View {
    @ObservedObject var cryptoService: CryptoCompareService
    @State private var cardAnimations: [Bool] = [false, false, false]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                if let btc = cryptoService.cryptoAssets.first(where: { $0.symbol.lowercased() == "btc" }) {
                    UltraProStatCard(
                        title: "BITCOIN",
                        subtitle: "BTC/USD",
                        value: "$\(String(format: "%.0f", btc.currentPrice))",
                        change: btc.priceChangePercentage24h,
                        color: .orange,
                        sparklineData: btc.priceData,
                        animationDelay: 0.1
                    )
                }
                
                if let eth = cryptoService.cryptoAssets.first(where: { $0.symbol.lowercased() == "eth" }) {
                    UltraProStatCard(
                        title: "ETHEREUM",
                        subtitle: "ETH/USD",
                        value: "$\(String(format: "%.0f", eth.currentPrice))",
                        change: eth.priceChangePercentage24h,
                        color: .purple,
                        sparklineData: eth.priceData,
                        animationDelay: 0.2
                    )
                }
                
                UltraProStatCard(
                    title: "MARKET CAP",
                    subtitle: "Total Crypto",
                    value: "$2.8T",
                    change: 3.45,
                    color: .cyan,
                    sparklineData: nil,
                    animationDelay: 0.3
                )
            }
            .padding(.horizontal, 20)
        }
    }
}


// MARK: - ULTRA PRO Global Dominance Widget
struct GlobalDominanceWidget: View {
    let btcDominance: Double
    let ethDominance: Double
    
    @State private var animatedBTCDominance: CGFloat = 0
    @State private var animatedETHDominance: CGFloat = 0
    @State private var rotationEffect = false
    @State private var pulseEffect = false
    
    var body: some View {
        UltraProWidgetCard(
            title: "MARKET DOMINANCE",
            subtitle: "Real-time market share analysis",
            color: .orange
        ) {
            VStack(spacing: 24) {
                // Main dominance circles
                HStack(spacing: 32) {
                    // BTC Dominance
                    VStack(spacing: 16) {
                        ZStack {
                            // Background circles with glow
                            Circle()
                                .stroke(Color.orange.opacity(0.1), lineWidth: 8)
                                .frame(width: 90, height: 90)
                            
                            Circle()
                                .stroke(Color.orange.opacity(0.05), lineWidth: 12)
                                .frame(width: 100, height: 100)
                                .blur(radius: 4)
                            
                            // Animated progress circle
                            Circle()
                                .trim(from: 0, to: animatedBTCDominance)
                                .stroke(
                                    AngularGradient(
                                        colors: [
                                            .orange,
                                            .yellow,
                                            .orange.opacity(0.8),
                                            .orange
                                        ],
                                        center: .center,
                                        startAngle: .degrees(-90),
                                        endAngle: .degrees(270)
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 90, height: 90)
                                .rotationEffect(.degrees(-90))
                                .rotationEffect(.degrees(rotationEffect ? 360 : 0))
                                .animation(.easeInOut(duration: 2), value: animatedBTCDominance)
                                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotationEffect)
                            
                            // Center content
                            VStack(spacing: 4) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                    .scaleEffect(pulseEffect ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 2).repeatForever(), value: pulseEffect)
                                
                                Text("\(String(format: "%.1f", btcDominance))%")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text("BITCOIN")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.orange)
                                .tracking(0.5)
                            
                            Text("Market Leader")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // ETH Dominance
                    VStack(spacing: 16) {
                        ZStack {
                            // Background circles with glow
                            Circle()
                                .stroke(Color.purple.opacity(0.1), lineWidth: 8)
                                .frame(width: 90, height: 90)
                            
                            Circle()
                                .stroke(Color.purple.opacity(0.05), lineWidth: 12)
                                .frame(width: 100, height: 100)
                                .blur(radius: 4)
                            
                            // Animated progress circle
                            Circle()
                                .trim(from: 0, to: animatedETHDominance)
                                .stroke(
                                    AngularGradient(
                                        colors: [
                                            .purple,
                                            .blue,
                                            .purple.opacity(0.8),
                                            .purple
                                        ],
                                        center: .center,
                                        startAngle: .degrees(-90),
                                        endAngle: .degrees(270)
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 90, height: 90)
                                .rotationEffect(.degrees(-90))
                                .rotationEffect(.degrees(rotationEffect ? -360 : 0))
                                .animation(.easeInOut(duration: 2).delay(0.3), value: animatedETHDominance)
                                .animation(.linear(duration: 25).repeatForever(autoreverses: false), value: rotationEffect)
                            
                            // Center content
                            VStack(spacing: 4) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple)
                                    .scaleEffect(pulseEffect ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 2).repeatForever(), value: pulseEffect)
                                
                                Text("\(String(format: "%.1f", ethDominance))%")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text("ETHEREUM")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.purple)
                                .tracking(0.5)
                            
                            Text("Smart Contracts")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                // Enhanced comparison section
                VStack(spacing: 12) {
                    HStack {
                        Text("MARKET COMPARISON")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(0.5)
                        Spacer()
                    }
                    
                    // Animated comparison bars
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: CGFloat(btcDominance / (btcDominance + ethDominance)) * 250, height: 12)
                                .animation(.easeInOut(duration: 1.5).delay(1), value: btcDominance)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .purple.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: CGFloat(ethDominance / (btcDominance + ethDominance)) * 250, height: 12)
                                .animation(.easeInOut(duration: 1.5).delay(1.2), value: ethDominance)
                        }
                        
                        HStack {
                            HStack(spacing: 4) {
                                Circle().fill(.orange).frame(width: 8, height: 8)
                                Text("BTC \(String(format: "%.1f", btcDominance))%")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Circle().fill(.purple).frame(width: 8, height: 8)
                                Text("ETH \(String(format: "%.1f", ethDominance))%")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            pulseEffect = true
            rotationEffect = true
            
            withAnimation(.spring(response: 2.0, dampingFraction: 0.7).delay(0.5)) {
                animatedBTCDominance = CGFloat(btcDominance / 100)
            }
            
            withAnimation(.spring(response: 2.0, dampingFraction: 0.7).delay(0.8)) {
                animatedETHDominance = CGFloat(ethDominance / 100)
            }
        }
    }
}

// MARK: - ULTRA PRO Network Activity Widget
struct NetworkActivityWidget: View {
    let txVolume: String
    let activeAddresses: String
    let avgGasFee: String
    
    @State private var showMetrics = false
    @State private var animateActivity = false
    @State private var pulseWaves = false
    
    var body: some View {
        UltraProWidgetCard(
            title: "NETWORK ACTIVITY",
            subtitle: "Real-time blockchain metrics & performance",
            color: .cyan
        ) {
            VStack(spacing: 20) {
                // Main metrics grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    UltraNetworkMetricCard(
                        title: "Volume",
                        subtitle: "24h",
                        value: txVolume,
                        icon: "arrow.up.arrow.down.circle.fill",
                        color: .cyan,
                        delay: 0.1
                    )
                    
                    UltraNetworkMetricCard(
                        title: "Addresses",
                        subtitle: "Active",
                        value: activeAddresses,
                        icon: "person.3.fill",
                        color: .green,
                        delay: 0.2
                    )
                    
                    UltraNetworkMetricCard(
                        title: "Gas Fee",
                        subtitle: "Average",
                        value: avgGasFee,
                        icon: "fuelpump.fill",
                        color: .orange,
                        delay: 0.3
                    )
                }
                
                // Enhanced activity visualization
                VStack(spacing: 12) {
                    HStack {
                        Text("NETWORK PULSE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(0.5)
                        Spacer()
                        Text("LIVE")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    // Animated wave visualization
                    HStack(spacing: 6) {
                        ForEach(0..<12) { index in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.cyan,
                                            Color.cyan.opacity(0.6),
                                            Color.cyan.opacity(0.3)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 4, height: animateActivity ? CGFloat.random(in: 8...24) : 8)
                                .animation(
                                    .easeInOut(duration: Double.random(in: 0.5...1.5))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.1),
                                    value: animateActivity
                                )
                        }
                    }
                    
                    // Status indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseWaves ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: pulseWaves)
                        
                        Text("Network Status: Optimal")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .onAppear {
            showMetrics = true
            animateActivity = true
            pulseWaves = true
        }
    }
}

// MARK: - Ultra Network Metric Card
struct UltraNetworkMetricCard: View {
    let title: String
    let subtitle: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    @State private var iconAnimation = false
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Glow background
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .blur(radius: 8)
                
                // Main background
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                    .scaleEffect(iconAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: iconAnimation)
            }
            .scaleEffect(isVisible ? 1.0 : 0.5)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay), value: isVisible)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(delay + 0.2), value: isVisible)
                
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(color)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(delay + 0.3), value: isVisible)
                
                Text(subtitle)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(delay + 0.4), value: isVisible)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            isVisible = true
            iconAnimation = true
        }
    }
}

// MARK: - Enhanced Bitcoin Balance Card (Broken into components)
struct RealTimeBitcoinBalanceCardView: View {
    @ObservedObject var cryptoService: CryptoCompareService
    @State private var cardPulse = false
    @State private var priceAnimation = false
    
    var bitcoinAsset: CryptoAsset? {
        cryptoService.cryptoAssets.first { $0.symbol.lowercased() == "btc" || $0.id == "bitcoin" }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            BitcoinHeaderSection(bitcoinAsset: bitcoinAsset, cardPulse: $cardPulse)
            BitcoinPriceSection(bitcoinAsset: bitcoinAsset, priceAnimation: $priceAnimation)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(bitcoinCardBackground)
        .overlay(bitcoinCardOverlay)
        .shadow(color: Color.orange.opacity(0.3), radius: 25, x: 0, y: 15)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .onAppear {
            cardPulse = true
        }
        .onChange(of: bitcoinAsset?.currentPrice) { _ in
            priceAnimation.toggle()
        }
    }
    
    // MARK: - Background Components
    private var bitcoinCardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.orange.opacity(0.08),
                            Color.white.opacity(0.10),
                            Color.orange.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }
    
    private var bitcoinCardOverlay: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.4),
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }
}

// MARK: - Bitcoin Header Section
struct BitcoinHeaderSection: View {
    let bitcoinAsset: CryptoAsset?
    @Binding var cardPulse: Bool
    
    var body: some View {
        HStack {
            BitcoinIconWithGlow(cardPulse: $cardPulse)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("BITCOIN LIVE")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.orange)
                    .tracking(1)
                
                Text("BTC/USD Real-time Price")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if let bitcoin = bitcoinAsset {
                BitcoinChangeIndicator(bitcoin: bitcoin)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(bitcoinHeaderBackground)
    }
    
    private var bitcoinHeaderBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Bitcoin Icon with Glow
struct BitcoinIconWithGlow: View {
    @Binding var cardPulse: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.3))
                .frame(width: 60, height: 60)
                .blur(radius: 15)
                .scaleEffect(cardPulse ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), value: cardPulse)
            
            DirectWebCryptoIconView(symbol: "BTC", size: 44)
                .overlay(bitcoinIconOverlay)
                .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 0)
        }
    }
    
    private var bitcoinIconOverlay: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [.orange, .yellow, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .frame(width: 50, height: 50)
    }
}

// MARK: - Bitcoin Change Indicator
struct BitcoinChangeIndicator: View {
    let bitcoin: CryptoAsset
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: bitcoin.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(changeColor)
                
                Text("\(bitcoin.priceChangePercentage24h >= 0 ? "+" : "")\(String(format: "%.2f", bitcoin.priceChangePercentage24h))%")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(changeColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(changeColor.opacity(0.15))
            .overlay(changeIndicatorOverlay)
            .cornerRadius(10)
            
            Text("24h Change")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private var changeColor: Color {
        bitcoin.priceChangePercentage24h >= 0 ? .green : .red
    }
    
    private var changeIndicatorOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(changeColor.opacity(0.3), lineWidth: 1)
    }
}

// MARK: - Bitcoin Price Section
struct BitcoinPriceSection: View {
    let bitcoinAsset: CryptoAsset?
    @Binding var priceAnimation: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            BitcoinPriceDisplay(bitcoinAsset: bitcoinAsset, priceAnimation: $priceAnimation)
            
            if let bitcoin = bitcoinAsset, !bitcoin.priceData.isEmpty {
                BitcoinChartSection(bitcoin: bitcoin)
            }
        }
    }
}

// MARK: - Bitcoin Price Display
struct BitcoinPriceDisplay: View {
    let bitcoinAsset: CryptoAsset?
    @Binding var priceAnimation: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if let bitcoin = bitcoinAsset {
                Text("$\(String(format: "%.0f", bitcoin.currentPrice))")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(priceGradient)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 0)
                    .scaleEffect(priceAnimation ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: bitcoin.currentPrice)
            } else {
                Text("Loading...")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            ATHIndicator()
            Spacer()
        }
    }
    
    private var priceGradient: LinearGradient {
        LinearGradient(
            colors: [.white, .orange.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - ATH Indicator
struct ATHIndicator: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
                
                Text("ATH")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Text("$73,794")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Bitcoin Chart Section
struct BitcoinChartSection: View {
    let bitcoin: CryptoAsset
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("24H PERFORMANCE CHART")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(0.5)
                
                Spacer()
                
                LiveIndicator()
            }
            
            RealTimeChartView(
                priceData: bitcoin.priceData,
                color: bitcoin.priceChangePercentage24h >= 0 ? .green : .red,
                showFill: true
            )
            .frame(height: 70)
            .background(chartBackground)
            .cornerRadius(12)
        }
    }
    
    private var chartBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.03))
    }
}

// MARK: - Live Indicator
struct LiveIndicator: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.green)
                .frame(width: 6, height: 6)
            Text("LIVE")
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.green)
        }
    }
}




// MARK: - Pro Stat Card with Sparkline
struct ProStatCard: View {
    let title: String
    let value: String
    let color: Color
    let sparklineData: [CryptoPriceData]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            
            if let data = sparklineData, !data.isEmpty {
                RealTimeChartView(priceData: data, color: color, showFill: true)
                    .frame(height: 30)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 160, height: 110)
        .background(AppGradients.cardGradient.blur(radius: 8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}


// MARK: - Enhanced Fear & Greed Index Widget with Real-Time API
struct RealTimeFearGreedWidget: View {
    @State private var sentimentData: MarketSentimentData?
    @State private var isLoading = true
    @State private var animatedScore: CGFloat = 0
    @State private var pulseAnimation = false
    @State private var rotationAnimation = false
    @State private var lastUpdated = Date()
    
    private let cryptoCompareAPIKey = "4fb2defa8c391dd6ad23210eab8d635f4b7389a7ec4b32af0408946502c278e8"
    
    var sentimentColor: Color {
        guard let data = sentimentData else { return .gray }
        switch data.fearGreedScore {
        case 0..<25: return .red
        case 25..<45: return .orange
        case 45..<55: return .yellow
        case 55..<75: return .green
        default: return Color(red: 0, green: 0.8, blue: 0)
        }
    }
    
    var sentimentGradient: LinearGradient {
        LinearGradient(
            colors: [sentimentColor, sentimentColor.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with live indicator
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        // Live indicator
                        Circle()
                            .fill(sentimentColor)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: pulseAnimation)
                        
                        Text("Market Sentiment")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, sentimentColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    HStack(spacing: 6) {
                        Text("LIVE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(sentimentColor)
                            .cornerRadius(4)
                        
                        Text("Fear & Greed Index")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Refresh button
                Button(action: { fetchSentimentData() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(sentimentColor)
                        .padding(8)
                        .background(sentimentColor.opacity(0.15))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(rotationAnimation ? 360 : 0))
                }
            }
            
            Spacer()
            
            if isLoading {
                loadingView
            } else if let data = sentimentData {
                mainSentimentView(data: data)
            } else {
                errorView
            }
            
            Spacer()
            
            // Bottom stats
            if let data = sentimentData {
                bottomStatsView(data: data)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            sentimentColor.opacity(0.4),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: sentimentColor.opacity(0.3), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .onAppear {
            pulseAnimation = true
            fetchSentimentData()
            startRealTimeUpdates()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotationAnimation ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotationAnimation)
                
                VStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(.cyan)
                    Text("Loading...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .onAppear { rotationAnimation = true }
        }
    }
    
    // MARK: - Main Sentiment View
    private func mainSentimentView(data: MarketSentimentData) -> some View {
        VStack(spacing: 24) {
            // Main Fear & Greed Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                // Animated progress circle
                Circle()
                    .trim(from: 0, to: animatedScore)
                    .stroke(
                        AngularGradient(
                            colors: [sentimentColor, sentimentColor.opacity(0.8), sentimentColor],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.5, dampingFraction: 0.8), value: animatedScore)
                
                // Inner glow effect
                Circle()
                    .fill(sentimentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                // Score and sentiment
                VStack(spacing: 8) {
                    Text("\(data.fearGreedScore)")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, sentimentColor.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: sentimentColor.opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    Text(data.socialSentiment)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(sentimentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(sentimentColor.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Sentiment explanation
            sentimentExplanationView(score: data.fearGreedScore)
        }
        .onAppear {
            withAnimation(.spring(response: 2.0, dampingFraction: 0.7).delay(0.5)) {
                animatedScore = CGFloat(data.fearGreedScore) / 100
            }
        }
    }
    
    // MARK: - Sentiment Explanation
    private func sentimentExplanationView(score: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                SentimentIndicator(title: "Extreme Fear", range: "0-24", isActive: score < 25, color: .red)
                SentimentIndicator(title: "Fear", range: "25-44", isActive: score >= 25 && score < 45, color: .orange)
                SentimentIndicator(title: "Neutral", range: "45-54", isActive: score >= 45 && score < 55, color: .yellow)
                SentimentIndicator(title: "Greed", range: "55-74", isActive: score >= 55 && score < 75, color: .green)
                SentimentIndicator(title: "Extreme Greed", range: "75-100", isActive: score >= 75, color: Color(red: 0, green: 0.8, blue: 0))
            }
            
            // Market insight based on score
            Text(getMarketInsight(score: score))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Bottom Stats
    private func bottomStatsView(data: MarketSentimentData) -> some View {
        HStack(spacing: 16) {
            StatPill(
                title: "BTC Volatility",
                value: "\(String(format: "%.1f", data.btcVolatility))%",
                icon: "waveform.path.ecg",
                color: data.btcVolatility > 5 ? .red : .green
            )
            
            StatPill(
                title: "Market Momentum",
                value: "\(data.marketMomentum >= 0 ? "+" : "")\(String(format: "%.1f", data.marketMomentum))%",
                icon: "arrow.up.right",
                color: data.marketMomentum >= 0 ? .green : .red
            )
            
            StatPill(
                title: "Updated",
                value: timeAgo(from: data.lastUpdated),
                icon: "clock",
                color: .cyan
            )
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text("Failed to load sentiment data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Button("Retry") {
                fetchSentimentData()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(8)
        }
    }
    
    // MARK: - API Functions
    private func fetchSentimentData() {
        isLoading = true
        
        withAnimation(.easeInOut(duration: 0.5)) {
            rotationAnimation = true
        }
        
        Task {
            do {
                let fearGreedScore = try await fetchFearGreedIndex()
                let btcData = try await fetchMarketIndicators(symbol: "BTC")
                let ethData = try await fetchMarketIndicators(symbol: "ETH")
                
                let sentimentData = MarketSentimentData(
                    fearGreedScore: fearGreedScore,
                    btcVolatility: btcData.volatility,
                    ethVolatility: ethData.volatility,
                    marketMomentum: calculateMarketMomentum(btc: btcData, eth: ethData),
                    socialSentiment: calculateSocialSentiment(fearGreed: fearGreedScore),
                    lastUpdated: Date()
                )
                
                await MainActor.run {
                    self.sentimentData = sentimentData
                    self.isLoading = false
                    self.lastUpdated = Date()
                    
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                        self.animatedScore = CGFloat(fearGreedScore) / 100
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        rotationAnimation = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("❌ Failed to fetch sentiment data: \(error)")
                    rotationAnimation = false
                }
            }
        }
    }
    
    private func fetchFearGreedIndex() async throws -> Int {
        let urlString = "https://api.alternative.me/fng/"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FearGreedResponse.self, from: data)
        
        return Int(response.data[0].value) ?? 50
    }
    
    private func fetchMarketIndicators(symbol: String) async throws -> MarketIndicators {
        let baseURL = "https://min-api.cryptocompare.com/data"
        let statsURL = "\(baseURL)/pricemultifull?fsyms=\(symbol)&tsyms=USD&api_key=\(cryptoCompareAPIKey)"
        
        guard let url = URL(string: statsURL) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PriceMultiFullResponse.self, from: data)
        
        let coinData = response.RAW[symbol]?["USD"]
        let change24h = coinData?.CHANGEPCT24HOUR ?? 0
        let volume24h = coinData?.VOLUME24HOUR ?? 0
        let high24h = coinData?.HIGH24HOUR ?? 0
        let low24h = coinData?.LOW24HOUR ?? 0
        let price = coinData?.PRICE ?? 0
        
        let volatility = high24h > 0 ? ((high24h - low24h) / price) * 100 : 0
        
        return MarketIndicators(
            symbol: symbol,
            change24h: change24h,
            volume24h: volume24h,
            volatility: volatility,
            price: price
        )
    }
    
    private func calculateMarketMomentum(btc: MarketIndicators, eth: MarketIndicators) -> Double {
        return (btc.change24h * 0.6) + (eth.change24h * 0.4)
    }
    
    private func calculateSocialSentiment(fearGreed: Int) -> String {
        switch fearGreed {
        case 0..<25: return "Extreme Fear"
        case 25..<45: return "Fear"
        case 45..<55: return "Neutral"
        case 55..<75: return "Greed"
        default: return "Extreme Greed"
        }
    }
    
    private func startRealTimeUpdates() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            fetchSentimentData()
        }
    }
    
    // MARK: - Helper Functions
    private func getMarketInsight(score: Int) -> String {
        switch score {
        case 0..<25:
            return "Market shows extreme fear. This could be a buying opportunity as investors may be overselling."
        case 25..<45:
            return "Market sentiment is fearful. Caution is advised, but some opportunities may emerge."
        case 45..<55:
            return "Market sentiment is neutral. Balanced approach recommended for trading decisions."
        case 55..<75:
            return "Market shows greed. Be cautious of overvalued assets and consider taking profits."
        default:
            return "Extreme greed detected. Market may be due for a correction. Consider defensive strategies."
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
}

// MARK: - Supporting Components
struct SentimentIndicator: View {
    let title: String
    let range: String
    let isActive: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? color : Color.white.opacity(0.2))
                .frame(width: 8, height: 8)
                .scaleEffect(isActive ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isActive)
            
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(isActive ? color : .white.opacity(0.5))
            
            Text(range)
                .font(.system(size: 8, weight: .regular))
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

struct StatPill: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Data Models (Add these if not already present)
struct MarketSentimentData {
    let fearGreedScore: Int
    let btcVolatility: Double
    let ethVolatility: Double
    let marketMomentum: Double
    let socialSentiment: String
    let lastUpdated: Date
}

struct MarketIndicators {
    let symbol: String
    let change24h: Double
    let volume24h: Double
    let volatility: Double
    let price: Double
}

struct FearGreedResponse: Codable {
    let data: [FearGreedData]
}

struct FearGreedData: Codable {
    let value: String
    let value_classification: String
    let timestamp: String
    let time_until_update: String?
}

struct PriceMultiFullResponse: Codable {
    let RAW: [String: [String: CoinData]]
}

struct CoinData: Codable {
    let PRICE: Double
    let CHANGEPCT24HOUR: Double
    let VOLUME24HOUR: Double
    let HIGH24HOUR: Double
    let LOW24HOUR: Double
    let LASTUPDATE: Int
}




// Reusable metric card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
}


// MARK: - Stat Card with Sparkline
struct StatCardWithSparkline: View {
    let title: String
    let value: String
    let color: Color
    let sparklineData: [CryptoPriceData]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            if let data = sparklineData, !data.isEmpty {
                RealTimeChartView(
                    priceData: data,
                    color: color,
                    showFill: true
                )
                .frame(height: 30)
                .cornerRadius(6)
            }
        }
        .padding()
        .frame(width: 160, height: 100)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}

// MARK: - Basic Stat Card (No Sparkline)
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
        }
        .padding()
        .frame(width: 140, height: 80)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}

// MARK: - Modern Widget Card
struct ModernWidgetCard<Content: View>: View {
    let title: String
    let subtitle: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            content()
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}


// Market Stat Card Component
struct MarketStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(PurchaseManager())
    }
}
