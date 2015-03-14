//
//  motifiedTests.swift
//  motifiedTests
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit
import XCTest

class motifiedTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterUser() {
        let expectation: XCTestExpectation = self.expectationWithDescription("Should Register User without Error")
        
        LoginManager.registerUserWithUsername("username", password: "password", confirm: "password", success: { () -> Void in
            expectation.fulfill()
        }) { (NSURLSessionDataTask, NSError) -> Void in
            XCTAssertNil(NSError, "Should execute without error")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testLogin() {
        let expectation: XCTestExpectation = self.expectationWithDescription("Should login OK")
        
    }
}
