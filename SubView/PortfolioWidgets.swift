//
//  PortfolioWidgets.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI

// MARK: - Portfolio Total Value Widget
struct PortfolioTotalValueWidget: View {
    @ObservedObject var cryptoService: CryptoCompareService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("Total Value")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formatTotalValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                    Text("+$2,340")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                    Text("(+10.5%)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
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
    
    private var formatTotalValue: String {
        let totalValue = cryptoService.cryptoAssets.prefix(10).reduce(0) { $0 + $1.currentPrice }
        
        if totalValue >= 1_000_000 {
            return String(format: "$%.1fM", totalValue / 1_000_000)
        } else if totalValue >= 1_000 {
            return String(format: "$%.1fK", totalValue / 1_000)
        } else {
            return String(format: "$%.0f", totalValue)
        }
    }
}

// MARK: - Portfolio Diversification Widget
struct PortfolioDiversificationWidget: View {
    @ObservedObject var cryptoService: CryptoCompareService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.blue)
                Text("Diversification")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                diversificationBar(label: "BTC", percentage: 35, color: .orange)
                diversificationBar(label: "ETH", percentage: 25, color: .blue)
                diversificationBar(label: "Others", percentage: 40, color: .purple)
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
    
    private func diversificationBar(label: String, percentage: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            
            Text("\(percentage)%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Portfolio 24h Change Widget
struct Portfolio24hChangeWidget: View {
    @ObservedObject var cryptoService: CryptoCompareService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.cyan)
                Text("24h Change")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(average24hChange >= 0 ? "+$1,234" : "-$876")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(average24hChange >= 0 ? .green : .red)
                
                Text("\(average24hChange >= 0 ? "+" : "")\(String(format: "%.2f", average24hChange))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(average24hChange >= 0 ? .green : .red)
                
                Text("vs yesterday")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
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
    
    private var average24hChange: Double {
        guard !cryptoService.cryptoAssets.isEmpty else { return 5.03 }
        let topTenAssets = Array(cryptoService.cryptoAssets.prefix(10))
        return topTenAssets.reduce(0) { $0 + $1.priceChangePercentage24h } / Double(topTenAssets.count)
    }
}

// MARK: - Portfolio Top Performer Widget
struct PortfolioTopPerformerWidget: View {
    @ObservedObject var cryptoService: CryptoCompareService
    
    var topPerformer: CryptoAsset? {
        Array(cryptoService.cryptoAssets.prefix(10)).max { $0.priceChangePercentage24h < $1.priceChangePercentage24h }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Top Performer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if let performer = topPerformer {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(getCryptoIcon(for: performer.symbol))
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text(performer.symbol.uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("\(performer.priceChangePercentage24h >= 0 ? "+" : "")\(String(format: "%.2f", performer.priceChangePercentage24h))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("$\(String(format: "%.2f", performer.currentPrice))")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Loading...")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
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
    
    private func getCryptoIcon(for symbol: String) -> String {
        switch symbol.lowercased() {
        case "btc", "bitcoin": return "bitcoin"
        case "eth", "ethereum": return "ethereum"
        case "sol", "solana": return "solana"
        case "ada", "cardano": return "cardano"
        case "matic", "polygon": return "polygon"
        case "avax", "avalanche": return "avalanche"
        case "dot", "polkadot": return "polkadot"
        case "link", "chainlink": return "chainlink"
        default: return "circle.fill"
        }
    }
}
