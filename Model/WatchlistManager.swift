//
//  WatchlistManager.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import SwiftUI
import Foundation

// MARK: - Watchlist Data Model
struct Watchlist: Identifiable, Codable {
    let id = UUID()
    var name: String
    var icon: String
    var coinIds: [String]
    let createdAt: Date
    
    init(name: String, icon: String = "heart.fill", coinIds: [String] = []) {
        self.name = name
        self.icon = icon
        self.coinIds = coinIds
        self.createdAt = Date()
    }
}

// MARK: - Watchlist Manager
class WatchlistManager: ObservableObject {
    @Published var watchlists: [Watchlist] = []
    @Published var activeAlertsCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let watchlistsKey = "SavedWatchlists"
    
    init() {
        loadWatchlists()
    }
    
    func loadWatchlists() {
        if let data = userDefaults.data(forKey: watchlistsKey),
           let decodedWatchlists = try? JSONDecoder().decode([Watchlist].self, from: data) {
            watchlists = decodedWatchlists
        } else {
            // Create default watchlist if none exist
            let defaultWatchlist = Watchlist(
                name: "Favorites",
                icon: "heart.fill",
                coinIds: ["bitcoin", "ethereum"] // Add some default coins
            )
            watchlists.append(defaultWatchlist)
            saveWatchlists()
        }
    }
    
    func createWatchlist(name: String, icon: String) {
        let newWatchlist = Watchlist(name: name, icon: icon)
        watchlists.append(newWatchlist)
        saveWatchlists()
    }
    
    func addCoin(_ coinId: String, to watchlistIndex: Int) {
        guard watchlistIndex < watchlists.count else { return }
        
        if !watchlists[watchlistIndex].coinIds.contains(coinId) {
            watchlists[watchlistIndex].coinIds.append(coinId)
            saveWatchlists()
        }
    }
    
    func removeCoin(_ coinId: String, from watchlistIndex: Int) {
        guard watchlistIndex < watchlists.count else { return }
        
        watchlists[watchlistIndex].coinIds.removeAll { $0 == coinId }
        saveWatchlists()
    }
    
    func deleteWatchlist(at index: Int) {
        guard index < watchlists.count && watchlists.count > 1 else { return }
        watchlists.remove(at: index)
        saveWatchlists()
    }
    
    private func saveWatchlists() {
        if let encodedData = try? JSONEncoder().encode(watchlists) {
            userDefaults.set(encodedData, forKey: watchlistsKey)
            print("💾 Watchlists saved successfully")
        }
    }
}
