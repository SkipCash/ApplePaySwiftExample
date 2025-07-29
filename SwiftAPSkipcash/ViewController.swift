//
//  ViewController.swift
//  SwiftAPSkipcash
//
//  Created by AhmadMustafa on 28/07/2025.
//

import UIKit
import PassKit
import CryptoKit
import CommonCrypto

class ViewController: UIViewController {

    private var paymentData: PaymentData?
    private let authorizationHeader = "" // define your authorization header to protect your endpoint
    @IBOutlet weak var applePayView: UIView!
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    typealias PaymentCompletionHandler = (Bool) -> Void
    var completionHandler: PaymentCompletionHandler!
    var paymentID: String = ""
    var transactionId: String = ""
    
    static let supportedNetworks: [PKPaymentNetwork] = [
//        .discover,
        .amex,
        .masterCard,
        .visa
    ]
    
    public func applePayResponseData(transactionID: String, isSuccess: Bool, token: String, returnCode: Int, errorMessage: String, completion: ((PKPaymentAuthorizationResult) -> Void)?) {

           if (isSuccess) {
               let errors = [Error]()
               let status = PKPaymentAuthorizationStatus.success

               self.paymentStatus = status
               completion?(PKPaymentAuthorizationResult(status: status, errors: errors))
           }else{
               let errors = [Error]()
               let status = PKPaymentAuthorizationStatus.failure
               
               self.paymentStatus = status
               completion?(PKPaymentAuthorizationResult(status: status, errors: errors))
           }

           let responseData: [String: Any] = [
               "transactionId": transactionID,
               "isSuccess": isSuccess,
               "returnCode": returnCode,
               "errorMessage": errorMessage
           ]
        
           
           debugPrint("Response Result: ", responseData)
    }
    
    func callApplePay(paymentData: PaymentData, applePaymentToken: String, completion: ((PKPaymentAuthorizationResult) -> Void)?) {
            
            guard let request = paymentData.encodeToJSON() else {
                let responseData = ResponseData(
                    transactionId: paymentData.transactionId,
                    resultObj: ResultObject(isSuccess: false, data: "\(applePaymentToken)"),
                    returnCode: 400,
                    errorCode: 1001,
                    errorMessage: "Couldn't convert payment request data",
                    error: "Couldn't convert payment request data",
                    validationErrors: "Couldn't convert payment request data",
                    hasError: true,
                    hasValidationError: true
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    self.applePayResponseData(transactionID: responseData.getTransactionId(), isSuccess: responseData.getResultObjIsSuccess(), token: responseData.getResultObjData(), returnCode: responseData.returnCode, errorMessage: responseData.getErrorMessage(), completion: completion)
                }
                
                return
            }

            let postData            = request.data(using: .utf8)
            let url                 = URL(string: paymentData.processApplePayEndPoint)!
            var urlRequest          = URLRequest(url: url)
            urlRequest.httpMethod   = "POST"

        if self.authorizationHeader.count > 0 {
            urlRequest.addValue(self.authorizationHeader, forHTTPHeaderField: "Authorization")
            }
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody     = postData
            
            let task: URLSessionDataTask

            task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                guard let data = data else {
                    let responseData = ResponseData(
                        transactionId: paymentData.transactionId,
                        resultObj: ResultObject(isSuccess: false, data: "\(applePaymentToken)"),
                        returnCode: 400,
                        errorCode: 1001,
                        errorMessage: "NO DATA RECEIVED",
                        error: "No data received",
                        validationErrors: "NO DATA RECEIVED",
                        hasError: true,
                        hasValidationError: true
                    )
                    

                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        self.applePayResponseData(transactionID: responseData.getTransactionId(), isSuccess: responseData.getResultObjIsSuccess(), token: responseData.getResultObjData(), returnCode: responseData.returnCode, errorMessage: responseData.getErrorMessage(), completion: completion)
                    }
                    
                    return
                }
                
                if let text =  String(data: data, encoding: .utf8) {
                    if let jsonData = text.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            
                            let responseData = try decoder.decode(ResponseData.self, from: jsonData)
                            
                            responseData.transactionId = paymentData.transactionId
                  
                            DispatchQueue.main.asyncAfter(deadline: .now()){
                                // self.delegate?.
                                self.applePayResponseData(
                                    transactionID: responseData.getTransactionId(),
                                    isSuccess: responseData.getResultObjIsSuccess(), token: responseData.getResultObjData(), returnCode: responseData.returnCode, errorMessage: responseData.getErrorMessage(), completion: completion)
                            }
                            
                        } catch {
                            let responseData = ResponseData(
                                transactionId: paymentData.transactionId,
                                resultObj: ResultObject(isSuccess: false, data: "\(applePaymentToken)"),
                                returnCode: 400,
                                errorCode: 1001,
                                errorMessage: "failed to decode json response for the payment!",
                                error: "\(error)",
                                validationErrors: "failed to decode json response for the payment",
                                hasError: true,
                                hasValidationError: true
                            )
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()){
                                self.applePayResponseData(transactionID: responseData.getTransactionId(), isSuccess: responseData.resultObj!.isSuccess, token: responseData.getResultObjData(), returnCode: responseData.returnCode, errorMessage: responseData.getErrorMessage(), completion: completion)
                            }
                            
                            
                            
                        }
                    }
                        else {
                        let responseData = ResponseData(
                            transactionId: paymentData.transactionId,
                            resultObj: ResultObject(isSuccess: false, data: "\(applePaymentToken)"),
                            returnCode: 400,
                            errorCode: 1001,
                            errorMessage: "Failed to convert JSON text to data",
                            error: "Failed to convert JSON text to data",
                            validationErrors: "Failed to convert JSON text to data",
                            hasError: true,
                            hasValidationError: true
                        )
                            
                        DispatchQueue.main.asyncAfter(deadline: .now()){
                            self.applePayResponseData(transactionID: responseData.getTransactionId(), isSuccess: responseData.resultObj!.isSuccess, token: responseData.getResultObjData(), returnCode: responseData.returnCode, errorMessage: responseData.getErrorMessage(), completion: completion)
                        }
                    }
                } else {
                    let responseData = ResponseData(
                        transactionId: paymentData.transactionId,
                        resultObj: ResultObject(isSuccess: false, data: "\(applePaymentToken)"),
                        returnCode: 400,
                        errorCode: 1001,
                        errorMessage: "Failed to decode data as UTF-8 string",
                        error: "Failed to decode data as UTF-8 string",
                        validationErrors: "Failed to decode data as UTF-8 string",
                        hasError: true,
                        hasValidationError: true
                    )
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        self.applePayResponseData(transactionID: responseData.getTransactionId(), isSuccess: responseData.resultObj!.isSuccess, token: responseData.getResultObjData(), returnCode: responseData.returnCode, errorMessage: responseData.getErrorMessage(), completion: completion)
                    }
                }
            }
            task.resume()
        }

    
    func isWalletHasCards () -> Bool {
      let result = ViewController.applePayStatus()

      return result.canMakePayments;
    }

    @objc func setupNewCard() {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }

    class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
    }

    func convertToDecimal(with string: String) -> NSDecimalNumber {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.generatesDecimalNumbers = true
        formatter.maximumFractionDigits = 2
          
        if let number = formatter.number(from: string) as? NSDecimalNumber {
            return number
        } else {
            return 0
        }
    }
    
    func startPayment(data: PaymentData, completion: @escaping PaymentCompletionHandler) {
            
        completionHandler  = completion
        self.transactionId = data.transactionId
        
        paymentData = data
        
        var paymentSummaryItems = [PKPaymentSummaryItem]()

        for (label, amountString) in data.summaryItems {
            guard let amount = Decimal(string: amountString) else {
                print("Invalid amount string: \(amountString)")
                continue
            }

            let paymentItem = PKPaymentSummaryItem(label: label, amount: NSDecimalNumber(decimal: amount))
            paymentSummaryItems.append(paymentItem)
        }
        
        
        let totalAmount = convertToDecimal(with: data.amount)
        
        let totalAmountItem = PKPaymentSummaryItem(
            label: "Your Official Business Name", // define your official business/app name
            amount: totalAmount
        )
        paymentSummaryItems.append(totalAmountItem)


        let paymentRequest = PKPaymentRequest()

        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier   = "" // you apple pay MID
        paymentRequest.merchantCapabilities = .threeDSecure
        paymentRequest.countryCode          = "QA"
        paymentRequest.currencyCode         = "QAR"
        paymentRequest.supportedNetworks    = ViewController.supportedNetworks

        let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        
        paymentController.delegate = self
        
        paymentController.present(completion: { (presented: Bool) in
            if presented {
                debugPrint("Payment Controller Triggered")
            } else {
                debugPrint("Failed To Trigger The Payment Controller")
                self.completionHandler(false)
            }
        })
    }
    
    @objc func handlePayment(){
        debugPrint("Triggering handlePayment...")
        
        let paymentDict: [String: Any] = [ // you backend would be posted by this payment details to process the payment
            "Amount": "8.00",
            "FirstName": "Test",
            "LastName": "SkipCash",
            "Phone": "+97412345678",
            "Email": "integrations@skipcash.com",
            "token": "",
            "ProcessApplePayEndPoint": "", // required
            "TransactionId": "test-applepay",
            "WebhookUrl": "",
            "summaryItems": [ // (optional)
                "Delivery": "0.00", // example
                "Total": "8.00"
            ],// ensure that the total of the summary items matches the 'Amount' specified at the top of this dictionary.
        ]


        
        guard let paymentData = PaymentData(data: paymentDict) else {
            debugPrint("Failed to create PaymentData: missing or invalid data")
            return
        }
        
        self.startPayment(data: paymentData) { success in
            var responseData: [String: Any] = [
                "transactionId": paymentData.transactionId,
                "isSuccess": false,
                "returnCode": 400,
                "errorMessage": "Payment failed!"
            ]

            if success {
                responseData["isSuccess"] = true
                responseData["returnCode"] = 200
                debugPrint("payment was successful:", responseData)
            } else {
                debugPrint("payment failed:", responseData)
            }
        }



    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.addTarget(self, action: #selector(handlePayment), for: .touchUpInside)
            
        view.addSubview(applePayButton)

        NSLayoutConstraint.activate([
            applePayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applePayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            applePayButton.widthAnchor.constraint(equalToConstant: 200),
            applePayButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }


}

extension ViewController: PKPaymentAuthorizationControllerDelegate {

    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {

        var token = ""

        
        do {
            if try JSONSerialization.jsonObject(with: payment.token.paymentData, options: []) is [String: Any] {
                token = String(decoding: payment.token.paymentData, as: UTF8.self)
            } else {
                debugPrint("error")
                let errors = [Error]()
                let status = PKPaymentAuthorizationStatus.failure
                self.paymentStatus = status
                completion(PKPaymentAuthorizationResult(status: status, errors: errors))
                return
            }
        } catch {
            debugPrint("error converting payment token")
            let errors = [Error]()
            let status = PKPaymentAuthorizationStatus.failure
            
            self.paymentStatus = status
            completion(PKPaymentAuthorizationResult(status: status, errors: errors))
            return
        }

        paymentData?.token = token
        self.callApplePay(paymentData: self.paymentData!, applePaymentToken: token, completion: completion)
    }

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            if self.paymentStatus == .success {
                self.completionHandler!(true)
            } else {
                self.completionHandler!(false)
            }
        }
    }
}
