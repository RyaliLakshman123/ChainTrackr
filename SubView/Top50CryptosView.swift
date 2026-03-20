//
//  Top50CryptosView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI

struct Top50CryptosView: View {
    @StateObject private var cryptoService = Top50CryptoService()
    @State private var selectedFilter: CryptoFilter = .all
    @State private var searchText = ""
    @State private var showingFilterMenu = false
    @State private var showingSettings = false
    @Environment(\.dismiss) private var dismiss
    
    enum CryptoFilter: String, CaseIterable {
        case all = "All"
        case gainers = "Top Gainers"
        case losers = "Top Losers"
        case volume = "High Volume"
        case marketCap = "Market Cap"
        case trending = "Trending"
    }
    
    var filteredCryptos: [CryptoAsset] {
        var cryptos = cryptoService.cryptoAssets
        
        if !searchText.isEmpty {
            cryptos = cryptos.filter { crypto in
                crypto.name.lowercased().contains(searchText.lowercased()) ||
                crypto.symbol.lowercased().contains(searchText.lowercased())
            }
        }
        
        switch selectedFilter {
        case .all:
            return cryptos
        case .gainers:
            return cryptos.filter { $0.priceChangePercentage24h > 0 }
                .sorted { $0.priceChangePercentage24h > $1.priceChangePercentage24h }
        case .losers:
            return cryptos.filter { $0.priceChangePercentage24h < 0 }
                .sorted { $0.priceChangePercentage24h < $1.priceChangePercentage24h }
        case .volume:
            return cryptos.sorted { $0.volume24h > $1.volume24h }
        case .marketCap:
            return cryptos.sorted { $0.marketCap > $1.marketCap }
        case .trending:
            return cryptos.filter { abs($0.priceChangePercentage24h) > 5 }
                .sorted { abs($0.priceChangePercentage24h) > abs($1.priceChangePercentage24h) }
        }
    }
    
    var body: some View {
        ZStack {
            // PRO Gradient Background
            // Using App's Primary Button Gradient Background
            AppGradients.primaryButton
                .ignoresSafeArea()
            
            // Animated background particles
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.cyan.opacity(0.1))
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 10...20))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
            }
            
            VStack(spacing: 0) {
                // PRO Header
                proHeaderSection
                
                // Main Content
                mainContentSection
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cryptoService.startRealTimeUpdates()
        }
        .onDisappear {
            cryptoService.stopRealTimeUpdates()
        }
        .refreshable {
            await cryptoService.refreshData()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheetView()
        }
    }
    
    // MARK: - PRO Header Section
    private var proHeaderSection: some View {
        VStack(spacing: 24) {
            // Navigation Header
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
                
                // PRO Title Section
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text("TOP 50")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 40, height: 20)
                            
                            Text("PRO")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        // Live indicator with advanced animation
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Circle()
                                .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                .frame(width: 16, height: 16)
                                .scaleEffect(cryptoService.isLoading ? 2.0 : 1.0)
                                .opacity(cryptoService.isLoading ? 0.0 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(), value: cryptoService.isLoading)
                            
                            Circle()
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                .frame(width: 24, height: 24)
                                .scaleEffect(cryptoService.isLoading ? 2.5 : 1.0)
                                .opacity(cryptoService.isLoading ? 0.0 : 0.5)
                                .animation(.easeInOut(duration: 1.5).repeatForever().delay(0.3), value: cryptoService.isLoading)
                        }
                        
                        Text("LIVE DATA")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("REAL-TIME")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                }
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
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
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // PRO Search Section (Fixed)
            proSearchSection
                .padding(.top, -140)
                
            // PRO Market Stats Section (Fixed)
            fixedMarketStatsSection
        }
    }
    
    // MARK: - PRO Search Section (Separate and Fixed)
    private var proSearchSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Search cryptocurrencies...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search cryp...")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 16, weight: .medium))
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // Filter Button
            Button(action: { showingFilterMenu = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: selectedFilter == .all ?
                                [Color.cyan.opacity(0.3), Color.cyan.opacity(0.1)] :
                                    [Color.cyan, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                        )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 25))
                        
                        if selectedFilter != .all {
                            Text(String(selectedFilter.rawValue.prefix(3)))
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .actionSheet(isPresented: $showingFilterMenu) {
                ActionSheet(
                    title: Text("Filter Cryptocurrencies"),
                    message: Text("Choose your preferred filter"),
                    buttons: CryptoFilter.allCases.map { filter in
                            .default(Text(filter.rawValue)) {
                                withAnimation(.spring()) {
                                    selectedFilter = filter
                                }
                            }
                    } + [.cancel()]
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 150)
    }
    
    // MARK: - Fixed Market Stats Section (No Scrolling)
    private var fixedMarketStatsSection: some View {
        VStack(spacing: 16) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MARKET INTELLIGENCE")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("Real-time market data & analytics")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if cryptoService.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        
                        Text("UPDATING")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.cyan.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                    )
                } else {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("LIVE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Market Stats Cards (Fixed - No Horizontal Scroll)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 12) {
//                CompactMarketStatCard(
//                    title: "Market Cap",
//                    value: formatMarketCap(cryptoService.totalMarketCap),
//                    change: "+2.4%",
//                    isPositive: true,
//                    icon: "chart.pie.fill",
//                    gradient: [Color.purple, Color.pink]
//                )
                
//                CompactMarketStatCard(
//                    title: "24h Volume",
//                    value: formatVolume(cryptoService.total24hVolume),
//                    change: "+15.7%",
//                    isPositive: true,
//                    icon: "arrow.up.arrow.down.circle.fill",
//                    gradient: [Color.blue, Color.cyan]
//                )
                
                CompactMarketStatCard(
                    title: "BTC Dom",
                    value: "\(String(format: "%.1f", cryptoService.bitcoinDominance))%",
                    change: "+0.5%",
                    isPositive: true,
                    icon: "bitcoinsign.circle.fill",
                    gradient: [Color.orange, Color.yellow]
                )
                
//                CompactMarketStatCard(
//                    title: "Coins",
//                    value: "\(cryptoService.cryptoAssets.count)",
//                    change: "LIVE",
//                    isPositive: true,
//                    icon: "circle.grid.cross.fill",
//                    gradient: [Color.green, Color.mint]
//                )
                
                CompactMarketStatCard(
                    title: "Gainers",
                    value: "\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h > 0 }.count)",
                    change: "24H",
                    isPositive: true,
                    icon: "arrow.up.circle.fill",
                    gradient: [Color.green, Color.teal]
                )
                
                CompactMarketStatCard(
                    title: "Losers",
                    value: "\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h < 0 }.count)",
                    change: "24H",
                    isPositive: false,
                    icon: "arrow.down.circle.fill",
                    gradient: [Color.red, Color.orange]
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Compact Market Stat Card (Smaller, Grid Layout)
    struct CompactMarketStatCard: View {
        let title: String
        let value: String
        let change: String
        let isPositive: Bool
        let icon: String
        let gradient: [Color]
        
        @State private var isPressed = false
        
        var body: some View {
            Button(action: {
                // Handle card tap for detailed view
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed.toggle()
                }
                
                // Reset after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }) {
                VStack(spacing: 14) {
                    // Enhanced Icon with Background
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: gradient.map { $0.opacity(0.3) },
                                    center: .topLeading,
                                    startRadius: 5,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 40, height: 40) // Increased icon size
                            .overlay(
                                Circle()
                                    .stroke(gradient[0].opacity(0.5), lineWidth: 2)
                            )
                        
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .bold)) // Increased icon font size
                            .foregroundColor(gradient[0])
                    }
                    
                    VStack(spacing: 6) {
                        // Value with larger font
                        Text(value)
                            .font(.system(size: 18, weight: .black)) // Increased font size
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .animation(.spring(response: 0.5), value: value)
                        
                        // Title with better spacing
                        Text(title)
                            .font(.system(size: 12, weight: .bold)) // Increased font size
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Enhanced Change Indicator
                        HStack(spacing: 4) {
                            if change != "LIVE" && change != "24H" {
                                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            
                            Text(change)
                                .font(.system(size: 11, weight: .black)) // Increased font size
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12) // Increased padding
                        .padding(.vertical, 6) // Increased padding
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: change == "LIVE" || change == "24H" ?
                                        [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                            isPositive ?
                                        [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                            [Color.red.opacity(0.3), Color.red.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            (change == "LIVE" || change == "24H") ? Color.green.opacity(0.5) :
                                                isPositive ? Color.green.opacity(0.5) : Color.red.opacity(0.5),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
                .frame(height: 95) // Set fixed height for consistency
                .frame(maxWidth: .infinity) // Take full width available
                .padding(20) // Increased padding
                .background(
                    RoundedRectangle(cornerRadius: 20) // Increased corner radius
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: gradient.map { $0.opacity(0.4) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                )
                .shadow(color: gradient[0].opacity(0.2), radius: 12, x: 0, y: 6) // Enhanced shadow
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Updated Main Content Section
    private var mainContentSection: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Section Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CRYPTOCURRENCY RANKINGS")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("\(filteredCryptos.count) coins • \(selectedFilter.rawValue) • Live prices & charts")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Updated \(formatTime(Date()))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.1))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20) // Reduced top padding
                .padding(.bottom, 16)
                
                // PRO Crypto List
                ForEach(Array(filteredCryptos.enumerated()), id: \.element.id) { index, crypto in
                    NavigationLink(destination: CryptoDetailView(asset: crypto)) {
                        ProCryptoCard(
                            rank: crypto.rank > 0 ? crypto.rank : index + 1,
                            crypto: crypto,
                            isEven: index % 2 == 0
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer(minLength: 100) // Reduced bottom spacing
            }
        }
    }
    
    // MARK: - PRO Search and Filter Section
    private var proSearchFilterSection: some View {
        VStack(spacing: 16) {
            // Advanced Search Bar
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("Search cryptocurrencies...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search 50+ cryptocurrencies...")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 16, weight: .medium))
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 70)
                }
                
                .actionSheet(isPresented: $showingFilterMenu) {
                    ActionSheet(
                        title: Text("Filter Cryptocurrencies"),
                        message: Text("Choose your preferred filter"),
                        buttons: CryptoFilter.allCases.map { filter in
                                .default(Text(filter.rawValue)) {
                                    withAnimation(.spring()) {
                                        selectedFilter = filter
                                    }
                                }
                        } + [.cancel()]
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 90)
        }
    }
    
    // MARK: - PRO Market Stats Section
    private var proMarketStatsSection: some View {
        VStack(spacing: 20) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MARKET INTELLIGENCE")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("Real-time market data & analytics")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if cryptoService.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        
                        Text("UPDATING")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.cyan.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                    )
                } else {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("LIVE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, -90)
            
            // Market Stats Cards Scroll View
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ProMarketStatCard(
                        title: "Total Market Cap",
                        value: formatMarketCap(cryptoService.totalMarketCap),
                        change: "+2.4%",
                        isPositive: true,
                        icon: "chart.pie.fill",
                        gradient: [Color.purple, Color.pink]
                    )
                    
                    ProMarketStatCard(
                        title: "24h Volume",
                        value: formatVolume(cryptoService.total24hVolume),
                        change: "+15.7%",
                        isPositive: true,
                        icon: "arrow.up.arrow.down.circle.fill",
                        gradient: [Color.blue, Color.cyan]
                    )
                    
                    ProMarketStatCard(
                        title: "BTC Dominance",
                        value: "\(String(format: "%.1f", cryptoService.bitcoinDominance))%",
                        change: "+0.5%",
                        isPositive: true,
                        icon: "bitcoinsign.circle.fill",
                        gradient: [Color.orange, Color.yellow]
                    )
                    
                    ProMarketStatCard(
                        title: "Active Coins",
                        value: "\(cryptoService.cryptoAssets.count)",
                        change: "LIVE",
                        isPositive: true,
                        icon: "circle.grid.cross.fill",
                        gradient: [Color.green, Color.mint]
                    )
                    
                    ProMarketStatCard(
                        title: "Gainers",
                        value: "\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h > 0 }.count)",
                        change: "24H",
                        isPositive: true,
                        icon: "arrow.up.circle.fill",
                        gradient: [Color.green, Color.teal]
                    )
                    
                    ProMarketStatCard(
                        title: "Losers",
                        value: "\(cryptoService.cryptoAssets.filter { $0.priceChangePercentage24h < 0 }.count)",
                        change: "24H",
                        isPositive: false,
                        icon: "arrow.down.circle.fill",
                        gradient: [Color.red, Color.orange]
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .padding(.top, -60)
        }
    }
    
    // MARK: - Quick Action Button Component
    struct QuickActionButton: View {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(color.opacity(0.4), lineWidth: 1)
                            )
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(color)
                    }
                    
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Scale Button Style for Better Interaction
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    // MARK: - Enhanced PRO Market Stat Card
    struct ProMarketStatCard: View {
        let title: String
        let value: String
        let change: String
        let isPositive: Bool
        let icon: String
        let gradient: [Color]
        
        @State private var isPressed = false
        
        var body: some View {
            Button(action: {
                // Handle card tap for detailed view
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed.toggle()
                }
                
                // Reset after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: gradient.map { $0.opacity(0.4) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: gradient[0].opacity(0.2), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 14) {
                        // Icon with Enhanced Background
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: gradient.map { $0.opacity(0.3) },
                                        center: .topLeading,
                                        startRadius: 5,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(gradient[0].opacity(0.5), lineWidth: 2)
                                )
                            
                            Image(systemName: icon)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(gradient[0])
                        }
                        
                        VStack(spacing: 6) {
                            // Value with Animation
                            Text(value)
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.white)
                                .animation(.spring(response: 0.5), value: value)
                            
                            // Title
                            Text(title)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            
                            // Change Indicator
                            HStack(spacing: 4) {
                                if change != "LIVE" && change != "24H" {
                                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                
                                Text(change)
                                    .font(.system(size: 11, weight: .black))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: change == "LIVE" || change == "24H" ?
                                            [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                                isPositive ?
                                            [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                                [Color.red.opacity(0.3), Color.red.opacity(0.1)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                (change == "LIVE" || change == "24H") ? Color.green.opacity(0.5) :
                                                    isPositive ? Color.green.opacity(0.5) : Color.red.opacity(0.5),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                    }
                    .padding(18)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 150, height: 160)
        }
    }
    
    // MARK: - Helper Functions
    private func formatMarketCap(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.1fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else {
            return String(format: "$%.1fM", value / 1_000_000)
        }
    }
    
    private func formatVolume(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else {
            return String(format: "$%.1fM", value / 1_000_000)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - PRO Market Stat Card
struct ProMarketStatCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: gradient[0].opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 12) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(gradient[0])
                }
                
                VStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text(change)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isPositive ? .green : .red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill((isPositive ? Color.green : Color.red).opacity(0.2))
                        )
                }
            }
            .padding(16)
        }
        .frame(width: 100, height: 100)
    }
}

// MARK: - PRO Crypto Card
struct ProCryptoCard: View {
    let rank: Int
    let crypto: CryptoAsset
    let isEven: Bool
    
    @State private var correctIconUrl: String?
    @State private var isLoadingIcon = false
    @State private var iconLoadFailed = false
    
    // Helper function for crypto gradients (fallback)
    private func getCryptoGradient(for symbol: String) -> [Color] {
        switch symbol.uppercased() {
        case "BTC": return [Color.orange, Color.yellow]
        case "ETH": return [Color.blue, Color.purple]
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
        case "ICP": return [Color.orange, Color.red]
        case "VET": return [Color.blue, Color.green]
        case "FIL": return [Color.blue, Color.cyan]
        case "THETA": return [Color.green, Color.blue]
        case "MANA": return [Color.red, Color.orange]
        case "AXS": return [Color.blue, Color.purple]
        case "SAND": return [Color.yellow, Color.orange]
        case "CRV": return [Color.yellow, Color.red]
        case "AAVE": return [Color.purple, Color.pink]
        case "COMP": return [Color.green, Color.cyan]
        case "MKR": return [Color.green, Color.blue]
        case "SNX": return [Color.blue, Color.purple]
        case "YFI": return [Color.blue, Color.black]
        case "BNB": return [Color.yellow, Color.orange]
        case "USDT", "USDC", "USDS", "FDUSD", "USD1", "USDTB": return [Color.green, Color.cyan]
        case "BUSD": return [Color.yellow, Color.green]
        case "SHIB": return [Color.orange, Color.red]
        case "NEAR": return [Color.black, Color.gray]
        case "APE": return [Color.blue, Color.purple]
        case "CRO": return [Color.blue, Color.purple]
        case "FTT": return [Color.cyan, Color.blue]
        case "FLOW": return [Color.green, Color.blue]
        case "HBAR": return [Color.purple, Color.pink]
        case "ETC": return [Color.green, Color.cyan]
        case "XMR": return [Color.orange, Color.red]
        case "XTZ": return [Color.blue, Color.purple]
        case "EGLD": return [Color.black, Color.blue]
        case "BSV": return [Color.yellow, Color.orange]
        case "BCH": return [Color.green, Color.yellow]
        case "CAKE": return [Color.orange, Color.pink]
        case "RUNE": return [Color.green, Color.blue]
        case "KCS": return [Color.blue, Color.cyan]
        case "ZEC": return [Color.yellow, Color.orange]
        case "DASH": return [Color.blue, Color.cyan]
        case "SUI": return [Color.blue, Color.cyan]
        case "TON": return [Color.blue, Color.cyan]
        case "HYPE": return [Color.purple, Color.pink]
        case "STETH", "WETH", "WEETH", "METH", "LSETH", "RETH": return [Color.blue, Color.purple]
        case "PEPE": return [Color.green, Color.yellow]
        case "TRUMP": return [Color.red, Color.orange]
        case "GT": return [Color.blue, Color.purple]
        case "BGB": return [Color.yellow, Color.blue]
        case "OKB": return [Color.blue, Color.white]
        case "JUP": return [Color.orange, Color.yellow]
        case "TAO": return [Color.purple, Color.blue]
        case "XDC": return [Color.blue, Color.cyan]
        case "SEI": return [Color.red, Color.pink]
        case "OP": return [Color.red, Color.orange]
        case "KAS": return [Color.cyan, Color.blue]
        case "FLR": return [Color.red, Color.orange]
        case "SKY": return [Color.blue, Color.cyan]
        case "TIA": return [Color.purple, Color.pink]
        case "FET": return [Color.blue, Color.cyan]
        case "RENDER", "RNDR": return [Color.orange, Color.red]
        case "INJ": return [Color.cyan, Color.blue]
        case "FARTCOIN": return [Color.brown, Color.orange]
        case "STX": return [Color.black, Color.purple]
        case "JLP": return [Color.orange, Color.yellow]
        case "MNT": return [Color.black, Color.green]
        case "ONDO": return [Color.blue, Color.purple]
        default: return [Color.gray, Color.gray.opacity(0.7)]
        }
    }
    
    // Comprehensive map of symbols to CoinGecko IDs
    private func getCoingeckoId(for symbol: String) -> String {
        let mapping: [String: String] = [
            // Major cryptocurrencies
            "BTC": "bitcoin",
            "ETH": "ethereum",
            "BNB": "binancecoin",
            "XRP": "ripple",
            "SOL": "solana",
            "ADA": "cardano",
            "DOGE": "dogecoin",
            "AVAX": "avalanche-2",
            "DOT": "polkadot",
            "MATIC": "matic-network",
            "POL": "matic-network", // POL is the new MATIC
            "TRX": "tron",
            "LINK": "chainlink",
            "UNI": "uniswap",
            "LTC": "litecoin",
            "ATOM": "cosmos",
            "ALGO": "algorand",
            "XLM": "stellar",
            "ICP": "internet-computer",
            "VET": "vechain",
            "FIL": "filecoin",
            
            // Stablecoins
            "USDT": "tether",
            "USDC": "usd-coin",
            "BUSD": "binance-usd",
            "USDS": "sky-dollar",
            "FDUSD": "first-digital-usd",
            "USD1": "usd1",
            "USDTB": "tether", // Base USDT
            "DAI": "dai",
            "FRAX": "frax",
            "TUSD": "true-usd",
            "USDP": "paxos-standard",
            
            // DeFi tokens
            "AAVE": "aave",
            "CRV": "curve-dao-token",
            "COMP": "compound-governance-token",
            "MKR": "maker",
            "SNX": "havven",
            "YFI": "yearn-finance",
            "1INCH": "1inch",
            "BAL": "balancer",
            "ZRX": "0x",
            "UMA": "uma",
            "REN": "republic-protocol",
            "SUSHI": "sushi",
            "LRC": "loopring",
            "GRT": "the-graph",
            "BAT": "basic-attention-token",
            "KAVA": "kava",
            "WAVES": "waves",
            "ONT": "ontology",
            "ICX": "icon",
            "QTUM": "qtum",
            "ZIL": "zilliqa",
            "SC": "siacoin",
            "DGB": "digibyte",
            
            // Layer 2 & Scaling solutions
            "OP": "optimism",
            "ARB": "arbitrum",
            "IMX": "immutable-x",
            "STRK": "starknet",
            "METIS": "metis-andromeda",
            "BOBA": "boba-network",
            
            // Meme coins
            "SHIB": "shiba-inu",
            "PEPE": "pepe",
            "FLOKI": "floki",
            "BONK": "bonk",
            "WIF": "dogwifcoin",
            "FARTCOIN": "fartcoin",
            "MEME": "memecoin",
            "BRETT": "brett",
            "POPCAT": "popcat",
            "MEW": "cat-in-a-dogs-world",
            
            // AI & Infrastructure tokens
            "FET": "fetch-ai",
            "RENDER": "render-token",
            "RNDR": "render-token", // Alternative symbol for RENDER
            "TAO": "bittensor",
            "AGIX": "singularitynet",
            "OCEAN": "ocean-protocol",
            "ORAI": "oraichain-token",
            "IOTX": "iotex",
            "AR": "arweave",
            "STORJ": "storj",
            
            // Gaming & Metaverse
            "AXS": "axie-infinity",
            "SAND": "the-sandbox",
            "MANA": "decentraland",
            "ENJ": "enjincoin",
            "CHZ": "chiliz",
            "GALA": "gala",
            "MAGIC": "magic",
            "GMT": "stepn",
            "APE": "apecoin",
            
            // Exchange tokens
            "CRO": "crypto-com-chain",
            "GT": "gatechain-token",
            "BGB": "bitget-token",
            "OKB": "okb",
            "KCS": "kucoin-shares",
            "HT": "huobi-token",
            "LEO": "leo-token",
            "FTT": "ftx-token",
            "BIT": "bitdao",
            
            // Layer 1 blockchains
            "SUI": "sui",
            "TON": "the-open-network",
            "NEAR": "near",
            "APT": "aptos",
            "SEI": "sei-network",
            "INJ": "injective-protocol",
            "TIA": "celestia",
            "STX": "stacks",
            "MNT": "mantle",
            "KAS": "kaspa",
            "FLR": "flare-networks",
            "ROSE": "oasis-network",
            "OSMO": "osmosis",
            "JUNO": "juno-network",
            "SCRT": "secret",
            "LUNA": "terra-luna-2",
            "LUNC": "terra-luna",
            "USTC": "terrausd",
            
            // Newer/Trending tokens
            "HYPE": "hyperliquid",
            "JUP": "jupiter-exchange-solana",
            "ONDO": "ondo-finance",
            "TRUMP": "maga", // Trump-related meme coin
            "WLD": "worldcoin",
            "PYTH": "pyth-network",
            "JTO": "jito-governance-token",
            "W": "wormhole",
            "DRIFT": "drift-protocol",
            "RAY": "raydium",
            "ORCA": "orca",
            "STEP": "step-finance",
            "SRM": "serum",
            "FIDA": "bonfida",
            
            // Wrapped/Staked tokens
            "WETH": "weth",
            "STETH": "staked-ether",
            "WEETH": "wrapped-eeth",
            "METH": "mantle-staked-ether",
            "LSETH": "liquid-staked-ethereum",
            "RETH": "rocket-pool-eth",
            "CBETH": "coinbase-wrapped-staked-eth",
            "WBTC": "wrapped-bitcoin",
            "WBNB": "wbnb",
            "WMATIC": "wmatic",
            "WAVAX": "wrapped-avax",
            
            // Other notable tokens
            "THETA": "theta-token",
            "TFUEL": "theta-fuel",
            "XDC": "xdce-crowd-sale",
            "FLOW": "flow",
            "HBAR": "hedera-hashgraph",
            "ETC": "ethereum-classic",
            "XMR": "monero",
            "XTZ": "tezos",
            "EGLD": "elrond-erd-2",
            "BSV": "bitcoin-sv",
            "BCH": "bitcoin-cash",
            "CAKE": "pancakeswap-token",
            "RUNE": "thorchain",
            "ZEC": "zcash",
            "DASH": "dash",
            "SKY": "maker", // SKY is related to MakerDAO
            "JLP": "jupiter-perpetuals-liquidity-provider-token",
            "BLUR": "blur",
            "LDO": "lido-dao",
            "RPL": "rocket-pool",
            "CVX": "convex-finance",
            "FXS": "frax-share",
            "ALCX": "alchemix",
            "SPELL": "spell-token",
            "ICE": "ice-token",
            "MAVIA": "heroes-of-mavia",
            "PRIME": "echelon-prime",
            "PIXEL": "pixels",
            "PORTAL": "portal",
            "RONIN": "ronin",
            "STRAX": "stratis",
            "XEM": "nem",
            "MINA": "mina-protocol",
            "ONE": "harmony",
            "CELO": "celo",
            "ZK": "zksync",
            "HOT": "holo"
        ]
        return mapping[symbol.uppercased()] ?? symbol.lowercased()
    }
    
    // Fetch correct icon URL from CoinGecko API with improved error handling and retry logic
    private func fetchCorrectIconUrl() async {
        guard correctIconUrl == nil && !isLoadingIcon && !iconLoadFailed else { return }
        
        await MainActor.run {
            isLoadingIcon = true
            iconLoadFailed = false
        }
        
        let coingeckoId = getCoingeckoId(for: crypto.symbol)
        let maxRetries = 2
        
        for attempt in 0..<maxRetries {
            do {
                let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coingeckoId)")!
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Check HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        break // Success
                    case 429:
                        // Rate limited - wait and retry
                        if attempt < maxRetries - 1 {
                            let delay = Double(attempt + 1) * 2.0 // Exponential backoff
                            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                            continue
                        }
                        throw URLError(.badServerResponse)
                    case 404:
                        // Not found - no point retrying
                        throw URLError(.fileDoesNotExist)
                    default:
                        throw URLError(.badServerResponse)
                    }
                }
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let image = json["image"] as? [String: Any],
                   let largeImageUrl = image["large"] as? String {
                    
                    await MainActor.run {
                        correctIconUrl = largeImageUrl
                        isLoadingIcon = false
                        print("✅ Found correct icon for \(crypto.symbol): \(largeImageUrl)")
                    }
                    return // Success - exit retry loop
                } else {
                    throw URLError(.cannotParseResponse)
                }
                
            } catch {
                if attempt == maxRetries - 1 {
                    // Final attempt failed
                    await MainActor.run {
                        isLoadingIcon = false
                        iconLoadFailed = true
                        print("❌ Failed to load icon for \(crypto.symbol) (ID: \(coingeckoId)) after \(maxRetries) attempts: \(error.localizedDescription)")
                    }
                } else {
                    // Wait before retry (except for 404s)
                    if !error.localizedDescription.contains("404") {
                        let delay = Double(attempt + 1) * 1.0
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    } else {
                        // 404 - don't retry
                        await MainActor.run {
                            isLoadingIcon = false
                            iconLoadFailed = true
                            print("❌ Icon not found for \(crypto.symbol) (ID: \(coingeckoId)): 404")
                        }
                        return
                    }
                }
            }
        }
    }
    
    // Helper function to get rank gradient colors
    private func getRankGradient() -> [Color] {
        switch rank {
        case 1...3:
            return [Color.yellow, Color.orange] // Gold gradient for top 3
        case 4...10:
            return [Color.blue, Color.purple] // Blue-purple for top 10
        case 11...25:
            return [Color.green, Color.cyan] // Green-cyan for top 25
        default:
            return [Color.gray, Color.gray.opacity(0.8)] // Gray for others
        }
    }
    
    // Helper functions for formatting
    private func formatVolume(_ volume: Double?) -> String {
        guard let volume = volume else { return "N/A" }
        if volume >= 1_000_000_000 {
            return String(format: "%.1fB", volume / 1_000_000_000)
        } else if volume >= 1_000_000 {
            return String(format: "%.1fM", volume / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", volume / 1_000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
    
    private func formatSupply(_ supply: Double?) -> String {
        guard let supply = supply else { return "N/A" }
        if supply >= 1_000_000_000_000 {
            return String(format: "%.1fT", supply / 1_000_000_000_000)
        } else if supply >= 1_000_000_000 {
            return String(format: "%.1fB", supply / 1_000_000_000)
        } else if supply >= 1_000_000 {
            return String(format: "%.1fM", supply / 1_000_000)
        } else if supply >= 1_000 {
            return String(format: "%.1fK", supply / 1_000)
        } else {
            return String(format: "%.0f", supply)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isEven ? 0.08 : 0.06),
                            Color.white.opacity(isEven ? 0.04 : 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
            
            VStack(spacing: 20) {
                // Top Row - Enhanced
                HStack(spacing: 16) {
                    // PRO Rank Badge
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: getRankGradient(),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 32)
                            .shadow(color: getRankGradient()[0].opacity(0.3), radius: 5)
                        
                        Text("#\(rank)")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    // Crypto Info Enhanced with Dynamic Icon Loading
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                        center: .topLeading,
                                        startRadius: 5,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            // Dynamic Crypto Icon with improved loading states
                            Group {
                                if isLoadingIcon {
                                    // Loading state
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                        
                                        ProgressView()
                                            .scaleEffect(0.6)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                } else if let iconUrl = correctIconUrl {
                                    // Load the correct icon
                                    AsyncImage(url: URL(string: iconUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32, height: 32)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                                )
                                                .shadow(color: .black.opacity(0.1), radius: 2)
                                        
                                        case .failure(_), .empty:
                                            GradientFallbackIcon(symbol: crypto.symbol, gradient: getCryptoGradient(for: crypto.symbol))
                                        
                                        @unknown default:
                                            GradientFallbackIcon(symbol: crypto.symbol, gradient: getCryptoGradient(for: crypto.symbol))
                                        }
                                    }
                                } else {
                                    // Fallback gradient icon (either failed to load or no URL found)
                                    GradientFallbackIcon(symbol: crypto.symbol, gradient: getCryptoGradient(for: crypto.symbol))
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(crypto.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(crypto.symbol.uppercased())
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Price Section Enhanced
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(crypto.formattedPrice)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .animation(.spring(response: 0.5), value: crypto.currentPrice)
                        
                        HStack(spacing: 6) {
                            Image(systemName: crypto.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 12, weight: .bold))
                            
                            Text("\(crypto.priceChangePercentage24h >= 0 ? "+" : "")\(String(format: "%.2f", crypto.priceChangePercentage24h))%")
                                .font(.system(size: 14, weight: .black))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: crypto.priceChangePercentage24h >= 0 ?
                                        [Color.green, Color.green.opacity(0.7)] :
                                        [Color.red, Color.red.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: (crypto.priceChangePercentage24h >= 0 ? Color.green : Color.red).opacity(0.3), radius: 5)
                        )
                    }
                }
                
                // Chart Section Enhanced
                if !crypto.priceData.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("24H PRICE CHART")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text("MCap: \(crypto.formattedMarketCap)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.02)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            
                            RealTimeChartView(
                                priceData: crypto.priceData,
                                color: crypto.priceChangePercentage24h >= 0 ? .green : .red,
                                showFill: true
                            )
                            .frame(height: 80)
                            .clipped()
                            .cornerRadius(16)
                        }
                    }
                }
                
                // Stats Row Enhanced
                HStack(spacing: 0) {
                    ProStatItem(
                        title: "VOLUME",
                        value: formatVolume(crypto.volume24h),
                        icon: "arrow.up.arrow.down.circle.fill"
                    )
                    
                    Spacer()
                    
                    ProStatItem(
                        title: "SUPPLY",
                        value: formatSupply(crypto.circulatingSupply),
                        icon: "circle.grid.cross.fill"
                    )
                    
                    Spacer()
                    
                    ProStatItem(
                        title: "MARKET CAP",
                        value: crypto.formattedMarketCap,
                        icon: "chart.pie.fill"
                    )
                }
            }
            .padding(24)
        }
        .onAppear {
            Task {
                await fetchCorrectIconUrl()
            }
        }
    }
}

// Helper view for gradient fallback icons
struct GradientFallbackIcon: View {
    let symbol: String
    let gradient: [Color]
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 2)
            
            Text(String(symbol.prefix(3)).uppercased())
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white)
        }
    }
}

// Helper view for pro stat items
struct ProStatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}


// MARK: - CORRECTED Crypto Icon View Component
struct CorrectedCryptoIconView: View {
    let symbol: String
    let iconUrls: [String]
    let gradient: [Color]
    
    @State private var currentUrlIndex = 0
    @State private var hasFailedAll = false
    
    var body: some View {
        Group {
            if hasFailedAll {
                // Final fallback - gradient with symbol
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Text(symbol.prefix(2))
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                }
            } else {
                AsyncImage(url: URL(string: iconUrls[currentUrlIndex])) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    
                    case .failure(_):
                        Color.clear
                            .frame(width: 32, height: 32)
                            .onAppear {
                                tryNextUrl()
                            }
                    
                    case .empty:
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                            
                            ProgressView()
                                .scaleEffect(0.6)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    
                    @unknown default:
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Text(symbol.prefix(2))
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 1)
                        }
                    }
                }
            }
        }
        .onAppear {
            print("🔄 Loading icon for \(symbol): \(iconUrls.first ?? "No URL")")
        }
    }
    
    private func tryNextUrl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if currentUrlIndex < iconUrls.count - 1 {
                currentUrlIndex += 1
                print("🔄 Trying next icon URL for \(symbol): \(iconUrls[currentUrlIndex])")
            } else {
                hasFailedAll = true
                print("❌ All icon URLs failed for \(symbol), using gradient fallback")
            }
        }
    }
}

// MARK: - Separate Crypto Icon View Component
struct CryptoIconView: View {
    let symbol: String
    let iconUrls: [String]
    let gradient: [Color]
    
    @State private var currentUrlIndex = 0
    @State private var hasFailedAll = false
    
    var body: some View {
        Group {
            if hasFailedAll {
                // Final fallback - gradient with symbol
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Text(symbol.prefix(2))
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                }
            } else {
                AsyncImage(url: URL(string: iconUrls[currentUrlIndex])) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    
                    case .failure(_):
                        Color.clear
                            .frame(width: 32, height: 32)
                            .onAppear {
                                tryNextUrl()
                            }
                    
                    case .empty:
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                            
                            ProgressView()
                                .scaleEffect(0.6)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    
                    @unknown default:
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Text(symbol.prefix(2))
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 1)
                        }
                    }
                }
            }
        }
    }
    
    private func tryNextUrl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if currentUrlIndex < iconUrls.count - 1 {
                currentUrlIndex += 1
                print("🔄 Trying next icon URL for \(symbol): \(iconUrls[currentUrlIndex])")
            } else {
                hasFailedAll = true
                print("❌ All icon URLs failed for \(symbol), using gradient fallback")
            }
        }
    }
}
 

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.08),
                        Color(red: 0.05, green: 0.05, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("PRO SETTINGS")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        SettingRow(title: "Auto Refresh", subtitle: "Update prices every 30s", isOn: .constant(true))
                        SettingRow(title: "Push Notifications", subtitle: "Price alerts & updates", isOn: .constant(false))
                        SettingRow(title: "Dark Mode", subtitle: "Always on for PRO users", isOn: .constant(true))
                        SettingRow(title: "Advanced Charts", subtitle: "Technical indicators", isOn: .constant(true))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct SettingRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.cyan)
        }
        .padding(16)
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

// MARK: - Enhanced Top 50 Crypto Service with Both APIs
class Top50CryptoService: ObservableObject {
    @Published var cryptoAssets: [CryptoAsset] = []
    @Published var isLoading = false
    @Published var totalMarketCap: Double = 2_487_000_000_000
    @Published var total24hVolume: Double = 89_500_000_000
    @Published var bitcoinDominance: Double = 52.3
    
    private var refreshTimer: Timer?
    private let cryptoCompareAPIKey = ""
    private let cryptoCoinsAPIKey =
    ""

    
    // Cache for crypto symbols from your API
    private var symbolsCache: [String: CoinInfo] = [:]
    
    struct CoinInfo: Codable {
        let id: String
        let name: String
        let symbol: String
        let image: String?
    }
    
    init() {
        Task {
            await fetchSymbolsFromAPI()
            await fetchTop50Cryptos()
        }
    }
    
    // MARK: - Fetch Symbols from Your Crypto Coins API
    @MainActor
    private func fetchSymbolsFromAPI() async {
        do {
            let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false")!
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let coins = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw URLError(.cannotParseResponse)
            }
            
            symbolsCache.removeAll()
            
            for coin in coins {
                if let symbol = coin["symbol"] as? String,
                   let name = coin["name"] as? String,
                   let id = coin["id"] as? String {
                    
                    symbolsCache[symbol.uppercased()] = CoinInfo(
                        id: id,
                        name: name,
                        symbol: symbol.uppercased(),
                        image: coin["image"] as? String
                    )
                }
            }
            
            print("✅ Successfully cached \(symbolsCache.count) crypto symbols from CoinGecko")
            
        } catch {
            print("❌ Error fetching symbols from CoinGecko: \(error)")
            loadFallbackSymbols()
        }
    }
    
    // MARK: - Enhanced Fallback symbols function
    private func loadFallbackSymbols() {
        let fallbackSymbols = [
            "BTC": "Bitcoin", "ETH": "Ethereum", "BNB": "BNB", "XRP": "XRP",
            "SOL": "Solana", "ADA": "Cardano", "DOGE": "Dogecoin", "AVAX": "Avalanche",
            "DOT": "Polkadot", "MATIC": "Polygon", "TRX": "TRON", "LINK": "Chainlink",
            "UNI": "Uniswap", "LTC": "Litecoin", "ATOM": "Cosmos", "ALGO": "Algorand",
            "XLM": "Stellar", "ICP": "Internet Computer", "VET": "VeChain", "FIL": "Filecoin",
            "THETA": "THETA", "MANA": "Decentraland", "AXS": "Axie Infinity", "SAND": "The Sandbox",
            "CRV": "Curve DAO Token", "AAVE": "Aave", "COMP": "Compound", "MKR": "Maker",
            "SNX": "Synthetix", "YFI": "yearn.finance", "1INCH": "1inch", "BAL": "Balancer",
            "ZRX": "0x", "UMA": "UMA", "REN": "Ren", "BAT": "Basic Attention Token",
            "ENJ": "Enjin Coin", "CHZ": "Chiliz", "HOT": "Holo", "KAVA": "Kava",
            "WAVES": "Waves", "ONT": "Ontology", "ICX": "ICON", "QTUM": "Qtum",
            "ZIL": "Zilliqa", "SC": "Siacoin", "DGB": "DigiByte", "GRT": "The Graph",
            "LRC": "Loopring", "SUSHI": "SushiSwap"
        ]
        
        symbolsCache.removeAll()
        for (symbol, name) in fallbackSymbols {
            symbolsCache[symbol] = CoinInfo(
                id: symbol.lowercased(),
                name: name,
                symbol: symbol,
                image: nil
            )
        }
        print("⚠️ Using fallback crypto symbols: \(symbolsCache.count) loaded")
    }
    
    
    @MainActor
    func fetchTop50Cryptos() async {
        isLoading = true
        
        do {
            // Use symbols from your API if available, otherwise fallback
            let symbols = symbolsCache.isEmpty ?
            "BTC,ETH,BNB,XRP,SOL,ADA,DOGE,AVAX,DOT,MATIC,TRX,LINK,UNI,LTC,ATOM,ALGO,XLM,ICP,VET,FIL,THETA,MANA,AXS,SAND,CRV,AAVE,COMP,MKR,SNX,YFI,1INCH,BAL,ZRX,UMA,REN,BAT,ENJ,CHZ,HOT,KAVA,WAVES,ONT,ICX,QTUM,ZIL,SC,DGB,GRT,LRC,SUSHI" :
            Array(symbolsCache.keys.prefix(50)).joined(separator: ",")
            
            let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(symbols)&tsyms=USD&api_key=\(cryptoCompareAPIKey)")!
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let rawData = json["RAW"] as? [String: [String: [String: Any]]] {
                
                var tempAssets: [CryptoAsset] = []
                var totalMarketCapValue: Double = 0
                var totalVolumeValue: Double = 0
                
                for (symbol, currencyData) in rawData {
                    if let usdData = currencyData["USD"] {
                        let price = usdData["PRICE"] as? Double ?? 0
                        let change24h = usdData["CHANGEPCT24HOUR"] as? Double ?? 0
                        let marketCap = usdData["MKTCAP"] as? Double ?? 0
                        let volume24h = usdData["VOLUME24HOURTO"] as? Double ?? 0
                        let supply = usdData["SUPPLY"] as? Double ?? 0
                        
                        totalMarketCapValue += marketCap
                        totalVolumeValue += volume24h
                        
                        // Enhanced historical data fetching
                        let historicalData = await fetchEnhancedHistoricalData(for: symbol)
                        
                        // Use symbol info from your API if available
                        let coinName = symbolsCache[symbol]?.name ?? getCoinName(for: symbol)
                        
                        let asset = CryptoAsset(
                            id: symbol.lowercased(),
                            name: coinName,
                            symbol: symbol,
                            currentPrice: price,
                            priceChange24h: change24h,
                            priceChangePercentage24h: change24h,
                            marketCap: marketCap,
                            volume24h: volume24h,
                            circulatingSupply: supply,
                            totalSupply: nil,
                            maxSupply: nil,
                            ath: 0,
                            athDate: "",
                            atl: 0,
                            atlDate: "",
                            rank: 0,
                            sparkline7d: nil
                        )
                        
                        tempAssets.append(asset)
                    }
                }
                
                // Enhanced sorting and ranking
                let sortedAssets = tempAssets.sorted { $0.marketCap > $1.marketCap }
                self.cryptoAssets = sortedAssets.enumerated().map { index, asset in
                    CryptoAsset(
                        id: asset.id,
                        name: asset.name,
                        symbol: asset.symbol,
                        currentPrice: asset.currentPrice,
                        priceChange24h: asset.priceChange24h,
                        priceChangePercentage24h: asset.priceChangePercentage24h,
                        marketCap: asset.marketCap,
                        volume24h: asset.volume24h,
                        circulatingSupply: asset.circulatingSupply,
                        totalSupply: asset.totalSupply,
                        maxSupply: asset.maxSupply,
                        ath: asset.ath,
                        athDate: asset.athDate,
                        atl: asset.atl,
                        atlDate: asset.atlDate,
                        rank: index + 1,
                        sparkline7d: asset.sparkline7d
                    )
                }.prefix(50).map { $0 }
                
                self.totalMarketCap = totalMarketCapValue
                self.total24hVolume = totalVolumeValue
                
                // Calculate Bitcoin dominance
                if let bitcoin = self.cryptoAssets.first(where: { $0.symbol.lowercased() == "btc" }) {
                    self.bitcoinDominance = (bitcoin.marketCap / totalMarketCapValue) * 100
                }
                
                print("✅ Successfully fetched \(self.cryptoAssets.count) top cryptocurrencies with PRO real-time data")
                
            } else {
                throw URLError(.badServerResponse)
            }
            
        } catch {
            print("❌ Error fetching top 50 crypto data: \(error)")
            loadEnhancedFallbackData()
        }
        
        isLoading = false
    }
    
    // Enhanced historical data fetching
    private func fetchEnhancedHistoricalData(for symbol: String) async -> [CryptoPriceData] {
        do {
            let url = URL(string: "https://min-api.cryptocompare.com/data/v2/histohour?fsym=\(symbol)&tsym=USD&limit=48&api_key=\(cryptoCompareAPIKey)")!
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataObj = json["Data"] as? [String: Any],
               let dataArray = dataObj["Data"] as? [[String: Any]] {
                
                return dataArray.compactMap { item in
                    if let timestamp = item["time"] as? TimeInterval,
                       let close = item["close"] as? Double,
                       let volume = item["volumeto"] as? Double {
                        return CryptoPriceData(
                            timestamp: Date(timeIntervalSince1970: timestamp),
                            price: close,
                            volume: volume
                        )
                    }
                    return nil
                }
            }
        } catch {
            print("❌ Error fetching enhanced historical data for \(symbol): \(error)")
        }
        
        return []
    }
    
    func startRealTimeUpdates() {
        // More frequent updates for PRO version - every 20 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { _ in
            Task {
                await self.fetchTop50Cryptos()
            }
        }
        print("✅ Started PRO real-time updates for Top 50 cryptos every 20 seconds")
    }
    
    func stopRealTimeUpdates() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        print("🛑 Stopped PRO real-time updates")
    }
    
    @MainActor
    func refreshData() async {
        await fetchTop50Cryptos()
    }
    
    private func loadEnhancedFallbackData() {
        cryptoAssets = [
            CryptoAsset(
                id: "bitcoin",
                name: "Bitcoin",
                symbol: "BTC",
                currentPrice: 45000,
                priceChange24h: 2.5,
                priceChangePercentage24h: 2.5,
                marketCap: 850_000_000_000,
                volume24h: 25_000_000_000,
                circulatingSupply: 19_000_000,
                totalSupply: nil,
                maxSupply: 21_000_000,
                ath: 69000,
                athDate: "2021-11-10",
                atl: 67.81,
                atlDate: "2013-07-06",
                rank: 1,
                sparkline7d: nil
            ),
            // Add more enhanced fallback data...
        ]
        print("⚠️ Using enhanced PRO fallback data")
    }
    
    private func getCoinName(for symbol: String) -> String {
        let nameMap: [String: String] = [
            "BTC": "Bitcoin", "ETH": "Ethereum", "BNB": "BNB", "XRP": "XRP",
            "SOL": "Solana", "ADA": "Cardano", "DOGE": "Dogecoin", "AVAX": "Avalanche",
            "DOT": "Polkadot", "MATIC": "Polygon", "TRX": "TRON", "LINK": "Chainlink",
            "UNI": "Uniswap", "LTC": "Litecoin", "ATOM": "Cosmos", "ALGO": "Algorand",
            "XLM": "Stellar", "ICP": "Internet Computer", "VET": "VeChain", "FIL": "Filecoin",
            "THETA": "THETA", "MANA": "Decentraland", "AXS": "Axie Infinity", "SAND": "The Sandbox",
            "CRV": "Curve DAO Token", "AAVE": "Aave", "COMP": "Compound", "MKR": "Maker",
            "SNX": "Synthetix", "YFI": "yearn.finance", "1INCH": "1inch", "BAL": "Balancer",
            "ZRX": "0x", "UMA": "UMA", "REN": "Ren", "BAT": "Basic Attention Token",
            "ENJ": "Enjin Coin", "CHZ": "Chiliz", "HOT": "Holo", "KAVA": "Kava",
            "WAVES": "Waves", "ONT": "Ontology", "ICX": "ICON", "QTUM": "Qtum",
            "ZIL": "Zilliqa", "SC": "Siacoin", "DGB": "DigiByte", "GRT": "The Graph",
            "LRC": "Loopring", "SUSHI": "SushiSwap"
        ]
        return nameMap[symbol] ?? symbol
    }
    
    deinit {
        stopRealTimeUpdates()
    }
}
 
// MARK: - TextField Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

#Preview {
    Top50CryptosView()
}
