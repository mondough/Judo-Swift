//
//  Model.swift
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


/**
*  the Card object stores all the necessary card information to make a transaction
*/
public struct Card {
    
    /// the minimum card length constant
    public static let minimumLength = 12
    /// the maximum card length constant
    public static let maximumLength = 19
    
    /// The card number should be submitted without any whitespace or non-numeric characters
    public let number: String
    /// The expiry date should be submitted as MM/YY
    public let expiryDate: String
    /// CV2 from the credit card, also known as the card verification value (CVV) or security code. It's the 3 or 4 digit number on the back of your credit card
    public let cv2: String
    /// The registered address for the card
    public let address: Address?
    
    public init(number: String, expiryDate: String, cv2: String, address: Address?) {
        self.number = number
        self.expiryDate = expiryDate
        self.cv2 = cv2
        self.address = address
    }
    
}


/**
the CardType enum is a value type for CardNetwork to further identify card types

- Debit:   Debit Card type
- Credit:  Credit Card type
- Unknown: Unknown Card type
*/
public enum CardType {
    case Debit, Credit, Unknown
}


/**
the CardNetwork enum depicts the Card Network type of a given Card object

- Visa:       Visa Card Network
- MasterCard: MasterCard Network
- AMEX:       American Express Card Network
*/
public enum CardNetwork: Equatable {
    case Visa(CardType), MasterCard(CardType), AMEX, DinersClub, Maestro, ChinaUnionPay, Discover, InterPayment, InstaPayment, JCB, Dankort, UATP, Unknown
    
    public func stringValue() -> String {
        switch self {
        case .Visa(.Debit), .Visa(.Credit), .Visa(.Unknown):
            return "Visa"
        case .MasterCard(.Debit), .MasterCard(.Credit), .MasterCard(.Unknown):
            return "MasterCard"
        case .AMEX:
            return "AMEX"
        case .DinersClub:
            return "Diners Club"
        case .Maestro:
            return "Maestro"
        case .ChinaUnionPay:
            return "China UnionPay"
        case .Discover:
            return "Discover"
        case .InterPayment:
            return "InterPayment"
        case .InstaPayment:
            return "InstaPayment"
        case .JCB:
            return "JCB"
        case .Dankort:
            return "Dankort"
        case .UATP:
            return "UATP"
        case .Unknown:
            return "Unknown"
        }
    }
}


/**
CardNetwork Equatable function

- Parameter lhs: left hand side of the compare method
- Parameter rhs: right hand side of the compare method

- Returns: Boolean that indicates wether the two objects are equal or not
*/
public func ==(lhs: CardNetwork, rhs: CardNetwork) -> Bool {
    switch lhs {
    case .Visa(.Debit):
        switch rhs {
        case .Visa(.Debit), .Visa(.Unknown):
            return true
        default:
            return false
        }
    case .Visa(.Credit):
        switch rhs {
        case .Visa(.Credit), .Visa(.Unknown):
            return true
        default:
            return false
        }
    case .Visa(.Unknown):
        switch rhs {
        case .Visa(.Credit), .Visa(.Debit), .Visa(.Unknown):
            return true
        default:
            return false
        }
    case .MasterCard(.Debit):
        switch rhs {
        case .MasterCard(.Debit), .MasterCard(.Unknown):
            return true
        default:
            return false
        }
    case .MasterCard(.Credit):
        switch rhs {
        case .MasterCard(.Credit), .MasterCard(.Unknown):
            return true
        default:
            return false
        }
    case .MasterCard(.Unknown):
        switch rhs {
        case .MasterCard(.Credit), .MasterCard(.Debit), .MasterCard(.Unknown):
            return true
        default:
            return false
        }
    case .AMEX:
        switch rhs {
        case .AMEX:
            return true
        default:
            return false
        }
    case .DinersClub:
        switch rhs {
        case .DinersClub:
            return true
        default:
            return false
        }
    case .Maestro:
        switch rhs {
        case .Maestro:
            return true
        default:
            return false
        }
    case .ChinaUnionPay:
        switch rhs {
        case .ChinaUnionPay:
            return true
        default:
            return false
        }
    case .Unknown:
        switch rhs {
        case .Unknown:
            return true
        default:
            return false
        }
    case .Discover:
        switch rhs {
        case .Discover:
            return true
        default:
            return false
        }
    case .InstaPayment:
        switch rhs {
        case .InstaPayment:
            return true
        default:
            return false
        }
    case .InterPayment:
        switch rhs {
        case .InterPayment:
            return true
        default:
            return false
        }
    case .JCB:
        switch rhs {
        case .JCB:
            return true
        default:
            return false
        }
    case .Dankort:
        switch rhs {
        case .Dankort:
            return true
        default:
            return false
        }
    case .UATP:
        switch rhs {
        case .UATP:
            return true
        default:
            return false
        }
    }
}


/**
*  the CardDetails object stores information that is returned from a successful payment or preAuth
*/
public struct CardDetails {
    /// The last four digits of the card used for this transaction.
    public let cardLastFour: String?
    /// Expiry date of the card used for this transaction formatted as a two digit month and year i.e. MM/YY.
    public let endDate: String?
    /// Can be used to charge future payments against this card.
    public let cardToken: String?
    /// the card network
    public let cardNetwork: CardNetwork?
    
    static func fromDictionary(dict: JSONDictionary) -> CardDetails {
        let lastFour = dict["cardLastfour"] as? String
        let endDate = dict["endDate"] as? String
        let cardToken = dict["cardToken"] as? String
        // TODO: parse dict["cardType"] into CardNetwork
        return CardDetails(cardLastFour: lastFour, endDate: endDate, cardToken: cardToken, cardNetwork: nil)
    }
}

