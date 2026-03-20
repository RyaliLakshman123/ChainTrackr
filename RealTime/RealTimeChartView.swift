//
//  RealTimeChartView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//


import SwiftUI

struct RealTimeChartView: View {
    let priceData: [CryptoPriceData]
    let color: Color
    let showFill: Bool 
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showFill {
                    // Fill area under the line
                    chartPath(in: geometry.size, fillArea: true)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .animation(.easeInOut(duration: 1.0), value: priceData.count)
                }
                
                // Chart line
                chartPath(in: geometry.size, fillArea: false)
                    .trim(from: 0, to: animationProgress)
                    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .animation(.easeInOut(duration: 1.0), value: animationProgress)
            }
        }
        .onAppear {
            animationProgress = 1.0 
        }
        .onChange(of: priceData.count) { _ in
            // Re-animate when new data arrives
            animationProgress = 0
            withAnimation(.easeInOut(duration: 0.5)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func chartPath(in size: CGSize, fillArea: Bool) -> Path {
        Path { path in
            guard priceData.count > 1 else { return }
            
            let prices = priceData.map { $0.price }
            let minPrice = prices.min() ?? 0
            let maxPrice = prices.max() ?? 1
            let priceRange = maxPrice - minPrice
            
            guard priceRange > 0 else { return }
            
            let stepX = size.width / CGFloat(priceData.count - 1)
            
            for (index, pricePoint) in priceData.enumerated() {
                let x = CGFloat(index) * stepX
                let normalizedPrice = (pricePoint.price - minPrice) / priceRange
                let y = size.height - (CGFloat(normalizedPrice) * size.height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            if fillArea {
                // Close the path for fill area
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.closeSubpath()
            }
        }
    }
}

struct RealTimeChartView_Previews: PreviewProvider {
    static var previews: some View { 
        RealTimeChartView(
            priceData: [
                CryptoPriceData(timestamp: Date(), price: 45000, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(3600), price: 46000, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(7200), price: 45500, volume: nil),
                CryptoPriceData(timestamp: Date().addingTimeInterval(10800), price: 47000, volume: nil)
            ],
            color: .green,
            showFill: true
        )
        .frame(width: 200, height: 100)
        .background(Color.black)
    }
}
