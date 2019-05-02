//
//  ProductViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ProductViewController: UIViewController {
    
    let textView = UITextView(frame: .zero)
    var product: Product?
    var variantCount = 0
    let closeButton = UIButton(frame: .zero)
    let checkoutButtonBackgroundView = UIView(frame: .zero)
    let checkoutButton = UIButton(frame: .zero)
    let variantOptionsContainerView = UIView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background configuration
        self.view.backgroundColor = .white
        
        // Count variants
        variantCount = (product?.data?.productByHandle?.variants?.edges!.count)!
        
        // Close button
        self.configureCloseButton()
        
        // Checkout button
        self.configureCheckOutButton()
        
        // Variant option selection container view
        if variantCount > 0 {
            self.configureVariantOptionsContainerView()
        }
        
        // Text View
        self.configureTextView()
        
        // Load product
        self.loadProduct()
    }
    
    func configureTextView() {
        // TextView
        self.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 0),
            textView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: 0),
            textView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            ])
    }
    
    func configureCloseButton() {
        // Close button
        closeButton.closeProductButtonStyle()
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            ])
    }
    
    func configureCheckOutButton() {
        // Checkout buttons background
        checkoutButtonBackgroundView.checkoutButtonBackgroundViewStyle()
        self.view.addSubview(checkoutButtonBackgroundView)
        NSLayoutConstraint.activate([
            checkoutButtonBackgroundView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: 0),
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 0),
            checkoutButtonBackgroundView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: 0),
            checkoutButtonBackgroundView.heightAnchor.constraint(equalToConstant: 70),
            ])
        
        // Checkout button
        checkoutButton.checkoutProductButtonStyle()
        checkoutButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(checkoutButton)
        NSLayoutConstraint.activate([
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -10),
            checkoutButton.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 10),
            checkoutButton.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -10),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            ])
    }
    
    func configureVariantOptionsContainerView() {
        // Variant option selection container view
        variantOptionsContainerView.variantOptionsContainerViewStyle()
        self.view.addSubview(variantOptionsContainerView)
        NSLayoutConstraint.activate([
            variantOptionsContainerView.bottomAnchor.constraint(equalTo: checkoutButtonBackgroundView.topAnchor, constant: 0),
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 0),
            variantOptionsContainerView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: 0),
            variantOptionsContainerView.heightAnchor.constraint(equalToConstant: 60),
            ])
        
    }
    
    func loadProduct() {
        //print(product!)
        let someProduct = self.product?.data?.productByHandle
        let text = String(describing: someProduct)
        textView.text = text
        textView.isScrollEnabled = true
    }
    
    // Handle button clicks
    @objc func buttonAction(sender:UIButton!){
        if sender == closeButton {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        if sender == checkoutButton {
            
        }
    }
}
