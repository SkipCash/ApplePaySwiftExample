//
//  ApplePayModels.swift
//  SwiftAPSkipcash
//
//  Created by AhmadMustafa on 28/07/2025.
//

import Foundation

public class PaymentData: NSObject, Codable{
    var token: String
    let amount: String
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let processApplePayEndPoint: String
    let summaryItems: [String: String]

    let transactionId: String
    let webhookUrl: String
 

    init?(data: [String: Any]) {
        guard
            let token = data["token"] as? String,
            let processApplePayEndPoint = data["ProcessApplePayEndPoint"] as? String,
            let amount = data["Amount"] as? String,
            let firstName = data["FirstName"] as? String,
            let lastName = data["LastName"] as? String,
            let phone = data["Phone"] as? String,
            let email = data["Email"] as? String,
            let summaryItems = data["summaryItems"] as? [String: String],

            let transactionId = data["TransactionId"] as? String,
            let webhookUrl = data["WebhookUrl"] as? String
      
        else {
            return nil
        }

        self.token = token
        self.processApplePayEndPoint = processApplePayEndPoint
        self.amount = amount
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
         self.summaryItems = summaryItems

        self.transactionId  = transactionId
        self.webhookUrl     = webhookUrl
    }

    func encodeToJSON() -> String? {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(self)
            // Convert to a string if needed (for the body of the POST request)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            debugPrint("Error encoding PaymentData to JSON: \(error)")
            return nil
        }
    }
}

public struct ResultObject: Codable {
    public var isSuccess: Bool
    var data: String?
}

public class ResponseData: NSObject, Codable {
    public var transactionId: String?
    public var resultObj: ResultObject?
    public var returnCode: Int
    public var errorCode: Int
    public var errorMessage: String?
    public var error: String?
    public var validationErrors: String?
    public var hasError: Bool
    public var hasValidationError: Bool
     
    // Initializer
    public init(transactionId: String?, resultObj: ResultObject?, returnCode: Int, errorCode: Int, errorMessage: String?, error: String?, validationErrors: String?, hasError: Bool, hasValidationError: Bool) {
        self.transactionId = transactionId
        self.resultObj = resultObj
        self.returnCode = returnCode
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.error = error
        self.validationErrors = validationErrors
        self.hasError = hasError
        self.hasValidationError = hasValidationError
    }
    
    
    public func getResultObjIsSuccess() -> Bool {
        return resultObj?.isSuccess ?? false;
    }
    
    public func getResultObjData() -> String {
        return resultObj?.data ?? "";
    }
    
    public func getTransactionId () -> String {
        return transactionId ?? "No Transaction ID";
    }
    
    public func getErrorMessage() -> String {
        return errorMessage ?? "Nothing to show";
    }
}
