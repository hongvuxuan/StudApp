//
//  ApiRoutesTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ApiRoutesTests : XCTestCase {
    struct Routes : ApiRoutes {
        let path: String = ""
    }

    func testType_Nil() {
        XCTAssertNil(Routes().type)
    }
}
