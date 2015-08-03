//
//  JudoTests.swift
//  JudoTests
//
//  Created by Hamon Riazy on 17/07/2015.
//  Copyright © 2015 Judo Payments. All rights reserved.
//

import XCTest
@testable import Judo

let token = "3x2dQPx5HiyD1zir"
let secret = "17aad220942556910e6c461bfb79b2c2d294a3de3c35c2f5484ba4d5dddadb93"

let strippedJudoID = "100963875"

class JudoTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testJudoSupportedNetworks() {
        let supportedNetworks = Judo.supportedNetworks
        let cardTypes: [CardNetwork] = [.Visa(.Debit), .MasterCard(.Debit), .MasterCard(.Credit), .AMEX]
        XCTAssert(supportedNetworks == cardTypes)
    }
    
    
    
    func testJudoErrorDomain() {
        let errorDomain = JudoErrorDomain
        XCTAssertNotNil(errorDomain)
    }
    
    
    
    func testJudoSandboxMode() {
        XCTAssertEqual(Judo.endpoint, "https://partnerapi.judopay.com/")
        Judo.sandboxed = true
        XCTAssertEqual(Judo.endpoint, "https://partnerapi.judopay-sandbox.com/")
    }
    
    
    
    func testSetTokenAndSecret() {
        // Given
        XCTAssertFalse(Judo.didSetTokenAndSecret())
        
        // When
        Judo.setToken(token, secret: secret)
        
        // Then
        XCTAssertTrue(Judo.didSetTokenAndSecret())
    }

}