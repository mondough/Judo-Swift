//
//  Response.swift
//  Judo
//
//  Created by Hamon Riazy on 03/08/2015.
//  Copyright © 2015 Judo Payments. All rights reserved.
//

import Foundation


/**
*  Response object that stores an array of items and includes pagination information if available
*/
public class Response: NSObject {
    /// the current pagination response
    public let pagination: Pagination?
    /// The array that contains the transaction response objects
    public private (set) var items = Array<TransactionData>()
    
    
    /**
    Initialize a Response object with pagination if available
    
    - Parameter pagination: the pagination information for the response
    
    - Returns: a Response object
    */
    init(_ pagination: Pagination?) {
        self.pagination = pagination
    }
    
    
    /**
    add an element on to the items
    
    - Parameter element: the element to add to the items Array
    */
    public func append(element: TransactionData) {
        self.items.append(element)
    }
    
    
    /**
    calculate the next page from available data
    
    :returns: a newly calculated Pagination object based on the Response object
    */
    public func nextPage() -> Pagination? {
        guard let page = self.pagination else { return nil }
        
        return Pagination(pageSize: page.pageSize, offset: page.offset + page.pageSize, sort: page.sort)
    }
}


/**
*  a PaymentToken object is necessary to make a token payment or token preAuth
*/
public class PaymentToken: NSObject {
    /// Our unique reference for this Consumer. Used in conjunction with the card token in repeat transactions.
    public let consumerToken: String
    /// Can be used to charge future payments against this card.
    public let cardToken: String
    /// cv2 of the card
    public var cv2: String?
    
    
    /**
     designated initialiser for non-optional values
     
     - parameter consumerToken: consumer token string
     - parameter cardToken:     card token string
     
     - returns: a PaymentToken object
     */
    public init(consumerToken: String, cardToken: String, cv2: String? = nil) {
        self.consumerToken = consumerToken
        self.cardToken = cardToken
        self.cv2 = cv2
        super.init()
    }
    
}


/**
*  details of the Consumer for use in repeat payments.
*/
public class Consumer: NSObject {
    /// Our unique reference for this Consumer. Used in conjunction with the card token in repeat transactions.
    public let consumerToken: String
    /// Your reference for this Consumer as you sent in your request.
    public let yourConsumerReference: String
    
    
    /**
     designated initialiser
     
     - parameter dict: the consumer dictionary which was return from the Judo REST API
     
     - returns: a Consumer object
     */
    public init(_ dict: JSONDictionary) {
        self.consumerToken = dict["consumerToken"] as! String
        self.yourConsumerReference = dict["yourConsumerReference"] as! String
        super.init()
    }
    
    
    /**
     designated initialiser
     
     - parameter consumerToken:     a consumer token string
     - parameter consumerReference: a consumer reference string
     
     - returns: a consumer object
     */
    public init(consumerToken: String, consumerReference: String) {
        self.consumerToken = consumerToken
        self.yourConsumerReference = consumerReference
        super.init()
    }

}


/**
*  TransactionResult will hold all the information from a transaction response
*/
public class TransactionData: NSObject {
    /// our reference for this transaction. Keep track of this as it's needed to process refunds or collections later
    public let receiptID: String
    /// Your original reference for this payment
    public let yourPaymentReference: String
    /// The type of Transaction, either "Payment" or "Refund"
    public let type: TransactionType
    /// date and time of the Transaction including time zone offset
    public let createdAt: NSDate
    /// The result of this transactions, this will either be "Success" or "Declined"
    public let result: TransactionResult
    /// A message detailing the result.
    public let message: String
    /// The number (e.g. "123-456" or "654321") identifying the Merchant to whom payment has been made
    public let judoID: String
    /// The trading name of the Merchant to whom payment has been made
    public let merchantName: String
    /// How the Merchant will appear on the Consumers statement
    public let appearsOnStatementAs: String
    /// If present this will show the total value of refunds made against the original payment
    public let refunds: Amount?
    /// This is the original value of this transaction before refunds
    public let originalAmount: Amount?
    /// This will show the remaining balance of the transaction after refunds. You cannot refund more than the original payment
    public let netAmount: Amount?
    /// This is the value of this transaction (if refunds available it is the amount after refunds)
    public let amount: Amount
    /// Information about the card used in this transaction
    public let cardDetails: CardDetails
    /// details of the Consumer for use in repeat payments
    public let consumer: Consumer
    /// raw data of the received dictionary
    public let rawData: [String : AnyObject]
    
    /**
    create a TransactionData Object from a dictionary
    
    - Parameter dict: the dictionary
    
    - Returns: a TransactionData object
    */
    public init(_ dict: JSONDictionary) throws {
        guard let receiptID = dict["receiptId"] as? String,
            let yourPaymentReference = dict["yourPaymentReference"] as? String,
            let typeString = dict["type"] as? String,
            let type = TransactionType(rawValue: typeString),
            let createdAtString = dict["createdAt"] as? String,
            let createdAt = ISO8601DateFormatter.dateFromString(createdAtString),
            let resultString = dict["result"] as? String,
            let result = TransactionResult(rawValue: resultString),
            let message = dict["message"] as? String,
            let judoID = dict["judoId"] as? NSNumber,
            let merchantName = dict["merchantName"] as? String,
            let appearsOnStatementAs = dict["appearsOnStatementAs"] as? String,
            let currency = dict["currency"] as? String,
            let amountString = dict["amount"] as? String,
            let cardDetailsDict = dict["cardDetails"] as? JSONDictionary,
            let consumerDict = dict["consumer"] as? JSONDictionary else {
                self.receiptID = ""
                self.yourPaymentReference = ""
                self.type = TransactionType.Payment
                self.createdAt = NSDate()
                self.result = TransactionResult.Error
                self.message = ""
                self.judoID = ""
                self.merchantName = ""
                self.appearsOnStatementAs = ""
                self.refunds = Amount(amountString: "1", currency: "XOR")
                self.originalAmount = Amount(amountString: "1", currency: "XOR")
                self.netAmount = Amount(amountString: "1", currency: "XOR")
                self.amount = Amount(amountString: "1", currency: "XOR")
                self.cardDetails = CardDetails(nil)
                self.consumer = Consumer(consumerToken: "", consumerReference: "")
                self.rawData = [String : AnyObject]()
                super.init()
                throw JudoError(.ResponseParseError)
        }
        
        self.receiptID = receiptID
        self.yourPaymentReference = yourPaymentReference
        self.type = type
        self.createdAt = createdAt
        self.result = result
        self.message = message
        self.judoID = String(judoID.integerValue)
        self.merchantName = merchantName
        self.appearsOnStatementAs = appearsOnStatementAs
        
        if let refunds = dict["refunds"] as? String {
            self.refunds = Amount(amountString: refunds, currency: currency)
        } else {
            self.refunds = nil
        }

        if let originalAmount = dict["originalAmount"] as? String {
            self.originalAmount = Amount(amountString: originalAmount, currency: currency)
        } else {
            self.originalAmount = nil
        }

        if let netAmount = dict["netAmount"] as? String {
            self.netAmount = Amount(amountString: netAmount, currency: currency)
        } else {
            self.netAmount = nil
        }

        self.amount = Amount(amountString: amountString, currency: currency)
        
        self.cardDetails = CardDetails(cardDetailsDict)
        self.consumer = Consumer(consumerDict)
        self.rawData = dict
        
        super.init()
    }
    
    
    /**
    generates a PaymentToken object from existing information
    
    - Returns: a PaymentToken object that has been generated from the current objects information
    */
    public func paymentToken() -> PaymentToken? {
        guard let cardToken = self.cardDetails.cardToken else { return nil }
        return PaymentToken(consumerToken: self.consumer.consumerToken, cardToken: cardToken)
    }
}


/**
 Type of Transaction
 
 - Payment: a Payment Transaction
 - PreAuth: a PreAuth Transaction
 - Refund:  a Refund Transaction
 - RegisterCard: Register a Card
*/
public enum TransactionType: String {
    /// a Payment Transaction
    case Payment
    /// a PreAuth Transaction
    case PreAuth
    /// a Refund Transaction
    case Refund
    /// TransactionTypeRegisterCard for registering a card for a later transaction
    case RegisterCard
}


/**
Result of a Transaction

- Success:  successful transaction
- Declined: declined transaction
- Error:    something went wrong
*/
public enum TransactionResult: String {
    /// successful transaction
    case Success
    /// declined transaction
    case Declined
    /// something went wrong
    case Error
}

// MARK: Helper


/// formatter for ISO8601 Dates that are returned from the webservice
let ISO8601DateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZZ"
    return dateFormatter
}()

