//
//  AppGradients.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import SwiftUI

struct AppGradients {
    static let mainBackground = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.08, blue: 0.20),
            Color(red: 0.10, green: 0.15, blue: 0.30),
            Color(red: 0.12, green: 0.20, blue: 0.40)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.25, blue: 0.45).opacity(0.3),
            Color(red: 0.0, green: 0.6, blue: 0.9).opacity(0.15),
            Color(red: 0.1, green: 0.3, blue: 0.6).opacity(0.2)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardBackground = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.25, blue: 0.45).opacity(0.25),
            Color(red: 0.0, green: 0.6, blue: 0.9).opacity(0.12),
            Color(red: 0.1, green: 0.3, blue: 0.6).opacity(0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // ✨ SMOOTH CLASSIC - 5 Color
    static let primaryButton = LinearGradient(
        colors: [
            Color(red: 0.01, green: 0.02, blue: 0.12),  // Space black
            Color(red: 0.02, green: 0.05, blue: 0.18),  // Deep space
            Color(red: 0.04, green: 0.10, blue: 0.25),  // Cosmic blue
            Color(red: 0.08, green: 0.18, blue: 0.35),  // Nebula blue
            Color(red: 0.12, green: 0.25, blue: 0.45),  // Star blue
            Color(red: 0.15, green: 0.35, blue: 0.55),  // Galaxy blue
            Color(red: 0.18, green: 0.45, blue: 0.60)   // Cosmic cyan (subtle)
        ],
        startPoint: UnitPoint(x: 0.1, y: 0.1),
        endPoint: UnitPoint(x: 0.9, y: 0.9)
    )
    
    static let successButton = LinearGradient(
        colors: [
            Color(red: 0.0, green: 0.25, blue: 0.15),
            Color(red: 0.0, green: 0.55, blue: 0.35),
            Color(red: 0.0, green: 0.80, blue: 0.50),
            Color(red: 0.2, green: 1.0, blue: 0.70)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warningButton = LinearGradient(
        colors: [
            Color(red: 0.45, green: 0.20, blue: 0.0),
            Color(red: 0.75, green: 0.40, blue: 0.05),
            Color(red: 1.0, green: 0.65, blue: 0.15),
            Color(red: 1.0, green: 0.85, blue: 0.35)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.15, blue: 0.40),
            Color(red: 0.15, green: 0.45, blue: 0.75),
            Color(red: 0.0, green: 0.75, blue: 0.90),
            Color(red: 0.25, green: 0.85, blue: 1.0),
            Color(red: 0.45, green: 0.35, blue: 0.85)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let cryptoGradient = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.08, blue: 0.22),
            Color(red: 0.08, green: 0.25, blue: 0.45),
            Color(red: 0.0, green: 0.60, blue: 0.80),
            Color(red: 0.10, green: 0.80, blue: 0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassOverlay = LinearGradient(
        colors: [
            Color.white.opacity(0.18),
            Color(red: 0.0, green: 0.70, blue: 0.90).opacity(0.12),
            Color.white.opacity(0.08),
            Color(red: 0.2, green: 0.80, blue: 1.0).opacity(0.06)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let premiumGradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.18, blue: 0.38),
            Color(red: 0.20, green: 0.40, blue: 0.70),
            Color(red: 0.0, green: 0.70, blue: 0.95),
            Color(red: 0.30, green: 0.85, blue: 1.0),
            Color(red: 0.60, green: 0.90, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleCard = LinearGradient(
        colors: [
            Color(red: 0.12, green: 0.20, blue: 0.35).opacity(0.45),
            Color(red: 0.05, green: 0.40, blue: 0.65).opacity(0.25),
            Color(red: 0.0, green: 0.60, blue: 0.80).opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
