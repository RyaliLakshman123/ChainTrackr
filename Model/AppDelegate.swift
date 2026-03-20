//
//  AppDelegate.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import SwiftUI
import RevenueCat
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // First test StoreKit directly BEFORE configuring RevenueCat
        testStoreKitProducts()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "")
        return true
    }
    
    func testStoreKitProducts() {
        print("🧪 Testing StoreKit products...")
        let productIDs = Set(["CTr_5999_1y", "Car_5.99_1m"])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
}

extension AppDelegate: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("✅ Valid StoreKit products found: \(response.products.count)")
        for product in response.products {
            print("   - Product ID: \(product.productIdentifier), Price: \(product.price)")
        }
        
        if !response.invalidProductIdentifiers.isEmpty {
            print("❌ Invalid product IDs: \(response.invalidProductIdentifiers)")
        }
        
        if response.products.isEmpty {
            print("🚨 NO PRODUCTS FOUND - StoreKit configuration issue!")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ StoreKit request failed: \(error)")
    }
}
