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
        completion(PKPaymentAuthorizationStatus.success)
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
                        if checkout?.data?.checkoutCreate?.checkoutUserErrors?.count ?? 0 > 0 {
                            completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
                        }
                        else {
                            // No errors update price etc.
                            // Update shipping options
                            var shippingOptions = [PKShippingMethod]()
                            
                            if checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?.count ?? 0 > 0 {
                                for rate in (checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates)! {
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
                            // Update summary items
                            // Product title
                            let productTitle = self.selectedVariant?.product?.title ?? ""
                            let subTotalPriceString = checkout?.data?.checkoutCreate?.checkout?.subtotalPriceV2?.amount ?? "0"
                            let subTotalAmount = NSDecimalNumber(string: subTotalPriceString)
                            
                            // Tax info
                            let taxTitle = NSLocalizedString("Tax", comment: "TAX")
                            let taxPriceString = checkout?.data?.checkoutCreate?.checkout?.totalTaxV2?.amount ?? "0"
                            let taxAmount = NSDecimalNumber(string: taxPriceString)
                            
                            // Total price
                            let companyName = Monetizr.shared.companyName ?? "Company"
                            let totalPriceString = checkout?.data?.checkoutCreate?.checkout?.totalPriceV2?.amount ?? "0"
                            let totalAmount = NSDecimalNumber(string: totalPriceString)
                            
                            // Payment items
                            let paymentSummaryItems = [PKPaymentSummaryItem(label: productTitle, amount: subTotalAmount), PKPaymentSummaryItem(label: taxTitle, amount: taxAmount), PKPaymentSummaryItem(label: companyName, amount: totalAmount)]
                            
                            completion(PKPaymentAuthorizationStatus.success, shippingOptions, paymentSummaryItems)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
