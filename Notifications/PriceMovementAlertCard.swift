//
//  PriceAlertCard.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 23/07/25.
//

import SwiftUI

// MARK: - Price Movement Alert Card
struct PriceMovementAlertCard: View {
    let crypto: String
    let symbol: String
    let currentPrice: Double
    let priceChange: Double
    let percentageChange: Double
    let alertType: PriceAlertType
    
    var body: some View {
        HStack(spacing: 12) {
            // Alert Icon
            Image(systemName: alertType.icon)
                .font(.system(size: 24))
                .foregroundColor(alertType.color)
                .frame(width: 40, height: 40)
                .background(alertType.color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alertType.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(alertType.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(alertType.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                }
                
                Text("\(crypto) (\(symbol))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", currentPrice))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 2) {
                        Image(systemName: percentageChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10))
                        Text("\(percentageChange >= 0 ? "+" : "")\(String(format: "%.1f", percentageChange))%")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(alertType.color)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(alertType.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Market Highlight Card
struct MarketHighlightCard: View {
    let title: String
    let description: String
    let value: String
    let changePercentage: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: changePercentage >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10))
                    Text("\(changePercentage >= 0 ? "+" : "")\(String(format: "%.1f", changePercentage))%")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(changePercentage >= 0 ? .green : .red)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
        }
        .padding(16)
        .background(AppGradients.cardGradient)
        .cornerRadius(12)
    }
}

// MARK: - Breaking News Banner
struct BreakingNewsBanner: View {
    let title: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Pulsing red dot
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: UUID())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("🚨 BREAKING NEWS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.red.opacity(0.2), Color.red.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Enums
enum PriceAlertType {
    case extremeGain, extremeLoss, nearATH, nearATL, highVolume
    
    var title: String {
        switch self {
        case .extremeGain: return "🚀 EXTREME GAIN"
        case .extremeLoss: return "💥 EXTREME LOSS"
        case .nearATH: return "🎯 NEAR ATH"
        case .nearATL: return "⚠️ NEAR ATL"
        case .highVolume: return "🔥 HIGH VOLUME"
        }
    }
    
    var icon: String {
        switch self {
        case .extremeGain: return "arrow.up.circle.fill"
        case .extremeLoss: return "arrow.down.circle.fill"
        case .nearATH: return "target"
        case .nearATL: return "exclamationmark.triangle.fill"
        case .highVolume: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .extremeGain, .nearATH: return .green
        case .extremeLoss, .nearATL: return .red
        case .highVolume: return .orange
        }
    }
}
