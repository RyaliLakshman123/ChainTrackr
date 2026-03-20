//
//  CryptoDetailView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI

struct CryptoDetailView: View {
    let asset: CryptoAsset
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTimeframe: TimeFrame = .oneDay
    @StateObject private var detailService = CryptoDetailService()
    @Environment(\.dismiss) private var dismiss
    
    enum TimeFrame: String, CaseIterable {
        case oneDay = "1 Day"
        case oneWeek = "1 W"
        case oneMonth = "1 M"
        case oneYear = "1 Y"
        case all = "All"
    }
    
    var body: some View {
        ZStack {
            AppGradients.primaryButton
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                priceSection
                chartSection
                timeframeSelector
                actionButtons
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            detailService.loadRealTimeDetailData(for: asset, timeframe: selectedTimeframe)
        }
        .onChange(of: selectedTimeframe) { newTimeframe in
            detailService.loadRealTimeDetailData(for: asset, timeframe: newTimeframe)
        }
    }
    
private var headerSection: some View {
        HStack {
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
            
            Spacer()
            
            // ✅ ADDED: Web-based crypto icon before the text
            HStack(spacing: 8) {
                DirectWebCryptoIconView(symbol: asset.symbol, size: 24)
                
                Text(asset.symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, -60)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var priceSection: some View {
        VStack(spacing: 8) {
            Text("$\(asset.currentPrice, specifier: "%.2f")")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                Image(systemName: asset.priceChange24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 14))
                    .foregroundColor(asset.priceChange24h >= 0 ? .green : .red)
                
                Text("$\(abs(asset.priceChange24h * asset.currentPrice / 100), specifier: "%.2f")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(asset.priceChange24h >= 0 ? .green : .red)
                
                Text("(\(asset.priceChange24h >= 0 ? "+" : "")\(asset.priceChange24h, specifier: "%.2f")%)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(asset.priceChange24h >= 0 ? .green : .red)
            }
        }
        .padding(.top, 20)
    }
    
    private var chartSection: some View {
        VStack(spacing: 16) {
            if detailService.isLoading {
                loadingChartView
            } else {
                enhancedChartView
            }
        }
        .padding(.top, 30)
    }

    private var loadingChartView: some View {
        ZStack {
            // Animated gradient background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.cyan.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            VStack(spacing: 16) {
                // Animated shimmer effect
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.cyan.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(loadingAnimation ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: loadingAnimation
                            )
                    }
                }
                
                Text("Loading beautiful chart...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            loadingAnimation = true
        }
    }

    @State private var loadingAnimation = false

    private var enhancedChartView: some View {
        VStack(spacing: 20) {
            // Time labels with gradient background
            timeLabelsSection
            
            // Main chart container with glassmorphism effect
            chartContainer
                
        }
    }

    private var timeLabelsSection: some View {
        HStack {
            ForEach(Array(detailService.timeLabels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(index == detailService.timeLabels.count - 1 ? .cyan : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 20)
    }

    private var chartContainer: some View {
        ZStack {
            // Glassmorphism background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 0) {
                // Enhanced grid with animated lines
                enhancedGridView
                    .padding(.top, -250)
                // Chart area
                ZStack {
                    // Price labels with better positioning
                    priceLabelsView
                        .padding(.horizontal, -10)
                    // Beautiful chart with animations
                    beautifulChartView
                    
                    // Interactive elements
                    chartInteractionLayer
                }
            }
            .padding(24)
        }
        .frame(height: 340)
        .padding(.horizontal, 20)
    }

    private var enhancedGridView: some View {
        VStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                
                if index < 4 {
                    Spacer()
                }
            }
        }
        .frame(height: 240)
    }

    private var priceLabelsView: some View {
        VStack(spacing: 0) {
            ForEach(detailService.priceLabels.reversed(), id: \.self) { price in
                HStack {
                    Spacer()
                    Text(price)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                }
                
                if price != detailService.priceLabels.first {
                    Spacer()
                }
            }
        }
        .frame(height: 240)
    }

    private var beautifulChartView: some View {
        EnhancedRealTimeChartView(
            priceData: detailService.chartData,
            asset: asset,
            selectedTimeframe: selectedTimeframe
        )
        .frame(height: 220)
        .padding(.trailing, 60)
    }

    private var chartInteractionLayer: some View {
        // Add touch interaction here if needed
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Handle chart interaction
                    }
            )
    }
    
    private var timeframeSelector: some View {
        HStack(spacing: 12) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Button(action: {
                    selectedTimeframe = timeframe
                }) {
                    Text(timeframe.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTimeframe == timeframe ? .black : .white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedTimeframe == timeframe ?
                            Color.cyan : Color.white.opacity(0.1)
                        )
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Text("Buy")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.cyan)
                    .cornerRadius(15)
            }
            
            Button(action: {}) {
                Text("Sell")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .cornerRadius(15)
    }
}

class CryptoDetailService: ObservableObject {
    @Published var chartData: [CryptoPriceData] = []
    @Published var timeLabels: [String] = []
    @Published var priceLabels: [String] = []
    @Published var isLoading = false
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    func loadRealTimeDetailData(for asset: CryptoAsset, timeframe: CryptoDetailView.TimeFrame) {
        isLoading = true
        
        // Use real historical data from API for selected timeframe
        fetchRealTimeframeData(coinId: asset.id, timeframe: timeframe) { [weak self] realData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if !realData.isEmpty {
                    self.chartData = realData
                    print("📊 Loaded \(realData.count) real data points for \(timeframe.rawValue)")
                } else {
                    // Fallback to enhanced simulated data
                    self.chartData = self.generateEnhancedData(for: asset, timeframe: timeframe)
                    print("⚠️ Using enhanced simulated data for \(timeframe.rawValue)")
                }
                
                self.timeLabels = self.generateTimeLabels(for: timeframe)
                self.priceLabels = self.generatePriceLabels(from: self.chartData)
                self.isLoading = false
            }
        }
    }
    
    private func fetchRealTimeframeData(coinId: String, timeframe: CryptoDetailView.TimeFrame, completion: @escaping ([CryptoPriceData]) -> Void) {
        let (days, interval) = getAPIParameters(for: timeframe)
        let url = URL(string: "\(baseURL)/coins/\(coinId)/market_chart?vs_currency=usd&days=\(days)&interval=\(interval)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Real-time detail data error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No detail data received")
                completion([])
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
                } else {
                    completion([])
                }
            } catch {
                print("❌ Detail data parsing error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    private func getAPIParameters(for timeframe: CryptoDetailView.TimeFrame) -> (days: String, interval: String) {
        switch timeframe {
        case .oneDay:
            return ("1", "hourly")
        case .oneWeek:
            return ("7", "hourly")
        case .oneMonth:
            return ("30", "daily")
        case .oneYear:
            return ("365", "daily")
        case .all:
            return ("max", "daily")
        }
    }
    
    private func generateEnhancedData(for asset: CryptoAsset, timeframe: CryptoDetailView.TimeFrame) -> [CryptoPriceData] {
        let numberOfPoints = getNumberOfPoints(for: timeframe)
        let timeInterval = getTimeInterval(for: timeframe)
        
        var newChartData: [CryptoPriceData] = []
        let currentTime = Date()
        
        // Use asset's real price data if available, otherwise generate
        if !asset.priceData.isEmpty && timeframe == .oneDay {
            return asset.priceData
        }
        
        for i in 0..<numberOfPoints {
            let timestamp = currentTime.addingTimeInterval(TimeInterval(-numberOfPoints + i) * timeInterval)
            let timeProgress = Double(i) / Double(numberOfPoints - 1)
            
            // Create more realistic price movement based on timeframe
            let volatilityFactor = getVolatilityFactor(for: timeframe)
            let baseVariation = sin(timeProgress * 4 * .pi) * volatilityFactor
            let trendVariation = timeProgress * 0.05
            let randomVariation = Double.random(in: -0.03...0.03) * volatilityFactor
            
            let price = asset.currentPrice * (1 + baseVariation + trendVariation + randomVariation)
            
            newChartData.append(CryptoPriceData(
                timestamp: timestamp,
                price: max(price, asset.currentPrice * 0.6),
                volume: nil
            ))
        }
        
        return newChartData
    }
    
    private func getVolatilityFactor(for timeframe: CryptoDetailView.TimeFrame) -> Double {
        switch timeframe {
        case .oneDay: return 0.05    // 5% volatility
        case .oneWeek: return 0.15   // 15% volatility
        case .oneMonth: return 0.25  // 25% volatility
        case .oneYear: return 0.50   // 50% volatility
        case .all: return 0.80       // 80% volatility
        }
    }
    
    private func getNumberOfPoints(for timeframe: CryptoDetailView.TimeFrame) -> Int {
        switch timeframe {
        case .oneDay: return 24
        case .oneWeek: return 48
        case .oneMonth: return 60
        case .oneYear: return 100
        case .all: return 120
        }
    }
    
    private func getTimeInterval(for timeframe: CryptoDetailView.TimeFrame) -> TimeInterval {
        switch timeframe {
        case .oneDay: return 3600      // 1 hour
        case .oneWeek: return 10800    // 3 hours
        case .oneMonth: return 43200   // 12 hours
        case .oneYear: return 604800   // 1 week
        case .all: return 2592000      // 1 month
        }
    }
    
    private func generateTimeLabels(for timeframe: CryptoDetailView.TimeFrame) -> [String] {
        let formatter = DateFormatter()
        
        switch timeframe {
        case .oneDay:
            return ["3 AM", "6 AM", "9 AM", "12 PM", "NOW"]
        case .oneWeek:
            formatter.dateFormat = "EEE"
            var labels: [String] = []
            for i in 0..<4 {
                let date = Calendar.current.date(byAdding: .day, value: -6 + i * 2, to: Date()) ?? Date()
                labels.append(formatter.string(from: date))
            }
            labels.append("NOW")
            return labels
        case .oneMonth:
            return ["Week 1", "Week 2", "Week 3", "Week 4", "NOW"]
        case .oneYear:
            return ["Q1", "Q2", "Q3", "Q4", "NOW"]
        case .all:
            return ["2020", "2021", "2022", "2023", "NOW"]
        }
    }
    
    private func generatePriceLabels(from data: [CryptoPriceData]) -> [String] {
        guard !data.isEmpty else { return [] }
        
        let prices = data.map { $0.price }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let range = maxPrice - minPrice
        
        var labels: [String] = []
        for i in 0..<5 {
            let price = minPrice + (range * Double(i) / 4)
            
            // Format price based on value
            if price >= 1000 {
                labels.append("$\(Int(price))")
            } else if price >= 1 {
                labels.append("$\(String(format: "%.1f", price))")
            } else {
                labels.append("$\(String(format: "%.3f", price))")
            }
        }
        
        return labels
    }
}

struct CryptoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoDetailView(asset: CryptoAsset(
            id: "solana",
            name: "Solana",
            symbol: "SOL",
            currentPrice: 248.38,
            priceChange24h: 3.04,
            priceData: [
                CryptoPriceData(timestamp: Date().addingTimeInterval(-86400), price: 240.50, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-82800), price: 235.20, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-79200), price: 238.90, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-75600), price: 242.10, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-72000), price: 245.30, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-68400), price: 243.80, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-64800), price: 246.70, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-61200), price: 244.20, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-57600), price: 247.50, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-54000), price: 249.10, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-50400), price: 251.20, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-46800), price: 248.90, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-43200), price: 250.40, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-39600), price: 252.80, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-36000), price: 250.10, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-32400), price: 248.60, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-28800), price: 246.30, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-25200), price: 244.70, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-21600), price: 247.20, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-18000), price: 249.50, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-14400), price: 251.10, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-10800), price: 248.80, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-7200), price: 246.90, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(-3600), price: 248.38, volume: nil),
                CryptoPriceData(timestamp: Date(), price: 248.38, volume: nil)
            ],
            icon: "solana"
        ))
    }
}

//#Preview {
//    CryptoDetailView(asset: CryptoAsset(
//        id: "solana",
//        name: "Solana",
//        symbol: "SOL", 
//        currentPrice: 248.38,
//        priceChange24h: 3.04,
//        priceData: [
//            CryptoPriceData(timestamp: Date(), price: 240, volume: nil),
//            CryptoPriceData(timestamp: Date().addingTimeInterval(3600), price: 245, volume: nil),
//            CryptoPriceData(timestamp: Date().addingTimeInterval(7200), price: 248, volume: nil)
//        ],
//        icon: "solana"
//    ))
//}
