//
//  RefundTests.swift
//  Judo
//
//  Copyright (c) 2016 Alternative Payments Ltd
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import XCTest
@testable import Judo

class RefundTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Judo.setToken(token, secret: secret)
        
        Session.isTesting = true
        Judo.sandboxed = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        Session.isTesting = false
        Judo.sandboxed = false
    }
    
    func testRefund() {
        // Given
        let receiptID = "1497684"
        let amount = Amount(decimalNumber: 30, currency: .GBP)
        let payRef = "payment123asd"
        
        let expectation = self.expectationWithDescription("refund expectation")

        // When
        do {
            let refund = try Judo.refund(receiptID, amount: amount, paymentReference: payRef).completion({ (dict, error) -> () in
                if let error = error {
                    XCTFail("api call failed with error: \(error)")
                } else {
                    expectation.fulfill()
                }
            })

            // Then
            XCTAssertNotNil(refund)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
}
