//
//  JudoErrors.swift
//  Judo
//
//  Copyright (c) 2015 Alternative Payments Ltd
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

import Foundation

public let JudoErrorDomain = "com.judopay.error"

public struct JudoError: ErrorType {
    public var userInfo: JSONDictionary?
    public var judoCode: JudoErrorCode
    
    public enum JudoErrorCode: Int {
        // MARK: Device Errors
        case Unknown, ParameterError, ResponseParseError, LuhnValidationError, JudoIDInvalidError, SerializationError, RequestError, TokenSecretError, CardAndTokenError, CardOrTokenMissingError, PKPaymentMissingError, JailbrokenDeviceDisallowedError
        case LocationServicesDisabled = 91
        
        // MARK: Card Errors
        case CardLengthMismatchError, InputLengthMismatchError, InvalidCardNumber, InvalidEntry
        
        // MARK: 3DS Error
        case ThreeDSAuthRequest, Failed3DSError
        
        // MARK: User Errors
        case UserDidCancel = -999
        
        // MARK: Server errors
        
        // ProcessingException
        // DataException
        // SecurityException
        // GatewayException
        
        case YouAreGoodToGo = 20
        case AccessForbiddenError = 403
    }
    
    public var domain: String { return JudoErrorDomain }
    public var _domain: String { return JudoErrorDomain }
    public var _code: Int { return 0 }
    
    public init(_ code: JudoErrorCode, _ userInfo: JSONDictionary? = nil) {
        self.judoCode = code
        self.userInfo = userInfo
    }
    
    public static func fromNSError(error: NSError) -> JudoError {
        // TODO:
        let error = JudoError(.Unknown, nil)
        return error
    }
    
    public func rawValue() -> Int {
        // TODO:
        return 0
    }
    
    public func toNSError() -> NSError {
        return NSError(domain: JudoErrorDomain, code: self.judoCode.rawValue, userInfo: self.userInfo)
    }
    
}
