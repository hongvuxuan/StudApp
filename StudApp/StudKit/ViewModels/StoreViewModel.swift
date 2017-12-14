//
//  StoreViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class StoreViewModel: NSObject {
    private let storeService = ServiceContainer.default[StoreService.self]
    private var productsRequest: SKProductsRequest?

    public override init() {}

    public func loadProducts() {
        productsRequest = SKProductsRequest(productIdentifiers: [
            storeService.subscriptionProductIdentifier, storeService.unlockProductIdentifier
        ])
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    public var didLoadProducts: (() -> Void)?

    public private(set) var subscriptionProduct: SKProduct?

    public private(set) var unlockProduct: SKProduct?

    public func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    public func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - Product Request Delegate

extension StoreViewModel: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        subscriptionProduct = response.products.first { $0.productIdentifier == storeService.subscriptionProductIdentifier }
        unlockProduct = response.products.first { $0.productIdentifier == storeService.unlockProductIdentifier }

        didLoadProducts?()
        productsRequest = nil
    }
}
