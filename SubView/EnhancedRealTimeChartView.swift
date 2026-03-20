//
//  EnhancedRealTimeChartView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import SwiftUI

struct EnhancedRealTimeChartView: View {
    let priceData: [CryptoPriceData]
    let asset: CryptoAsset
    let selectedTimeframe: CryptoDetailView.TimeFrame
    
    @State private var animationProgress: CGFloat = 0
    @State private var showGradient = false
    @State private var pulseAnimation = false
    @State private var trendPulse = false
    @State private var particleAnimation = false
    @State private var glowIntensity: Double = 0.5
    @State private var pricePopAnimations: [Bool] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Beautiful static background
                staticBackgroundElements(geometry: geometry)
                
                // Main chart elements
                chartElements(geometry: geometry)
                
                // Clean overlay effects
                cleanOverlayEffects(geometry: geometry)
            }
        }
        .onAppear {
            initializeAnimations()
            startStunningAnimations()
        }
        .onDisappear {
            stopAnimations()
        }
        .onChange(of: selectedTimeframe) { _ in
            restartAllAnimations()
        }
    }
    
    // MARK: - Static Background Elements (No Moving Waves)
    private func staticBackgroundElements(geometry: GeometryProxy) -> some View {
        ZStack {
            
            // Elegant grid lines
            elegantGridBackground(geometry: geometry)
        }
    }
    
    // MARK: - Chart Elements
    private func chartElements(geometry: GeometryProxy) -> some View {
        ZStack {
            // Rainbow gradient fill
            if showGradient {
                rainbowGradientFill(geometry: geometry)
            }
            
            // Multi-layer glowing lines
            multiLayerChartLines(geometry: geometry)
            
            // Beautiful data points
            enhancedDataPoints(geometry: geometry)
        }
    }
    
    // MARK: - Clean Overlay Effects (No Sparkles)
    private func cleanOverlayEffects(geometry: GeometryProxy) -> some View {
        ZStack {
            // Floating price indicators
            floatingPriceIndicators(geometry: geometry)
            
            // Premium trend indicator
            //premiumTrendIndicator(geometry: geometry)
            
            // Subtle holographic overlay
            subtleHolographicOverlay(geometry: geometry)
        }
    }
    
    
    
    // MARK: - Elegant Grid Background
    private func elegantGridBackground(geometry: GeometryProxy) -> some View {
        ZStack {
            // Horizontal grid lines
            ForEach(0..<5, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * CGFloat(index) / 4
                    )
            }
        }
    }
    
    // MARK: - Rainbow Gradient Fill
    private func rainbowGradientFill(geometry: GeometryProxy) -> some View {
        let fillPath = createFillPath(geometry: geometry)
        
        return fillPath
            .fill(
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.4),
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.2),
                        Color.pink.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .scaleEffect(x: animationProgress, y: 1, anchor: .leading)
            )
    }
    
    // MARK: - Multi-Layer Chart Lines
    private func multiLayerChartLines(geometry: GeometryProxy) -> some View {
        let path = createPath(geometry: geometry)
        
        return ZStack {
            // Outer glow
            path
                .stroke(
                    RadialGradient(
                        colors: [
                            (asset.priceChange24h >= 0 ? Color.cyan : Color.red).opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: 8)
                .opacity(glowIntensity)
            
            // Middle glow
            path
                .stroke(
                    (asset.priceChange24h >= 0 ? Color.cyan : Color.red).opacity(0.4),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: 3)
            
            // Main line with gradient
            path
                .trim(from: 0, to: animationProgress)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white,
                            asset.priceChange24h >= 0 ? Color.cyan : Color.red,
                            asset.priceChange24h >= 0 ? Color.blue : Color.orange,
                            Color.purple.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: asset.priceChange24h >= 0 ? .cyan : .red, radius: 5)
            
            // Top highlight line
            path
                .trim(from: 0, to: animationProgress)
                .stroke(
                    Color.white.opacity(0.8),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round)
                )
        }
    }
    
    // MARK: - Enhanced Data Points
    private func enhancedDataPoints(geometry: GeometryProxy) -> some View {
        ForEach(Array(priceData.enumerated()), id: \.offset) { index, dataPoint in
            let point = getPoint(at: index, geometry: geometry)
            let shouldShow = CGFloat(index) / CGFloat(max(priceData.count - 1, 1)) <= animationProgress
            let isKeyPoint = index % max(priceData.count / 6, 1) == 0
            
            if shouldShow && isKeyPoint {
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white, Color.cyan, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 16, height: 16)
                        .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                        .opacity(pulseAnimation ? 0.3 : 0.8)
                    
                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white,
                                    asset.priceChange24h >= 0 ? Color.cyan : Color.red,
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 8, height: 8)
                        .blur(radius: 2)
                    
                    
                    // Core point
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .shadow(color: .cyan, radius: 3)
                }
                .position(point)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                    value: pulseAnimation
                )
                
            }
        }
    }
    
    // MARK: - Floating Price Indicators
    private func floatingPriceIndicators(geometry: GeometryProxy) -> some View {
        ForEach(Array(priceData.enumerated()), id: \.offset) { index, dataPoint in
            let point = getPoint(at: index, geometry: geometry)
            let shouldShow = CGFloat(index) / CGFloat(max(priceData.count - 1, 1)) <= animationProgress
            let isImportantPoint = index % max(priceData.count / 4, 1) == 0 && index > 0
            
            if shouldShow && isImportantPoint && index < pricePopAnimations.count {
                VStack {
                    Text("$\(dataPoint.price, specifier: "%.2f")")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.8))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.cyan, lineWidth: 1)
                                )
                        )
                        .scaleEffect(pricePopAnimations[index] ? 1.0 : 0.0)
                        .opacity(pricePopAnimations[index] ? 1.0 : 0.0)
                    
                    // Connection line
                    Rectangle()
                        .fill(Color.cyan.opacity(0.6))
                        .frame(width: 1, height: 15)
                        .scaleEffect(y: pricePopAnimations[index] ? 1.0 : 0.0, anchor: .bottom)
                }
                .position(x: point.x, y: point.y - 25)
                .animation(
                    Animation.spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                    value: pricePopAnimations[index]
                )
            }
        }
    }
    
//    // MARK: - Premium Trend Indicator
//    private func premiumTrendIndicator(geometry: GeometryProxy) -> some View {
//        VStack {
//            HStack {x
//                Spacer()
//                
//                ZStack {
//                    // Outer ring with rotation
//                    Circle()
//                        .stroke(
//                            LinearGradient(
//                                colors: [Color.cyan, Color.blue, Color.purple, Color.cyan],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            ),
//                            lineWidth: 3
//                        )
//                        .frame(width: 50, height: 50)
//                        .rotationEffect(.degrees(trendPulse ? 360 : 0))
//                        .animation(
//                            Animation.linear(duration: 4)
//                                .repeatForever(autoreverses: false),
//                            value: trendPulse
//                        )
//                    
//                    // Inner glow
////                    Circle()
////                        .fill(
////                            RadialGradient(
////                                colors: [
////                                    Color.black.opacity(0.8),
////                                    Color.cyan.opacity(0.2)
////                                ],
////                                center: .center,
////                                startRadius: 0,
////                                endRadius: 25
////                            )
////                        )
////                        .frame(width: 40, height: 40)
//                        //.padding(.top, -190)
//
//                    // Trend arrow
////                    Image(systemName: asset.priceChange24h >= 0 ? "arrow.up.right" : "arrow.down.right")
////                        .font(.system(size: 20, weight: .bold))
////                        .foregroundColor(.white)
////                        .scaleEffect(trendPulse ? 1.2 : 1.0)
////                        .animation(
////                            Animation.easeInOut(duration: 1.5)
////                                .repeatForever(autoreverses: true),
////                            value: trendPulse
////                        )
//                }
//            }
//            Spacer()
//        }
//        .padding(.top, 10)
//        .padding(.trailing, 10)
//    }
//    
    // MARK: - Subtle Holographic Overlay
    private func subtleHolographicOverlay(geometry: GeometryProxy) -> some View {
        LinearGradient(
            colors: [
                Color.clear,
                Color.cyan.opacity(0.05),
                Color.blue.opacity(0.03),
                Color.purple.opacity(0.02),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .mask(
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 1)
        )
    }
    
    // MARK: - Animation Functions
    private func initializeAnimations() {
        pricePopAnimations = Array(repeating: false, count: priceData.count)
    }
    
    private func startStunningAnimations() {
        // Main animation sequence
        withAnimation(.easeInOut(duration: 2.5)) {
            animationProgress = 1.0
        }
        
        // Staggered effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showGradient = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            particleAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pulseAnimation = true
            trendPulse = true
        }
        
        // Animate price pops with delay
        for index in 0..<pricePopAnimations.count {
            if index % max(priceData.count / 4, 1) == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(index) * 0.1) {
                    if index < pricePopAnimations.count {
                        pricePopAnimations[index] = true
                    }
                }
            }
        }
        
        // Glow pulsing
        animationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                glowIntensity = glowIntensity == 0.5 ? 1.0 : 0.5
            }
        }
    }
    
    private func stopAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func restartAllAnimations() {
        stopAnimations()
        
        // Reset all animations
        animationProgress = 0
        showGradient = false
        particleAnimation = false
        pulseAnimation = false
        trendPulse = false
        pricePopAnimations = Array(repeating: false, count: priceData.count)
        
        // Restart
        startStunningAnimations()
    }
    
    // MARK: - Path Creation
    private func createPath(geometry: GeometryProxy) -> Path {
        var path = Path()
        guard !priceData.isEmpty else { return path }
        
        let firstPoint = getPoint(at: 0, geometry: geometry)
        path.move(to: firstPoint)
        
        for index in 1..<priceData.count {
            let point = getPoint(at: index, geometry: geometry)
            path.addLine(to: point)
        }
        
        return path
    }
    
    private func createFillPath(geometry: GeometryProxy) -> Path {
        var path = createPath(geometry: geometry)
        guard !priceData.isEmpty else { return path }
        
        let lastPoint = getPoint(at: priceData.count - 1, geometry: geometry)
        let firstPoint = getPoint(at: 0, geometry: geometry)
        
        path.addLine(to: CGPoint(x: lastPoint.x, y: geometry.size.height))
        path.addLine(to: CGPoint(x: firstPoint.x, y: geometry.size.height))
        path.closeSubpath()
        
        return path
    }
    
    private func getPoint(at index: Int, geometry: GeometryProxy) -> CGPoint {
        guard !priceData.isEmpty else { return .zero }
        
        let prices = priceData.map { $0.price }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let priceRange = maxPrice - minPrice
        
        let x = geometry.size.width * CGFloat(index) / CGFloat(max(priceData.count - 1, 1))
        let normalizedPrice = priceRange > 0 ? (priceData[index].price - minPrice) / priceRange : 0.5
        let y = geometry.size.height * (1 - normalizedPrice)
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Preview
#Preview {
    EnhancedRealTimeChartView(
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
        asset: CryptoAsset(
            id: "solana",
            name: "Solana",
            symbol: "SOL",
            currentPrice: 248.38,
            priceChange24h: 3.04,
            priceData: [],
            icon: "solana"
        ),
        selectedTimeframe: .oneDay
    )
    .frame(height: 250)
    .background(Color.black)
}

