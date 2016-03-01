//
//  PaymentTests.swift
//  JudoTests
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

class TokenPaymentTests: JudoTestCase {
    
    func testJudoMakeValidTokenPayment() {
        do {
            // Given I have an SDK
            // When I provide the required fields
            let registerCard = try judo.registerCard(myJudoID, reference: validReference).card(validVisaTestCard)
            
            let expectation = self.expectationWithDescription("token payment expectation")
            
            try registerCard.completion({ (data, error) -> () in
                if let _ = error {
                    XCTFail()
                } else {
                    guard let uData = data else {
                        XCTFail("no data available")
                        return // BAIL
                    }
                    let payToken = PaymentToken(consumerToken: uData.items.first!.consumer.consumerToken, cardToken: uData.items.first!.cardDetails.cardToken!)
                    do {
                        // Then I should be able to make a token payment
                        try self.judo.payment(self.myJudoID, amount: self.oneGBPAmount, reference: self.validReference).paymentToken(payToken).completion({ (data, error) -> () in
                            if let error = error {
                                XCTFail("api call failed with error: \(error)")
                            }
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("exception thrown: \(error)")
                    }
                }
            })
            XCTAssertNotNil(registerCard)
            XCTAssertEqual(registerCard.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func testJudoMakeTokenPaymentWithoutToken() {
        do {
            // Given I have an SDK
            let registerCard = try judo.registerCard(myJudoID, reference: validReference).card(validVisaTestCard)
            
            let expectation = self.expectationWithDescription("token payment expectation")
            
            try registerCard.completion({ (data, error) -> () in
                if let _ = error {
                    XCTFail()
                } else {
                    
                    // When I do not provide a card token
                    do {
                        try self.judo.payment(self.myJudoID, amount: self.oneGBPAmount, reference: self.validReference).completion({ (data, error) -> () in
                            XCTFail("api call failed with error: \(error)")
                            expectation.fulfill()
                        })
                    } catch {
                        // Then I should receive an error
                        if let error = error as? JudoError {
                            XCTAssertEqual(error.code, JudoErrorCode.CardOrTokenMissingError)
                        } else {
                            XCTFail("exception thrown: \(error)")
                        }
                        expectation.fulfill()
                    }
                }
            })
            XCTAssertNotNil(registerCard)
            XCTAssertEqual(registerCard.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func testJudoMakeTokenPaymentWithoutReference() {
        do {
            // Given I have an SDK
            let registerCard = try judo.registerCard(myJudoID, reference: validReference).card(validVisaTestCard)
            
            let expectation = self.expectationWithDescription("token payment expectation")
            
            try registerCard.completion({ (data, error) -> () in
                if let _ = error {
                    XCTFail()
                } else {
                    guard let uData = data else {
                        XCTFail("no data available")
                        return // BAIL
                    }
                    let payToken = PaymentToken(consumerToken: uData.items.first!.consumer.consumerToken, cardToken: uData.items.first!.cardDetails.cardToken!)
                    
                    do {
                        // When I do not provide a consumer reference
                        // Then I should receive an error
                        try self.judo.payment(self.myJudoID, amount: self.oneGBPAmount, reference: self.invalidReference).paymentToken(payToken).completion({ (response, error) -> () in
                            XCTAssertNil(response)
                            XCTAssertNotNil(error)
                            XCTAssertEqual(error!.code, JudoErrorCode.General_Model_Error)
                            
                            XCTAssertEqual(error?.details?.count, 2)
                            
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("exception thrown: \(error)")
                    }
                }
            })
            XCTAssertNotNil(registerCard)
            XCTAssertEqual(registerCard.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func testJudoMakeTokenPaymentWithoutAmount() {
        do {
            // Given I have an SDK
            let registerCard = try judo.registerCard(myJudoID, reference: validReference).card(validVisaTestCard)
            
            let expectation = self.expectationWithDescription("token payment expectation")
            
            try registerCard.completion({ (data, error) -> () in
                if let _ = error {
                    XCTFail()
                } else {
                    guard let uData = data else {
                        XCTFail("no data available")
                        return // BAIL
                    }
                    let payToken = PaymentToken(consumerToken: uData.items.first!.consumer.consumerToken, cardToken: uData.items.first!.cardDetails.cardToken!)
                    
                    do {
                        // When I do not provide an amount
                        // Then I should receive an error
                        try self.judo.payment(self.myJudoID, amount: self.invalidCurrencyAmount, reference: self.validReference).paymentToken(payToken).completion({ (response, error) -> () in
                            XCTAssertNil(response)
                            XCTAssertNotNil(error)
                            XCTAssertEqual(error!.code, JudoErrorCode.General_Model_Error)
                            
                            XCTAssertEqual(error?.details?.count, 3)
                            
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("exception thrown: \(error)")
                    }
                }
            })
            // Then
            XCTAssertNotNil(registerCard)
            XCTAssertEqual(registerCard.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
}
