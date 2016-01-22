//
//  Model.swift
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

import Foundation


/**
 **BillingCountry**
 
 BillingCountry enum to simplify identifying a billing country for a given Card
 */
@objc public enum BillingCountry: Int {
    /// United Kingdom
    case UK
    /// United States of America
    case USA
    /// Canada
    case Canada
    /// Other
    case Other
    
    
    /// simple helper to receive all values of the struct as an array
    public static let allValues = [UK, USA, Canada, Other]
    
    
    /**
     Transacting with AMEX required ISO codes instead of Unicode representation of a Country
     
     - returns: the ISO code as an Int for the receiver
     */
    public func ISOCode() -> Int? {
        switch self {
        case UK:
            return 826
        case USA:
            return 840
        case Canada:
            return 124
        case Other:
            return nil
        }
    }
    
    
    /**
     different countries have different names for Postal Code description. This method returns the receivers version of a string representation
     
     - returns: a String
     */
    public func titleDescription() -> String {
        switch self {
        case .USA:
            return "ZIP code"
        case .Canada:
            return "Postal code"
        default:
            return "Post code"
        }
    }
    
    
    /**
     get a string representation of a title
     
     - returns: a String object
     */
    public func title() -> String {
        switch self {
        case .USA:
            return "USA"
        case .Canada:
            return "Canada"
        case .UK:
            return "UK"
        case .Other:
            return "Other"
        }
    }
}

/**
 **Address object for card transactions**
 
 the Address object stores information around the address that is related to a card
*/
public class Address: NSObject {
    /// line one of the address
    public let line1: String?
    /// line two of the address
    public let line2: String?
    /// line three of the address
    public let line3: String?
    /// town of the address
    public let town: String?
    /// post code of the address
    public let postCode: String?
    /// billing country of the address
    public let country: BillingCountry?
    
    /**
     designated initialiser
     
     - parameter line1:    line one
     - parameter line2:    line two
     - parameter line3:    line three
     - parameter town:     town
     - parameter postCode: post code
     - parameter country:  country
     
     - returns: an address object
     */
    public init(line1: String? = nil, line2: String? = nil, line3: String? = nil, town: String? = nil, postCode: String? = nil, country: BillingCountry? = nil) {
        self.line1 = line1
        self.line2 = line2
        self.line3 = line3
        self.town = town
        self.postCode = postCode
        self.country = country
    }
    
    
    /**
     dictionary representation of the address object
     
     - returns: a dictionary containing all available infos
     */
    func dictionaryRepresentation() -> NSDictionary {
        let dict = NSMutableDictionary()
        if let line1 = self.line1 {
            dict.setValue(line1, forKey: "line1")
        }
        if let line2 = self.line2 {
            dict.setValue(line2, forKey: "line2")
        }
        if let line3 = self.line3 {
            dict.setValue(line3, forKey: "line3")
        }
        if let town = self.town {
            dict.setValue(town, forKey: "town")
        }
        if let postCode = self.postCode {
            dict.setValue(postCode, forKey: "postCode")
        }
        if let country = self.country, let countryCode = country.ISOCode() {
            dict.setValue(countryCode, forKey: "countryCode")
        }
        return dict.copy() as! NSDictionary
    }
    
}
