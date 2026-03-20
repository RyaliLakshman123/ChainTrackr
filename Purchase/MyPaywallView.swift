//
//  MyPaywallView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 16/07/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct MyPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        PaywallView()
            .onAppear {
                debugPaywallInfo()
            }
            .onPurchaseCompleted { customerInfo in
                print("✅ Purchase completed!")
                purchaseManager.checkSubscriptionStatus()
                dismiss()
            }
            .onRestoreCompleted { customerInfo in
                print("✅ Restore completed!")
                purchaseManager.checkSubscriptionStatus()
                dismiss()
            }
            .onPurchaseFailure { error in
                print("❌ Purchase failed: \(error)")
            }
            .onPurchaseCancelled {
                print("🚫 Purchase cancelled")
            }
    }
    
    private func debugPaywallInfo() {
        if let offerings = purchaseManager.offerings,
           let currentOffering = offerings.current {
            print("🔍 Current offering: \(currentOffering.identifier)")
            print("🔍 Available packages: \(currentOffering.availablePackages.map { $0.identifier })")
            
            if let paywall = currentOffering.paywall {
                print("🔍 Paywall template name: \(paywall.templateName)")
            } else {
                print("🔍 No custom paywall found, using default")
            }
        } else {
            print("🔍 No offerings available")
        }
    }
}

struct MyPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        MyPaywallView()
            .environmentObject(PurchaseManager())
    }
}
