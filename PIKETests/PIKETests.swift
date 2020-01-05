//
//  PIKETests.swift
//  PIKETests
//
//  Created by Datvuong Lee on 12/30/19.
//  Copyright © 2019 Devin Lee. All rights reserved.
//

import XCTest
@testable import PIKE

class PIKETests: XCTestCase {

    func testExample() {
        let order = Order(name: "One", size: "5", quantity: "7")
        XCTAssert(order.testFun())
        let order2 = Order(name: "One", size: "-5", quantity: "-7")
        XCTAssert(order2.testFun())
    }

}
