//
//  ApplePayViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 19/08/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit
import PassKit

class ApplePayViewController: UIViewController {
    
    var selectedVariant: PurpleNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.purchase()
    }
    
    func purchase() {
        let priceString = selectedVariant?.priceV2?.amount ?? "0"
        let amount = NSDecimalNumber(string: priceString)
        let currencyCode = selectedVariant?.priceV2?.currency ?? "USD"
        let request = PKPaymentRequest()
        request.merchantIdentifier = Monetizr.shared.applePayMerchantID!
        request.supportedNetworks = applePaySupportedPaymentNetworks()
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = regionCode() ?? "US"
        request.currencyCode = currencyCode
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: selectedVariant?.product?.title ?? "Item", amount: amount)
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
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
