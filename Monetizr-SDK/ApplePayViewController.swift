//
//  ApplePayViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 19/08/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit
import PassKit

class ApplePayViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    var selectedVariant: PurpleNode?
    var checkout: Checkout?
    var tag: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.purchase()
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        let token = payment.token
        print(token)
        let paymentData=String(data: payment.token.paymentData.base64EncodedData(), encoding: .utf8)
        print (paymentData ?? "No data")
        let shippingContactName = payment.shippingContact?.name
        print(shippingContactName ?? "No data")
        let shippingContactPhone = payment.shippingContact?.phoneNumber
        print(shippingContactPhone ?? "No data")
        let shippingContactAdress = payment.shippingContact?.postalAddress
        print(shippingContactAdress ?? "No data")
        let shippingMethodIdentifier = payment.shippingMethod?.identifier
        print(shippingMethodIdentifier ?? "No data")
        
        completion(PKPaymentAuthorizationStatus.failure)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        let shippingAddress = contact.postalAddress
        switch (shippingAddress?.city, shippingAddress?.country) {
        case (.some, .some):
            if shippingAddress?.city != "" && shippingAddress?.country != "" {
                completion(PKPaymentAuthorizationStatus.success, [], [])
                // Address OK, validate against checkout
                Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!, shippingAddress: shippingAddress) { success, error, checkout in
                    if success {
                        // Handle success response
                        self.checkout = checkout
                        if self.checkout?.data?.checkoutCreate?.checkoutUserErrors?.count ?? 0 > 0 {
                            completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
                        }
                        else {
                            // No errors update price etc.
                            completion(PKPaymentAuthorizationStatus.success, self.shippingMethods(), self.paymentSummaryItems())
                        }
                    }
                    else {
                        // Handle error
                        completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
                    }
                }
            }
            else {
                completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
            }
        default:
            completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        
        completion(PKPaymentAuthorizationStatus.success, self.paymentSummaryItems(shippingMethodIdentifier: shippingMethod.identifier))
    }
    
    func purchase() {
        // Prepare data for request
        let priceString = selectedVariant?.priceV2?.amount ?? "0"
        let amount = NSDecimalNumber(string: priceString)
        let currencyCode = selectedVariant?.priceV2?.currency ?? "USD"
        let productTitle = selectedVariant?.product?.title ?? ""
        let companyName = Monetizr.shared.companyName ?? "Company"
        
        // Create and configure request
        let request = PKPaymentRequest()
        request.merchantIdentifier = Monetizr.shared.applePayMerchantID!
        request.supportedNetworks = applePaySupportedPaymentNetworks()
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = regionCode() ?? "US"
        request.currencyCode = currencyCode
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: productTitle, amount: amount), PKPaymentSummaryItem(label: companyName, amount: amount)
        ]
        request.requiredShippingAddressFields = [PKAddressField.postalAddress, PKAddressField.name, PKAddressField.phone]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        self.present(applePayController!, animated: true, completion: nil)
    }
    
    func shippingMethods() -> [PKShippingMethod] {
        // Shipping options
        var shippingOptions = [PKShippingMethod]()
        
        if self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?.count ?? 0 > 0 {
            for rate in (self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates)! {
                let shippingOptionTitle = rate.title ?? NSLocalizedString("Unknown", comment: "Unknown")
                let shippingPriceString = rate.priceV2?.amount ?? "0"
                let shippingPrice = NSDecimalNumber(string: shippingPriceString)
                let shippingIdentifier = rate.handle ?? "Default"
                let shippingOption = PKShippingMethod(label: shippingOptionTitle, amount: shippingPrice)
                shippingOption.detail = ""
                shippingOption.identifier = shippingIdentifier
                shippingOptions.append(shippingOption)
            }
        }
        return shippingOptions
    }
    
    func paymentSummaryItems(shippingMethodIdentifier: String? = "") -> [PKPaymentSummaryItem] {
        // Shipping Options
        let shippingTitle = NSLocalizedString("Shipping", comment: "Shipping")
        var shippingPrice = 0 as NSDecimalNumber
        if shippingMethodIdentifier == "" {
            let firstShippingPriceString = self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?.first?.priceV2?.amount ?? "0"
            shippingPrice = NSDecimalNumber(string: firstShippingPriceString)
        }
        if shippingMethodIdentifier != "" {
            let shippingRates = self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates
            if let index = shippingRates?.firstIndex(where: { $0.handle == shippingMethodIdentifier }) {
                let shippingPriceString = shippingRates?[index].priceV2?.amount
                shippingPrice = NSDecimalNumber(string: shippingPriceString)
            }
        }
        // Product info
        let productTitle = self.selectedVariant?.product?.title ?? ""
        let subTotalPriceString = self.checkout?.data?.checkoutCreate?.checkout?.subtotalPriceV2?.amount ?? "0"
        let subTotalAmount = NSDecimalNumber(string: subTotalPriceString)
        
        // Tax info
        let taxTitle = NSLocalizedString("Tax", comment: "TAX")
        let taxPriceString = self.checkout?.data?.checkoutCreate?.checkout?.totalTaxV2?.amount ?? "0"
        let taxAmount = NSDecimalNumber(string: taxPriceString)
        
        // Total
        let companyName = Monetizr.shared.companyName ?? "Company"
        let totalPriceString = self.checkout?.data?.checkoutCreate?.checkout?.totalPriceV2?.amount ?? "0"
        var totalAmount = NSDecimalNumber(string: totalPriceString)
        totalAmount = totalAmount.adding(shippingPrice)
        
        // Payment items
        let paymentSummaryItems = [PKPaymentSummaryItem(label: productTitle, amount: subTotalAmount), PKPaymentSummaryItem(label: taxTitle, amount: taxAmount), PKPaymentSummaryItem(label: shippingTitle, amount: shippingPrice), PKPaymentSummaryItem(label: companyName, amount: totalAmount)]
        
        return paymentSummaryItems
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
