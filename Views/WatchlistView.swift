//
//  WatchlistView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import SwiftUI

struct WatchlistView: View {
    @StateObject private var watchlistManager = WatchlistManager()
    @StateObject private var cryptoService = RealTimeCryptoService()
    @StateObject private var converterService = CryptoConverterService()
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    @State private var selectedWatchlist = 0
    @State private var showCreateListSheet = false
    @State private var showPaywall = false
    @State private var selectedCoin: CryptoAsset?
    @State private var showCoinDetail = false
    
    // Add coins state
    @State private var isAddingCoins = false
    @State private var searchText = ""
    @State private var selectedCategory = "Trending"
    
    // Converter state - Fixed currencies
    @State private var showConverter = false
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "INR"
    @State private var fromAmount = "1"
    @State private var showFromPicker = false
    @State private var showToPicker = false
    
    private let categories = ["Trending", "Top 50", "DeFi", "Gaming", "Metaverse", "AI"]
    
    // Available currencies for conversion
    private let availableCurrencies = [
        CurrencyOption(code: "USD", name: "US Dollar", icon: "https://flagcdn.com/w40/us.png", isCrypto: false),
        CurrencyOption(code: "INR", name: "Indian Rupee", icon: "https://flagcdn.com/w40/in.png", isCrypto: false),
        CurrencyOption(code: "EUR", name: "Euro", icon: "https://flagcdn.com/w40/eu.png", isCrypto: false),
        CurrencyOption(code: "GBP", name: "British Pound", icon: "https://flagcdn.com/w40/gb.png", isCrypto: false),
        CurrencyOption(code: "JPY", name: "Japanese Yen", icon: "https://flagcdn.com/w40/jp.png", isCrypto: false),
        CurrencyOption(code: "CAD", name: "Canadian Dollar", icon: "https://flagcdn.com/w40/ca.png", isCrypto: false),
        CurrencyOption(code: "AUD", name: "Australian Dollar", icon: "https://flagcdn.com/w40/au.png", isCrypto: false),
        CurrencyOption(code: "BTC", name: "Bitcoin", icon: "https://cryptologos.cc/logos/bitcoin-btc-logo.png", isCrypto: true),
        CurrencyOption(code: "ETH", name: "Ethereum", icon: "https://cryptologos.cc/logos/ethereum-eth-logo.png", isCrypto: true),
        CurrencyOption(code: "SOL", name: "Solana", icon: "https://cryptologos.cc/logos/solana-sol-logo.png", isCrypto: true),
        CurrencyOption(code: "ADA", name: "Cardano", icon: "https://cryptologos.cc/logos/cardano-ada-logo.png", isCrypto: true),
        CurrencyOption(code: "MATIC", name: "Polygon", icon: "https://cryptologos.cc/logos/polygon-matic-logo.png", isCrypto: true)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.primaryButton
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    
                    // Crypto Converter Section
                    if showConverter {
                        converterSection
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if !isAddingCoins {
                        // Normal watchlist view
                        if !showConverter {
                            watchlistSelector
                        }
                        watchlistContent
                    } else {
                        // Add coins view integrated
                        addCoinsSection
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateListSheet) {
            CreateWatchlistView(watchlistManager: watchlistManager)
        }
        .sheet(isPresented: $showPaywall) {
            MyPaywallView()
        }
        .sheet(isPresented: $showCoinDetail) {
            if let coin = selectedCoin {
                CoinDetailView(crypto: coin, cryptoService: cryptoService)
            }
        }
        .sheet(isPresented: $showFromPicker) {
            CurrencyPickerView(
                currencies: availableCurrencies,
                selectedCurrency: $fromCurrency,
                isPresented: $showFromPicker
            )
        }
        .sheet(isPresented: $showToPicker) {
            CurrencyPickerView(
                currencies: availableCurrencies,
                selectedCurrency: $toCurrency,
                isPresented: $showToPicker
            )
        }
        .onAppear {
            cryptoService.startRealTimeUpdates()
            converterService.startUpdates()
            watchlistManager.loadWatchlists()
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isAddingCoins ? "Add Coins" : (showConverter ? "Converter" : "Watchlist"))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if cryptoService.isLoading || converterService.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    }
                }
                
                Text(isAddingCoins ? "Discover new cryptocurrencies" :
                        (showConverter ? "Convert crypto & fiat currencies" : "Track your favorite crypto"))
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if !isAddingCoins && !showConverter {
                    // Market Stats
                    marketStatsView
                }
                
                // Converter Toggle Button
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        if showConverter {
                            showConverter = false
                        } else {
                            showConverter = true
                            isAddingCoins = false
                        }
                    }
                }) {
                    Image(systemName: showConverter ? "xmark.circle.fill" : "arrow.2.squarepath")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: showConverter ? [.red, .orange] : [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Main Action Button
                if !showConverter {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if isAddingCoins {
                                isAddingCoins = false
                                searchText = ""
                            } else {
                                if canAddMoreCoins() {
                                    isAddingCoins = true
                                } else {
                                    showPaywall = true
                                }
                            }
                        }
                    }) {
                        Image(systemName: isAddingCoins ? "xmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: isAddingCoins ? [.red, .orange] : [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var converterSection: some View {
        VStack(spacing: 20) {
            // From Currency
            VStack(spacing: 12) {
                HStack {
                    Text("You Send")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    // Currency Selector - Removed chevron, made clickable
                    Button(action: {
                        showFromPicker = true
                    }) {
                        HStack(spacing: 8) {
                            AsyncImage(url: URL(string: getCurrencyIcon(fromCurrency))) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Text(fromCurrency.prefix(2))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fromCurrency)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(getCurrencyName(fromCurrency))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(fromCurrencyButtonBackground)
                    }
                    
                    // Amount Input
                    TextField("Amount", text: $fromAmount)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .onChange(of: fromAmount) { _ in
                            converterService.convert(
                                amount: Double(fromAmount) ?? 0,
                                from: fromCurrency,
                                to: toCurrency
                            )
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(fromCurrencyBackground)
            }
            
            // Swap Button
            Button(action: {
                withAnimation(.spring()) {
                    let tempCurrency = fromCurrency
                    fromCurrency = toCurrency
                    toCurrency = tempCurrency
                    
                    converterService.convert(
                        amount: Double(fromAmount) ?? 0,
                        from: fromCurrency,
                        to: toCurrency
                    )
                }
            }) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(swapButtonBackground)
            }
            
            // To Currency
            VStack(spacing: 12) {
                HStack {
                    Text("You Get")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    // Currency Selector - Removed chevron, made clickable
                    Button(action: {
                        showToPicker = true
                    }) {
                        HStack(spacing: 8) {
                            AsyncImage(url: URL(string: getCurrencyIcon(toCurrency))) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Text(toCurrency.prefix(2))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(toCurrency)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(getCurrencyName(toCurrency))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(toCurrencyButtonBackground)
                    }
                    
                    // Converted Amount
                    Text(converterService.convertedAmount)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(toCurrencyBackground)
            }
            
            // Exchange Rate Info
            if !converterService.exchangeRate.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("1 \(fromCurrency) = \(converterService.exchangeRate) \(toCurrency)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Live rates")
                        .font(.system(size: 12))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(liveRatesBackground)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(exchangeRateBackground)
            }
            
            // Popular Conversions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(popularConversions, id: \.0) { conversion in
                        Button(action: {
                            withAnimation(.spring()) {
                                fromCurrency = conversion.0
                                toCurrency = conversion.1
                                converterService.convert(
                                    amount: Double(fromAmount) ?? 0,
                                    from: fromCurrency,
                                    to: toCurrency
                                )
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(conversion.0)
                                    .font(.system(size: 12, weight: .bold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                                
                                Text(conversion.1)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(popularConversionBackground)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // Helper computed properties for converter backgrounds
    private var fromCurrencyButtonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var fromCurrencyBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var swapButtonBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.cyan, Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var toCurrencyButtonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var toCurrencyBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var liveRatesBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.cyan.opacity(0.2))
    }
    
    private var exchangeRateBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.05))
    }
    
    private var popularConversionBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var popularConversions: [(String, String)] {
        [
            ("USD", "INR"),
            ("BTC", "USD"),
            ("ETH", "INR"),
            ("USD", "EUR"),
            ("BTC", "INR"),
            ("ETH", "USD"),
            ("USD", "GBP"),
            ("SOL", "USD"),
            ("ADA", "USD"),
            ("MATIC", "USD")
        ]
    }
    
    // Rest of your existing code...
    private var marketStatsView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("Market Cap")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
            
            Text(formatMarketCap(cryptoService.totalMarketCap))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.cyan)
        }
    }
    
    private var watchlistSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(watchlistManager.watchlists.enumerated()), id: \.element.id) { index, watchlist in
                    WatchlistSelectorButton(
                        watchlist: watchlist,
                        isSelected: selectedWatchlist == index
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedWatchlist = index
                        }
                    }
                }
                
                // Add New Watchlist Button
                Button(action: {
                    if canCreateMoreLists() {
                        showCreateListSheet = true
                    } else {
                        showPaywall = true
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                        
                        Text("New List")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(newWatchlistBackground)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private var newWatchlistBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            .fill(Color.white.opacity(0.05))
    }
    
    private var watchlistContent: some View {
        Group {
            if watchlistManager.watchlists.isEmpty {
                emptyStateView
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        let currentWatchlist = watchlistManager.watchlists[selectedWatchlist]
                        
                        ForEach(currentWatchlist.coinIds, id: \.self) { coinId in
                            if let crypto = cryptoService.getCrypto(by: coinId) {
                                EnhancedCoinCard(
                                    crypto: crypto,
                                    onTap: {
                                        selectedCoin = crypto
                                        showCoinDetail = true
                                    },
                                    onRemove: {
                                        withAnimation(.spring()) {
                                            watchlistManager.removeCoin(coinId, from: selectedWatchlist)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var addCoinsSection: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBarView
            
            // Category Filter
            categoryFilterView
            
            // Coins List
            addCoinsListView
        }
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search cryptocurrencies...", text: $searchText)
                .foregroundColor(.white)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(searchBarBackground)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var searchBarBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                if selectedCategory == category {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing))
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.1))
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    private var addCoinsListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(filteredCoinsForAdding) { crypto in
                    AddCoinRowView(
                        crypto: crypto,
                        isAdded: isCurrentlyAdded(crypto.id)
                    ) {
                        addCoinToCurrentWatchlist(crypto.id)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(.cyan)
            
            VStack(spacing: 16) {
                Text("Start Your Crypto Journey")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Add your favorite cryptocurrencies\nto track their performance")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isAddingCoins = true
                }
            }) {
                Text("Add Your First Coin")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(emptyStateButtonBackground)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }
    
    private var emptyStateButtonBackground: some View {
        LinearGradient(
            colors: [Color.cyan, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Computed Properties
    
    private var filteredCoinsForAdding: [CryptoAsset] {
        var coins = cryptoService.getCoinsForCategory(selectedCategory)
        
        if !searchText.isEmpty {
            coins = coins.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return coins
    }
    
    // MARK: - Helper Functions
    
    private func getCurrencyIcon(_ currency: String) -> String {
        if let currencyOption = availableCurrencies.first(where: { $0.code == currency }) {
            return currencyOption.icon
        }
        return ""
    }
    
    private func getCurrencyName(_ currency: String) -> String {
        if let currencyOption = availableCurrencies.first(where: { $0.code == currency }) {
            return currencyOption.name
        }
        return currency
    }
    
    private func canAddMoreCoins() -> Bool {
        guard !watchlistManager.watchlists.isEmpty else { return true }
        let currentWatchlist = watchlistManager.watchlists[selectedWatchlist]
        
        if purchaseManager.isPro {
            return currentWatchlist.coinIds.count < 50
        } else {
            return currentWatchlist.coinIds.count < 10
        }
    }
    
    private func canCreateMoreLists() -> Bool {
        if purchaseManager.isPro {
            return watchlistManager.watchlists.count < 10
        } else {
            return watchlistManager.watchlists.count < 3
        }
    }
    
    private func isCurrentlyAdded(_ coinId: String) -> Bool {
        guard watchlistManager.watchlists.indices.contains(selectedWatchlist) else { return false }
        return watchlistManager.watchlists[selectedWatchlist].coinIds.contains(coinId)
    }
    
    private func addCoinToCurrentWatchlist(_ coinId: String) {
        withAnimation(.spring()) {
            watchlistManager.addCoin(coinId, to: selectedWatchlist)
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Auto-dismiss after adding if not pro user (to encourage upgrading)
        if !purchaseManager.isPro && !canAddMoreCoins() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring()) {
                    isAddingCoins = false
                }
            }
        }
    }
    
    private func formatMarketCap(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.1fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

// MARK: - Currency Models and Picker

struct CurrencyOption {
    let code: String
    let name: String
    let icon: String
    let isCrypto: Bool
}

struct CurrencyPickerView: View {
    let currencies: [CurrencyOption]
    @Binding var selectedCurrency: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.primaryButton
                    .ignoresSafeArea()
                
                VStack {
                    // Header
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Select Currency")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Done") {
                            isPresented = false
                        }
                        .foregroundColor(.cyan)
                    }
                    .padding()
                    
                    // Currency List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(currencies, id: \.code) { currency in
                                Button(action: {
                                    selectedCurrency = currency.code
                                    isPresented = false
                                }) {
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: currency.icon)) { image in
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
                                            Text(currency.code)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text(currency.name)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        if currency.isCrypto {
                                            Text("CRYPTO")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.orange)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(cryptoTagBackground)
                                        }
                                        
                                        if selectedCurrency == currency.code {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.cyan)
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(currencyRowBackground(isSelected: selectedCurrency == currency.code))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var cryptoTagBackground: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.orange.opacity(0.2))
    }
    
    private func currencyRowBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.cyan.opacity(0.1) : Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Enhanced Crypto Converter Service with Real Rates

class CryptoConverterService: ObservableObject {
    @Published var convertedAmount = "0.00"
    @Published var exchangeRate = ""
    @Published var isLoading = false
    
    private let newsApiKey = ""
    private let cryptoApiKey = ""
    
    // Real exchange rates - Updated frequently
    private var liveRates: [String: Double] = [:]
    private var updateTimer: Timer?
    
    func startUpdates() {
        fetchLiveRates()
        
        // Update rates every 30 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.fetchLiveRates()
        }
        
        // Initialize with default conversion
        convert(amount: 1, from: "USD", to: "INR")
    }
    
    func convert(amount: Double, from: String, to: String) {
        isLoading = true
        
        // Use real API rates when available
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
            
            let rate = self.getExchangeRate(from: from, to: to)
            let converted = amount * rate
            
            self.convertedAmount = self.formatAmount(converted, currency: to)
            self.exchangeRate = self.formatRate(rate, to: to)
        }
    }
    
    private func fetchLiveRates() {
        // Fetch real exchange rates from multiple APIs
        fetchCryptoRates()
        fetchFiatRates()
    }
    
    private func fetchCryptoRates() {
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,cardano,matic-network&vs_currencies=usd,inr,eur,gbp,jpy,cad,aud")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Double]] {
                    DispatchQueue.main.async {
                        // Bitcoin rates
                        if let btcRates = json["bitcoin"] {
                            self?.liveRates["BTC_USD"] = btcRates["usd"]
                            self?.liveRates["BTC_INR"] = btcRates["inr"]
                            self?.liveRates["BTC_EUR"] = btcRates["eur"]
                            self?.liveRates["BTC_GBP"] = btcRates["gbp"]
                        }
                        
                        // Ethereum rates
                        if let ethRates = json["ethereum"] {
                            self?.liveRates["ETH_USD"] = ethRates["usd"]
                            self?.liveRates["ETH_INR"] = ethRates["inr"]
                            self?.liveRates["ETH_EUR"] = ethRates["eur"]
                            self?.liveRates["ETH_GBP"] = ethRates["gbp"]
                        }
                        
                        // Solana rates
                        if let solRates = json["solana"] {
                            self?.liveRates["SOL_USD"] = solRates["usd"]
                            self?.liveRates["SOL_INR"] = solRates["inr"]
                            self?.liveRates["SOL_EUR"] = solRates["eur"]
                            self?.liveRates["SOL_GBP"] = solRates["gbp"]
                        }
                        
                        // Cardano rates
                        if let adaRates = json["cardano"] {
                            self?.liveRates["ADA_USD"] = adaRates["usd"]
                            self?.liveRates["ADA_INR"] = adaRates["inr"]
                            self?.liveRates["ADA_EUR"] = adaRates["eur"]
                            self?.liveRates["ADA_GBP"] = adaRates["gbp"]
                        }
                        
                        // Polygon rates
                        if let maticRates = json["matic-network"] {
                            self?.liveRates["MATIC_USD"] = maticRates["usd"]
                            self?.liveRates["MATIC_INR"] = maticRates["inr"]
                            self?.liveRates["MATIC_EUR"] = maticRates["eur"]
                            self?.liveRates["MATIC_GBP"] = maticRates["gbp"]
                        }
                        
                        print("✅ Updated crypto rates: \(self?.liveRates.count ?? 0) pairs")
                    }
                }
            } catch {
                print("❌ Error parsing crypto rates: \(error)")
            }
        }.resume()
    }
    
    private func fetchFiatRates() {
        // Using a free exchange rate API
        let url = URL(string: "https://api.exchangerate-api.com/v4/latest/USD")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let rates = json["rates"] as? [String: Double] {
                    
                    DispatchQueue.main.async {
                        // Store fiat exchange rates
                        self?.liveRates["USD_INR"] = rates["INR"]
                        self?.liveRates["USD_EUR"] = rates["EUR"]
                        self?.liveRates["USD_GBP"] = rates["GBP"]
                        self?.liveRates["USD_JPY"] = rates["JPY"]
                        self?.liveRates["USD_CAD"] = rates["CAD"]
                        self?.liveRates["USD_AUD"] = rates["AUD"]
                        
                        // Calculate reverse rates
                        if let inrRate = rates["INR"] {
                            self?.liveRates["INR_USD"] = 1.0 / inrRate
                        }
                        if let eurRate = rates["EUR"] {
                            self?.liveRates["EUR_USD"] = 1.0 / eurRate
                        }
                        if let gbpRate = rates["GBP"] {
                            self?.liveRates["GBP_USD"] = 1.0 / gbpRate
                        }
                        
                        print("✅ Updated fiat rates: \(rates.count) currencies")
                    }
                }
            } catch {
                print("❌ Error parsing fiat rates: \(error)")
            }
        }.resume()
    }
    
    private func getExchangeRate(from: String, to: String) -> Double {
        if from == to { return 1.0 }
        
        let conversionKey = "\(from)_\(to)"
        let reverseKey = "\(to)_\(from)"
        
        // Check if we have a direct rate
        if let directRate = liveRates[conversionKey] {
            return directRate
        }
        
        // Check if we have a reverse rate
        if let reverseRate = liveRates[reverseKey] {
            return 1.0 / reverseRate
        }
        
        // Try cross-conversion through USD
        if from != "USD" && to != "USD" {
            if let fromUsdRate = liveRates["\(from)_USD"],
               let usdToRate = liveRates["USD_\(to)"] {
                return fromUsdRate * usdToRate
            }
            
            if let usdFromRate = liveRates["USD_\(from)"],
               let toUsdRate = liveRates["\(to)_USD"] {
                return (1.0 / usdFromRate) * toUsdRate
            }
        }
        
        // Fallback to hardcoded rates if API fails
        return getFallbackRate(from: from, to: to)
    }
    
    private func getFallbackRate(from: String, to: String) -> Double {
        let fallbackRates: [String: Double] = [
            "USD_INR": 83.25,
            "USD_EUR": 0.85,
            "USD_GBP": 0.73,
            "USD_JPY": 150.0,
            "USD_CAD": 1.35,
            "USD_AUD": 1.55,
            "BTC_USD": 67850.42,
            "ETH_USD": 3456.78,
            "SOL_USD": 158.92,
            "ADA_USD": 0.4567,
            "MATIC_USD": 0.8934
        ]
        
        let conversionKey = "\(from)_\(to)"
        let reverseKey = "\(to)_\(from)"
        
        if let directRate = fallbackRates[conversionKey] {
            return directRate
        } else if let reverseRate = fallbackRates[reverseKey] {
            return 1.0 / reverseRate
        }
        
        return 1.0
    }
    
    private func formatAmount(_ amount: Double, currency: String) -> String {
        switch currency {
        case "BTC":
            return String(format: "%.8f", amount)
        case "ETH":
            return String(format: "%.6f", amount)
        case "SOL", "ADA", "MATIC":
            return String(format: "%.4f", amount)
        case "USD", "EUR", "GBP", "CAD", "AUD":
            return String(format: "%.2f", amount)
        case "INR":
            return String(format: "%.2f", amount)
        case "JPY":
            return String(format: "%.0f", amount)
        default:
            return String(format: "%.4f", amount)
        }
    }
    
    private func formatRate(_ rate: Double, to: String) -> String {
        return formatAmount(rate, currency: to)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - Enhanced Coin Card with Real-time Charts

struct EnhancedCoinCard: View {
    let crypto: CryptoAsset
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon and Info
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: getCryptoIconURL(crypto.icon))) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Text(String(crypto.symbol.prefix(2)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(crypto.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(crypto.symbol.uppercased())
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Price and Real-time Chart
                VStack(alignment: .trailing, spacing: 8) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(crypto.formattedPrice)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: crypto.priceChangePercentage24h >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 12))
                            
                            Text(String(format: "%.2f%%", crypto.priceChangePercentage24h))
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
                    }
                    
                    // Fixed chart view call
                    RealTimeChartView(
                        priceData: crypto.priceData,
                        color: crypto.priceChangePercentage24h >= 0 ? .green : .red,
                        showFill: true
                    )
                    .frame(width: 80, height: 30)
                }
                
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(coinCardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var coinCardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
    
    private func getCryptoIconURL(_ icon: String) -> String {
        switch icon {
        case "bitcoin":
            return "https://cryptologos.cc/logos/bitcoin-btc-logo.png"
        case "ethereum":
            return "https://cryptologos.cc/logos/ethereum-eth-logo.png"
        case "solana":
            return "https://cryptologos.cc/logos/solana-sol-logo.png"
        case "cardano":
            return "https://cryptologos.cc/logos/cardano-ada-logo.png"
        case "polygon", "matic-network":
            return "https://cryptologos.cc/logos/polygon-matic-logo.png"
        default:
            return ""
        }
    }
}

 struct WatchlistSelectorButton: View {
    let watchlist: Watchlist
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: watchlist.icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(watchlist.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text("\(watchlist.coinIds.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .black : .white.opacity(0.8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(countBackground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selectorButtonBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var countBackground: some View {
        Circle()
            .fill(isSelected ? Color.white : Color.white.opacity(0.2))
    }
    
    private var selectorButtonBackground: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            }
        }
    }
}

struct AddCoinRowView: View {
    let crypto: CryptoAsset
    let isAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon and Info
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: getCryptoIconURL(crypto.icon))) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Text(String(crypto.symbol.prefix(2)))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(crypto.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(crypto.symbol.uppercased())
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(crypto.formattedMarketCap)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            
            Spacer()
            
            // Price Info with mini chart
            VStack(alignment: .trailing, spacing: 4) {
                Text(crypto.formattedPrice)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: crypto.priceChangePercentage24h >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10))
                    
                    Text(String(format: "%.2f%%", crypto.priceChangePercentage24h))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
                
                // Fixed mini chart for add coin row
                RealTimeChartView(
                    priceData: crypto.priceData,
                    color: crypto.priceChangePercentage24h >= 0 ? .green : .red,
                    showFill: false
                )
                .frame(width: 50, height: 20)
            }
            
            // Add Button
            Button(action: onAdd) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isAdded ? .green : .cyan)
            }
            .disabled(isAdded)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(addCoinRowBackground)
    }
    
    private var addCoinRowBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
    
    private func getCryptoIconURL(_ icon: String) -> String {
        switch icon {
        case "bitcoin":
            return "https://cryptologos.cc/logos/bitcoin-btc-logo.png"
        case "ethereum":
            return "https://cryptologos.cc/logos/ethereum-eth-logo.png"
        case "solana":
            return "https://cryptologos.cc/logos/solana-sol-logo.png"
        case "cardano":
            return "https://cryptologos.cc/logos/cardano-ada-logo.png"
        case "polygon", "matic-network":
            return "https://cryptologos.cc/logos/polygon-matic-logo.png"
        default:
            return ""
        }
    }
}

#Preview {
    WatchlistView()
        .environmentObject(PurchaseManager())
}
