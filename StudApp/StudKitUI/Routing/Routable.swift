//
//  Routable.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public protocol Routable: class {
    func prepareDependencies(for route: Routes)
}

// MARK: - Default Implementation

public extension Routable {
    func prepareDependencies(for _: Routes) {}
}