//
//  StoreService.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

final class StoreService: NSObject {
    // MARK: - Constants

    let subscriptionProductIdentifier = "SteffenRyll.StudApp.Subscription"

    let unlockProductIdentifier = "SteffenRyll.StudApp.Unlock"

    // MARK: - Life Cycle

    init(addAsObserver _: Bool = true) {
        super.init()

        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Managing State

    private(set) lazy var state = State.fromDefaults ?? .locked

    func validateState(handler: @escaping ResultHandler<State>) {
        handler(.success(state))
    }
}

// MARK: - Payment Transaction Observer

extension StoreService: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            updateState(using: transaction)
        }
    }

    private func updateState(using transaction: SKPaymentTransaction) {
        switch transaction.transactionState {
        case .purchased, .restored:
            state = .unlocked(validatedByServer: false)
            state.toDefaults()
        default:
            break
        }
    }
}
