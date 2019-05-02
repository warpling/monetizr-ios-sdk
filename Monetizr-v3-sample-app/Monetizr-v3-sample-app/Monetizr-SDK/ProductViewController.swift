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
    let closeButton = UIButton(frame: .zero)
    let checkoutButton = UIButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background configuration
        self.view.backgroundColor = .white
        
        // Text View
        self.configureTextView()
        
        // Close button
        self.configureCloseButton()
        
        // Checkout button
        self.configureCheckOutButton()
        
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
            textView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: 0),
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
