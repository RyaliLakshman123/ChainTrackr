//
//  AddCoinToWatchlistView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import SwiftUI

struct AddCoinToWatchlistView: View {
    @ObservedObject var watchlistManager: WatchlistManager
    let selectedListIndex: Int
    @StateObject private var cryptoService = RealTimeCryptoService()
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    private var filteredCryptos: [CryptoAsset] {
        if searchText.isEmpty {
            return cryptoService.cryptoAssets
        } else {
            return cryptoService.cryptoAssets.filter { crypto in
                crypto.name.localizedCaseInsensitiveContains(searchText) ||
                crypto.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.primaryButton
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Search cryptocurrencies...", text: $searchText)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Coins List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCryptos) { crypto in
                                AddCoinRow(
                                    crypto: crypto,
                                    isAdded: isAlreadyAdded(crypto.id),
                                    onAdd: {
                                        addCoin(crypto.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Add Cryptocurrency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            cryptoService.fetchInitialData()
        }
    }
    
    private func isAlreadyAdded(_ coinId: String) -> Bool {
        guard selectedListIndex < watchlistManager.watchlists.count else { return false }
        return watchlistManager.watchlists[selectedListIndex].coinIds.contains(coinId)
    }
    
    private func addCoin(_ coinId: String) {
        watchlistManager.addCoin(coinId, to: selectedListIndex)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

struct AddCoinRow: View {
    let crypto: CryptoAsset
    let isAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(crypto.icon)
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(crypto.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(crypto.symbol.uppercased())
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(crypto.currentPrice, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: crypto.priceChange24h >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12))
                    
                    Text("\(crypto.priceChange24h >= 0 ? "+" : "")\(crypto.priceChange24h, specifier: "%.2f")%")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(crypto.priceChange24h >= 0 ? .green : .red)
            }
            
            Button(action: onAdd) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(isAdded ? .green : .cyan)
            }
            .disabled(isAdded)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AddCoinToWatchlistView(
        watchlistManager: WatchlistManager(),
        selectedListIndex: 0
    )
}
