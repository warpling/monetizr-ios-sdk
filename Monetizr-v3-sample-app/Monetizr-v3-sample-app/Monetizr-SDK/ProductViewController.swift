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
    var token = ""
    var tag = ""
    var product: Product? {
        didSet{
            //print(product!)
            print("Product retrieved")
            let someProduct = self.product?.data?.productByHandle
            
            let text = String(describing: someProduct)
            textView.text = text
            textView.isScrollEnabled = true
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background configuration
        self.view.backgroundColor = .white
        
        // TextView
        //textView.backgroundColor = .red
        self.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 0),
            textView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: 0),
            textView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: 0),
            ])
        
        // Close button
        let closeButton = UIButton(frame: .zero)
        closeButton.closeProductButtonStyle()
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            ])
        
        // Load product
        self.loadProductData()
    }
    
    // Load product data
    func loadProductData() {
        let url = URL(string: "https://api3.themonetizr.com/api/products/tag/"+tag)!
        let headers: HTTPHeaders = [
            "Authorization": "Bearer "+token
        ]
        Alamofire.request(url, headers: headers).responseProduct { response in
            if let retrievedProduct = response.result.value {
                self.product = retrievedProduct
            }
            else if let error = response.result.error as? URLError {
                print("URLError occurred: \(error)")
            }
            else {
                print("Unknown error: \(String(describing: response.result.error))")
            }
        }
    }
    
    // Handle button clicks
    @objc func buttonAction(sender:UIButton!){
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
