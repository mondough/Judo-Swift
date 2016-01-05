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


/// Constants that describe the formatting pattern of given Card Networks
let VISAPattern         = "XXXX XXXX XXXX XXXX"
let AMEXPattern         = "XXXX XXXXXX XXXXX"
let CUPPattern          = "XXXXXX XXXXXXXXXXXXX"
let DinersClubPattern   = "XXXX XXXXXX XXXX"


// these should be computed once and then referenced - O(n)
let masterCardPrefixes          = ([Int](2221...2720)).map({ String($0) }) + ([Int](51...55)).map { String($0) }
let maestroPrefixes             = ([Int](56...69)).map({ String($0) }) + ["50"]
let dinersClubPrefixes          = ([Int](300...305)).map({ String($0) }) + ["36", "38", "39", "309"]
let instaPaymentPrefixes        = ([Int](637...639)).map({ String($0) })
let JCBPrefixes                 = ([Int](3528...3589)).map({ String($0) })

// expression was too complex to be executed in one line 😩😭💥
let discoverPrefixes: [String]  = {
    let discover = ([Int](644...649)).map({ String($0) }) + ([Int](622126...622925)).map({ String($0) })
    return discover + ["65", "6011"]
    }()


/**
*  the Card object stores all the necessary card information to make a transaction
*/
public class Card: NSObject {
    
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
    /// The start date if the card is a Maestro
    public let startDate: String?
    /// The issue number if the card is a Maestro
    public let issueNumber: String?
    
    
    /**
     designated initialiser for the Card struct
     
     - parameter number:      the card number (long number)
     - parameter expiryDate:  the expiry date of the card
     - parameter cv2:         the security code number of the card
     - parameter address:     the address of the card holder where the account is registered (AVS)
     - parameter startDate:   in case of transacting with maestro cards, the start date (optional)
     - parameter issueNumber: in case of transacting with maestro cards, the issue number (optional)
     
     - returns: a Card object
     */
    public init(number: String, expiryDate: String, cv2: String, address: Address?, startDate: String? = nil, issueNumber: String? = nil) {
        self.number = number
        self.expiryDate = expiryDate
        self.cv2 = cv2
        self.address = address
        self.startDate = startDate
        self.issueNumber = issueNumber
    }
    
    /**
    *  Card Configuration consists of a Card Network and a given length
    */
    public class Configuration: NSObject {
        /// the network of the configuration
        public let cardNetwork: CardNetwork
        /// the length of the card for this configuration
        public let cardLength: Int
        
        /**
         designated initialiser for a card configuration
         
         - parameter cardNetwork: the card network (eg. Visa, MasterCard or AMEX)
         - parameter cardLength:  the length of the card number (eg. 16 or 19 for Maestro cards)
         
         - returns: a Card.Configuration object
         */
        public init(_ cardNetwork: CardNetwork, _ cardLength: Int) {
            self.cardLength = cardLength
            self.cardNetwork = cardNetwork
        }
        
        
        /**
        helper method to get a pattern string for a certain configuration
        
        - Returns: a given String with the correct pattern
        */
        public func patternString() -> String? {
            switch self.cardNetwork {
            case .Visa, .MasterCard, .Dankort, .JCB, .InstaPayment, .Discover:
                return VISAPattern
            case .AMEX:
                return AMEXPattern
            case .ChinaUnionPay, .InterPayment, .Maestro:
                if self.cardLength == 16 {
                    return VISAPattern
                } else if self.cardLength == 19 {
                    return CUPPattern
                }
                break
            case .DinersClub:
                if self.cardLength == 16 {
                    return VISAPattern
                } else if self.cardLength == 14 {
                    return DinersClubPattern
                }
            default:
                return VISAPattern
            }
            return nil
        }
        
        
        /**
        helper method to get a placeholder string for a certain configuration
        
        - Returns: a given String as a placeholder
        */
        public func placeholderString() -> String? {
            return self.patternString()?.stringByReplacingOccurrencesOfString("X", withString: "0")
        }
    }
    
}


extension Card.Configuration: Comparable { }

public func ==(x: Card.Configuration, y: Card.Configuration) -> Bool {
    return x.cardLength == y.cardLength && x.cardNetwork == y.cardNetwork
}

public func <(x: Card.Configuration, y: Card.Configuration) -> Bool {
    return x.cardLength < y.cardLength
}

public func <=(x: Card.Configuration, y: Card.Configuration) -> Bool {
    return x.cardLength <= y.cardLength
}

public func >(x: Card.Configuration, y: Card.Configuration) -> Bool {
    return x.cardLength > y.cardLength
}

public func >=(x: Card.Configuration, y: Card.Configuration) -> Bool {
    return x.cardLength >= y.cardLength
}

/**
the CardType enum is a value type for CardNetwork to further identify card types

- Debit:   Debit Card type
- Credit:  Credit Card type
- Unknown: Unknown Card type
*/
@objc public enum CardType: Int {
    /// Debit Card type
    case Debit
    /// Credit Card type
    case Credit
    /// Unknown Card type
    case Unknown
}


/**
the CardNetwork enum depicts the Card Network type of a given Card object

- Visa:             Visa Card Network
- MasterCard:       MasterCard Network
- AMEX:             American Express Card Network
- DinersClub:       Diners Club Network
- Maestro:          Maestro Card Network
- ChinaUnionPay:    China UnionPay Network
- Discover:         Discover Network
- InterPayment:     InterPayment Network
- InstaPayment:     InstaPayment Network
- JCB:              JCB Network
- Dankort:          Dankort Network
- UATP:             UATP Network
- Unknown:          Unknown
*/
@objc public enum CardNetwork: Int {
    
    /// Unknown
    case Unknown = 0
    /// Visa Card Network
    case Visa = 1
    /// MasterCard Network
    case MasterCard = 2
    /// Visa Electron Network
    case VisaElectron = 3
    /// Switch Network
    case Switch = 4
    /// Solo Network
    case Solo = 5
    /// Laser Network
    case Laser = 6
    /// China UnionPay Network
    case ChinaUnionPay = 7
    /// American Express Card Network
    case AMEX = 8
    /// JCB Network
    case JCB = 9
    /// Maestro Card Network
    case Maestro = 10
    /// Visa Debit Card Network
    case VisaDebit = 11
    /// MasterCard Network
    case MasterCardDebit = 12
    /// Visa Purchasing Network
    case VisaPurchasing = 13
    /// Discover Network
    case Discover = 14
    /// Carnet Network
    case Carnet = 15
    /// Carte Bancaire Network
    case CarteBancaire = 16
    /// Diners Club Network
    case DinersClub = 17
    /// Elo Network
    case Elo = 18
    /// Farmers Card Network
    case FarmersCard = 19
    /// Soriana Network
    case Soriana = 20
    /// Private Label Card Network
    case PrivateLabelCard = 21
    /// Q Card Network
    case QCard = 22
    /// Style Network
    case Style = 23
    /// True Rewards Network
    case TrueRewards = 24
    /// UATP Network
    case UATP = 25
    /// Bank Card Network
    case BankCard = 26
    /// Banamex Costco Network
    case Banamex_Costco = 27
    /// InterPayment Network
    case InterPayment = 28
    /// InstaPayment Network
    case InstaPayment = 29
    /// Dankort Network
    case Dankort = 30
    
    
    /**
     the string value of the receiver
     
     - returns: a string describing the receiver
     */
    public func stringValue() -> String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .Visa, .VisaDebit, .VisaElectron, .VisaPurchasing:
            return "Visa"
        case .MasterCard, .MasterCardDebit:
            return "MasterCard"
        case .Switch:
            return "Switch"
        case .Solo:
            return "Solo"
        case .Laser:
            return "Laser"
        case .ChinaUnionPay:
            return "China UnionPay"
        case .AMEX:
            return "AMEX"
        case .JCB:
            return "JCB"
        case .Maestro:
            return "Maestro"
        case .Discover:
            return "Discover"
        case .Carnet:
            return "Carnet"
        case .CarteBancaire:
            return "CarteBancaire"
        case .DinersClub:
            return "Diners Club"
        case .Elo:
            return "Elo"
        case .FarmersCard:
            return "FarmersCard"
        case .Soriana:
            return "Soriana"
        case .PrivateLabelCard:
            return "PrivateLabelCard"
        case .QCard:
            return "QCard"
        case .Style:
            return "Style"
        case .TrueRewards:
            return "TrueRewards"
        case .UATP:
            return "UATP"
        case .BankCard:
            return "BankCard"
        case .Banamex_Costco:
            return "BanamexCostco"
        case .InterPayment:
            return "InterPayment"
        case .InstaPayment:
            return "InstaPayment"
        case .Dankort:
            return "Dankort"
        }
    }
    
    
    /**
    the prefixes determine which card network a number belongs to, this method provides an array with one or many prefixes for a given type
    
    - Returns: an Array containing all the possible prefixes for a type
    */
    public func prefixes() -> [String] {
        switch self {
        case .Visa, .VisaDebit, .VisaElectron, .VisaPurchasing:
            return ["4"]
        case .MasterCard, .MasterCardDebit:
            return masterCardPrefixes
        case .AMEX:
            return ["34", "37"]
        case .DinersClub:
            return dinersClubPrefixes
        case .Maestro:
            return maestroPrefixes
        case .ChinaUnionPay:
            return ["62"]
        case .Discover:
            return discoverPrefixes
        case .InterPayment:
            return ["636"]
        case .InstaPayment:
            return instaPaymentPrefixes
        case .JCB:
            return JCBPrefixes
        case .Dankort:
            return ["5019"]
        case .UATP:
            return ["1"]
        default:
            return []
        }
    }
    
    
    /**
     the card network type for a given card number string and constrained to a set of networks
     
     - parameter string:   the card number as a string
     - parameter networks: the networks allowed for detection
     
     - returns: a CardNetwork if the prefix matches a given set of CardNetworks or CardNetwork.Unknown
     */
    public static func networkForString(string: String, constrainedToNetworks networks: [CardNetwork]) -> CardNetwork {
        let result = networks.filter({ $0.prefixes().filter({ string.hasPrefix($0) }).count > 0 })
        if result.count == 1 {
            return result[0]
        }
        return CardNetwork.Unknown
    }
    
    
    /**
     the card network type for a given card number
     
     - parameter string: the card number as a string
     
     - returns: a CardNetwork if the prefix matches any CardNetwork prefix
     */
    public static func networkForString(string: String) -> CardNetwork {
        let allNetworks: [CardNetwork] = [.Visa, .MasterCard, .AMEX, .DinersClub, .Maestro, .ChinaUnionPay, .Discover, .InterPayment, .InstaPayment, .JCB, .Dankort, .UATP]
        return self.networkForString(string, constrainedToNetworks: allNetworks)
    }
    

    /**
    security code name for a certain card
    
    - Returns: a String for the title of a certain security code
    */
    public func securityCodeTitle() -> String {
        switch self {
        case .Visa:
            return "CVV2"
        case .MasterCard:
            return "CVC2"
        case .AMEX:
            return "CIDV"
        case .ChinaUnionPay:
            return "CVN2"
        case .Discover:
            return "CID"
        case .JCB:
            return "CAV2"
        case .Unknown:
            return "CVV"
        default:
            return "CVV"
        }
    }
    
    
    /**
    security code length for a card type
    
    - Returns: an Int with the code length
    */
    public func securityCodeLength() -> Int {
        switch self {
        case .AMEX:
            return 4
        default:
            return 3
        }
    }
    
}


/**
*  the CardDetails object stores information that is returned from a successful payment or preAuth
*/
public class CardDetails: NSObject, NSCoding {
    /// The last four digits of the card used for this transaction.
    public let cardLastFour: String?
    /// Expiry date of the card used for this transaction formatted as a two digit month and year i.e. MM/YY.
    public let endDate: String?
    /// Can be used to charge future payments against this card.
    public let cardToken: String?
    /// the card network
    public let cardNetwork: CardNetwork?
    
    
    /**
     designated initialiser for Card Details
     
     - parameter dict: all parameters as a dictionary
     
     - returns: a CardDetails object
     */
    public init(_ dict: JSONDictionary?) {
        self.cardLastFour = dict?["cardLastfour"] as? String
        self.endDate = dict?["endDate"] as? String
        self.cardToken = dict?["cardToken"] as? String
        if let cardType = dict?["cardType"] as? Int {
            self.cardNetwork = CardNetwork(rawValue: cardType)
        } else {
            self.cardNetwork = nil
        }
        super.init()
    }
    
    
    /**
     initialise the CardDetails object with a coder
     
     - parameter decoder: the decoder object
     
     - returns: a CardDetails object or nil
     */
    public required init?(coder decoder: NSCoder) {
        let cardLastFour = decoder.decodeObjectForKey("cardLastFour") as? String?
        let endDate = decoder.decodeObjectForKey("endDate") as? String?
        let cardToken = decoder.decodeObjectForKey("cardToken") as? String?
        let cardNetwork = decoder.decodeObjectForKey("cardNetwork") as? Int?
        
        self.cardLastFour = cardLastFour ?? nil
        self.endDate = endDate ?? nil
        self.cardToken = cardToken ?? nil
        if let network = cardNetwork, let kNetwork = network {
            self.cardNetwork = CardNetwork(rawValue: Int(kNetwork))
        } else {
            self.cardNetwork = nil
        }
        
        super.init()
    }
    
    
    /**
     encode the receiver CardDetails object
     
     - parameter aCoder: the Coder
     */
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.cardLastFour, forKey: "cardLastFour")
        aCoder.encodeObject(self.endDate, forKey: "endDate")
        aCoder.encodeObject(self.cardToken, forKey: "cardToken")
        if let cardNetwork = self.cardNetwork {
            aCoder.encodeInt(Int32(cardNetwork.rawValue), forKey: "cardNetwork")
        }
    }
    
    
    /**
     get a formatted string with the right whitespacing for a certain card type
     
     - returns: a string with the last four digits with the right format
     */
    public func formattedLastFour() -> String? {
        guard let cardLastFour = self.cardLastFour else { return nil }
        guard let cardNetwork = self.cardNetwork else { return "**** \(cardLastFour)" }
        
        switch cardNetwork {
        case .AMEX:
            return "**** ****** *\(cardLastFour)"
        default:
            return "**** **** **** \(cardLastFour)"
        }
    }
    
    
    /**
     get a formatted string with the right slash for a date
     
     - returns: a string with the date as shown on the credit card with the right format
     */
    public func formattedEndDate() -> String? {
        guard let ed = self.endDate else { return nil }
        
        if ed.characters.count == 4 {
            // backend returns the end date without a slash so for UI purposes we have to add it
            let prefix = ed.substringToIndex(ed.startIndex.advancedBy(2))
            let suffix = ed.substringFromIndex(ed.endIndex.advancedBy(-2))
            return "\(prefix)/\(suffix)"
        } else {
            return ed
        }
    }
    
}


