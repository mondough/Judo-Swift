//
//  PaymentTests.swift
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
import CoreLocation
@testable import Judo


class PaymentTests: XCTestCase {
    
    let judo = Judo(token: token, secret: secret)
    
    override func setUp() {
        super.setUp()
        judo.sandboxed = true
    }
    
    
    
    override func tearDown() {
        judo.sandboxed = false
        super.tearDown()
    }
    
    
    
    func testPayment() {
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let amount = Amount(amountString: "30", currency: .GBP)
        do {
            let payment = try judo.payment(myJudoID, amount: amount, reference: references)
            XCTAssertNotNil(payment)
        } catch {
            XCTFail()
        }
    }
    
    

    func testJudoMakeValidPayment() {
        // Given
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let card = Card(number: "4976000000003436", expiryDate: "12/20", cv2: "452")
        let amount = Amount(amountString: "30", currency: .GBP)
        let emailAddress = "hans@email.com"
        let mobileNumber = "07100000000"
        
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 65)
        
        let expectation = self.expectationWithDescription("payment expectation")
        
        // When
        do {
            let makePayment = try judo.payment(myJudoID, amount: amount, reference: references).card(card).location(location).contact(mobileNumber, emailAddress).completion({ (data, error) -> () in
                if let error = error {
                    XCTFail("api call failed with error: \(error)")
                }
                expectation.fulfill()
            })
            // Then
            XCTAssertNotNil(makePayment)
            XCTAssertEqual(makePayment.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    
    func testJudoMakeValidTokenPayment() {
        // Given
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let card = Card(number: "4976000000003436", expiryDate: "12/20", cv2: "452")
        let amount = Amount(amountString: "30", currency: .GBP)
        let emailAddress = "hans@email.com"
        let mobileNumber = "07100000000"
        
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 65)
        
        let expectation = self.expectationWithDescription("payment expectation")
        
        // When
        do {
            let makePayment = try judo.payment(myJudoID, amount: amount, reference: references).card(card).location(location).contact(mobileNumber, emailAddress).completion({ (data, error) -> () in
                if let _ = error {
                    XCTFail()
                } else {
                    guard let uData = data else {
                        XCTFail("no data available")
                        return // BAIL
                    }
                    let payToken = PaymentToken(consumerToken: uData.items.first!.consumer.consumerToken, cardToken: uData.items.first!.cardDetails.cardToken!)
                    do {
                        try self.judo.payment(myJudoID, amount: amount, reference: references).paymentToken(payToken).completion({ (data, error) -> () in
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
            // Then
            XCTAssertNotNil(makePayment)
            XCTAssertEqual(makePayment.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    
    func testJudoMakeInvalidJudoIDPayment() throws {
        // Given
        // allowed length for judoID is 6 to 10 chars
        let tooShortJudoID = "33412" // 5 chars not allowed
        let tooLongJudoID = "33224433441" // 11 chars not allowed
        let luhnInvalidJudoID = "33224433"
        var parameterError = false
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let amount = Amount(amountString: "30", currency: .GBP)

        // When
        do {
            try judo.payment(tooShortJudoID, amount: amount, reference: references) // this should fail
        } catch let error as JudoError {
            // Then
            switch error.code {
            case .JudoIDInvalidError, .LuhnValidationError:
                parameterError = true
            default:
                XCTFail("exception thrown: \(error)")
            }
        }
        XCTAssertTrue(parameterError)
        
        parameterError = false
        // When
        do {
            try judo.payment(tooLongJudoID, amount: amount, reference: references) // this should fail
        } catch let error as JudoError {
            switch error.code {
            case .JudoIDInvalidError, .LuhnValidationError:
                parameterError = true
            default:
                XCTFail("exception thrown: \(error)")
            }
        }
        XCTAssertTrue(parameterError)
        
        parameterError = false
        // When
        do {
            try judo.payment(luhnInvalidJudoID, amount: amount, reference: references) // this should fail
        } catch let error as JudoError {
            switch error.code {
            case .JudoIDInvalidError, .LuhnValidationError:
                parameterError = true
            default:
                XCTFail("exception thrown: \(error)")
            }
        }
        XCTAssertTrue(parameterError)
    }
    
    
    
    func testJudoValidation() {
        // Given
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let card = Card(number: "4976000000003436", expiryDate: "12/20", cv2: "452")
        let amount = Amount(amountString: "30", currency: .GBP)
        let emailAddress = "hans@email.com"
        let mobileNumber = "07100000000"
        
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 65)
        
        let expectation = self.expectationWithDescription("payment expectation")
        
        // When
        do {
            let makePayment = try judo.payment(myJudoID, amount: amount, reference: references).card(card).location(location).contact(mobileNumber, emailAddress).validate { dict, error in
                if let error = error {
                    XCTAssertEqual(error.code, JudoErrorCode.Validation_Passed)
                } else {
                    XCTFail("api call failed with error: \(error)")
                }
                expectation.fulfill()
            }
            // Then
            XCTAssertNotNil(makePayment)
            XCTAssertEqual(makePayment.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        self.waitForExpectationsWithTimeout(30.0, handler: nil)
        
    }

}
