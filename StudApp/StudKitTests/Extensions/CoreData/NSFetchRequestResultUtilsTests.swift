//
//  NSFetchRequestResultUtilsTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class NSFetchRequestResultUtilsTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "C0").coreDataObject(in: context)
        try! CourseResponse(id: "C1").coreDataObject(in: context)
    }

    func testFetch_All() {
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C0", "C1"])
    }
}
