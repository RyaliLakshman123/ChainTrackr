//
//  ContentView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI

 struct ContentView: View {
    @StateObject private var purchaseManager = PurchaseManager()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient fills screen
            AppGradients.primaryButton
                .ignoresSafeArea(.all)

            // Main content - Add bottom padding so it doesn't overlap tab bar
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(purchaseManager)
                case 1:
                    WatchlistView()
                        .environmentObject(purchaseManager)
                case 2:
                    TrackrAIView()
                        .padding(.bottom, getSafeAreaBottom() - 10) // <-- FIX
                case 3:
                    SettingsView()
                default:
                    HomeView()
                        .environmentObject(purchaseManager)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            
            // Custom Floating Tab Bar
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.bottom, -15)
        }
        .ignoresSafeArea(edges: .bottom) // Only ignore bottom for tab bar
    }
}

// Safe area helper function
private func getSafeAreaBottom() -> CGFloat {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        return window.safeAreaInsets.bottom
    }
    return 0
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animationNamespace
    
    let tabs = [
        TabItem(icon: "house", title: "Home", tag: 0),
        TabItem(icon: "heart", title: "Watchlist", tag: 1),
        TabItem(icon: "brain.head.profile", title: "AI", tag: 2),
        TabItem(icon: "gearshape", title: "Settings", tag: 3)
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.tag) { tab in
                FloatingTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab.tag,
                    animationNamespace: animationNamespace
                ) {
                    // Add haptic feedback when switching tabs
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        selectedTab = tab.tag
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Main background with blur
                Capsule()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                
                // Gradient border
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.cyan.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 15)
        .padding(.horizontal, 20)
        .padding(.bottom, getSafeAreaBottom())
    }
    
    private func getSafeAreaBottom() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return max(window.safeAreaInsets.bottom, 10)
        }
        return 10
    }
}

struct FloatingTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animationNamespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: isSelected ? 8 : 0) {
                Image(systemName: isSelected ? "\(tab.icon).fill" : tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                if isSelected {
                    Text(tab.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "selectedTab", in: animationNamespace)
                            .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabItem {
    let icon: String
    let title: String
    let tag: Int
}

#Preview {
    ContentView()
}
