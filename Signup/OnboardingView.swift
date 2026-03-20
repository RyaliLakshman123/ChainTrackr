//
//  OnboardingView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("bitcoin")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .padding(.horizontal, -1)
                
                // Dark overlay for better text readability
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // below spacer moves the two buttons down
                    Spacer()
                    
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Your")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Text("Crypto Journey")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Create your account to trade, store, and grow your digital assets securely")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                print("Sign Up tapped")
                            }) {
                                Text("Sign Up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.2, blue: 0.6),     // Bright Pink
                                                Color(red: 0.0, green: 0.8, blue: 0.9),     // Cyan
                                                Color(red: 0.2, green: 0.9, blue: 0.6),     // Green
                                                Color(red: 0.8, green: 0.4, blue: 1.0)      // Purple-Pink
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                print("Log In tapped")
                            }) {
                                Text("Log In")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.top, 32)
                    }
                    .padding(.horizontal, 52)
                    .padding(.leading, -25)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct CryptoCoinView: View {
    let color: LinearGradient
    let imageName: String
    let offset: CGSize
    let rotation: Double
    let scale: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 120, height: 120)
                .shadow(
                    color: .black.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .offset(offset)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
