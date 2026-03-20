//
//  CreateWatchlistView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import SwiftUI

struct CreateWatchlistView: View {
    @ObservedObject var watchlistManager: WatchlistManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var watchlistName = ""
    @State private var selectedIcon = "heart.fill"
    
    private let availableIcons = [
        "heart.fill", "star.fill", "bookmark.fill", "flag.fill",
        "diamond.fill", "crown.fill", "flame.fill", "bolt.fill",
        "chart.line.uptrend.xyaxis", "dollarsign.circle.fill",
        "bitcoinsign.circle.fill", "chart.bar.fill"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    headerSection
                    nameInputSection
                    iconSelectionSection
                    Spacer()
                    createButtonSection
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Create Watchlist")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Organize your crypto portfolio")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Watchlist Name")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("Enter name...", text: $watchlistName)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Icon")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(availableIcons, id: \.self) { icon in
                    iconButton(for: icon)
                }
            }
        }
    }
    
    // Break down the icon button to fix type-checking issue
    private func iconButton(for icon: String) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedIcon = icon
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(selectedIcon == icon ? .white : .white.opacity(0.6))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(iconBackgroundFill(for: icon))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(selectedIcon == icon ? 0.3 : 0.2), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: selectedIcon)
    }
    
    // Separate function to handle background fill
    private func iconBackgroundFill(for icon: String) -> LinearGradient {
        if selectedIcon == icon {
            return LinearGradient(
                colors: [Color.cyan, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var createButtonSection: some View {
        Button(action: {
            if !watchlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                watchlistManager.createWatchlist(name: watchlistName, icon: selectedIcon)
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                
                Text("Create Watchlist")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(createButtonBackground)
            .disabled(watchlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.bottom, 40)
    }
    
    // Fixed computed property for button background
    private var createButtonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                watchlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                AnyShapeStyle(Color.white.opacity(0.2)) :
                AnyShapeStyle(LinearGradient(
                    colors: [Color.cyan, Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            )
    }
}

#Preview {
    CreateWatchlistView(watchlistManager: WatchlistManager())
}
