//
//  CoinDetailView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import SwiftUI

struct CoinDetailView: View {
    let crypto: CryptoAsset
    @ObservedObject var cryptoService: RealTimeCryptoService
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTimeframe = "24H"
    
    private let timeframes = ["1H", "24H", "7D", "30D", "1Y"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.primaryButton
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        priceSection
                        chartSection
                        statsSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: crypto.icon)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(crypto.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(crypto.symbol.uppercased())
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            Button(action: {
                // TODO: Add to favorites
            }) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red.opacity(0.8))
            }
        }
        .padding(.top, 10)
    }
    
    private var priceSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(crypto.formattedPrice)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Image(systemName: crypto.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 16))
                        
                        Text(String(format: "%.2f%% (24h)", crypto.priceChangePercentage24h))
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(String(format: "$%.2f", crypto.priceChange24h))
                            .font(.system(size: 14))
                    }
                    .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill((crypto.priceChangePercentage24h >= 0 ? Color.green : Color.red).opacity(0.2))
                    )
                }
                
                Spacer()
                
                Text("#\(crypto.rank)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.cyan.opacity(0.2))
                    )
            }
        }
    }
    
    private var chartSection: some View {
        VStack(spacing: 16) {
            // Timeframe Selector
            HStack(spacing: 8) {
                ForEach(timeframes, id: \.self) { timeframe in
                    Button(action: {
                        selectedTimeframe = timeframe
                    }) {
                        Text(timeframe)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTimeframe == timeframe ? Color.cyan.opacity(0.3) : Color.white.opacity(0.1))
                            )
                    }
                }
                
                Spacer()
            }
            
            // Chart
            if !crypto.priceData.isEmpty {
                DetailedChartView(data: crypto.priceData.map { $0.price }, color: crypto.priceChangePercentage24h >= 0 ? .green : .red)
                    .frame(height: 200)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("Chart data unavailable")
                            .foregroundColor(.white.opacity(0.6))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Statistics")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatRowView(title: "Market Cap", value: crypto.formattedMarketCap)
                StatRowView(title: "Volume (24h)", value: formatVolume(crypto.volume24h))
                StatRowView(title: "Current Price", value: crypto.formattedPrice)
                StatRowView(title: "Price Change", value: String(format: "%.2f%%", crypto.priceChangePercentage24h))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("About \(crypto.name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text("Detailed information about \(crypto.name) (\(crypto.symbol.uppercased())) would be displayed here. This could include project description, use cases, technology details, and recent developments.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000_000 {
            return String(format: "$%.1fB", volume / 1_000_000_000)
        } else if volume >= 1_000_000 {
            return String(format: "$%.1fM", volume / 1_000_000)
        } else {
            return String(format: "$%.0f", volume)
        }
    }
}

struct StatRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct DetailedChartView: View {
    let data: [Double]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            if !data.isEmpty {
                let minValue = data.min() ?? 0
                let maxValue = data.max() ?? 0
                let range = maxValue - minValue
                
                ZStack {
                    // Background grid
                    Path { path in
                        let stepY = geometry.size.height / 4
                        for i in 0...4 {
                            let y = stepY * CGFloat(i)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    
                    // Chart line
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        
                        for (index, value) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
                            let y = geometry.size.height * (1 - normalizedValue)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Fill area under curve
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        
                        for (index, value) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
                            let y = geometry.size.height * (1 - normalizedValue)
                            
                            if index == 0 {
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    CoinDetailView(
        crypto: CryptoAsset(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            currentPrice: 45000,
            priceChange24h: 2.5,
            priceData: [],
            icon: "bitcoin"
        ),
        cryptoService: RealTimeCryptoService()
    )
}
