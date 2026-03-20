//
//  PurchaseManager.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 20/07/25.
//

import Foundation
import RevenueCat
import Combine

class PurchaseManager: NSObject, ObservableObject {
    @Published var isProUser = false
    @Published var showPaywall = false
    @Published var offerings: Offerings?
    @Published var customerInfo: CustomerInfo?
    @Published var isPro: Bool = false
    
    override init() {
        super.init()
        setupPurchasesDelegate()
        loadOfferings()
        checkSubscriptionStatus()
    }
    
    private func setupPurchasesDelegate() {
        Purchases.shared.delegate = self
    }
    
    func loadOfferings() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error loading offerings: \(error)")
                } else {
                    print("✅ Offerings loaded successfully: \(offerings?.all.count ?? 0) offerings")
                    self?.offerings = offerings
                }
            }
        }
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let customerInfo = customerInfo {
                    let isProActive = customerInfo.entitlements["PRO"]?.isActive == true
                    self?.isProUser = isProActive
                    self?.isPro = isProActive
                    self?.customerInfo = customerInfo
                    print("🔍 Pro status: \(isProActive)")
                }
            }
        }
    }
    
    func presentPaywall() {
        showPaywall = true
    }
    
    func checkProFeature() -> Bool {
        if !isPro {
            presentPaywall()
            return false
        }
        return true
    }
}

extension PurchaseManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        DispatchQueue.main.async {
            let isProActive = customerInfo.entitlements["PRO"]?.isActive == true
            self.isProUser = isProActive
            self.isPro = isProActive
            self.customerInfo = customerInfo
            print("🔄 Customer info updated - Pro status: \(isProActive)")
        }
    }
}
