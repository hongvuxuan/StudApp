//
//  FetchableTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class FetchableTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(target: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "0", title: "A").coreDataModel(in: context)
        try! CourseResponse(id: "1", title: "B").coreDataModel(in: context)
    }

    func testFetch_All_Courses() {
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(courses.count, 2)
        XCTAssertEqual(courses.map { $0.id }.set, ["0", "1"].set)
    }
}
