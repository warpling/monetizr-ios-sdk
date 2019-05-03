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
    
    var product: Product?
    var variantCount = 0
    
    // Outlets
    let textView = UITextView(frame: .zero)
    let closeButton = UIButton(frame: .zero)
    let checkoutButtonBackgroundView = UIView(frame: .zero)
    let checkoutButton = UIButton(frame: .zero)
    let variantOptionsContainerView = UIView(frame: .zero)
    let imageCarouselContainerView = UIView(frame: .zero)
    
    // Constraints
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var checkoutButtonBackgroundViewConstraint = NSLayoutConstraint()
    private var imageCarouselContainerViewHeightConstraint = NSLayoutConstraint()
    
    // Size values
    var bottomPadding: CGFloat = 0
    var topPadding: CGFloat = 0
    var viewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background configuration
        self.view.backgroundColor = .white
        
        // Count variants
        variantCount = (product?.data?.productByHandle?.variants?.edges!.count)!
        
        // Checkout button
        self.configureCheckOutButton()
        
        // Variant option selection container view
        if variantCount > 0 {
            self.configureVariantOptionsContainerView()
        }
        
        // Text View
        self.configureTextView()
        
        // Image carousel
        self.configureImageCarouselContainerView()
        
        // Setup constraints
        self.configureSharedConstraints()
        self.configureCompatConstraints()
        self.configureRegularConstraints()
        
        // Close button
        self.configureCloseButton()
        
        // Load product
        self.loadProduct()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = (window?.safeAreaInsets.top)!
            bottomPadding = (window?.safeAreaInsets.bottom)!
            viewHeight = view.frame.size.height
        }
        
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint.constant = 70+bottomPadding
        
        // Image carousel container view
        imageCarouselContainerViewHeightConstraint.constant = viewHeight/100*55
        
        if (!sharedConstraints[0].isActive) {
            // activating shared constraints
            NSLayoutConstraint.activate(sharedConstraints)
        }
        
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    func configureSharedConstraints() {
        
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint = checkoutButtonBackgroundView.heightAnchor.constraint(equalToConstant: 70+bottomPadding)
        
        // Image carousel container view
        imageCarouselContainerViewHeightConstraint = imageCarouselContainerView.heightAnchor.constraint(equalToConstant: viewHeight/100*55)
        
        // Create shared constraints array
        sharedConstraints.append(contentsOf: [
            
            // TextView
            textView.topAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            textView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: 0),
            textView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            
            // Checkout buttons background
            checkoutButtonBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            checkoutButtonBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            checkoutButtonBackgroundViewConstraint,
            
            // Checkout button
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -10),
            checkoutButton.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 10),
            checkoutButton.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -10),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Variant option selection container view
            variantOptionsContainerView.bottomAnchor.constraint(equalTo: checkoutButtonBackgroundView.topAnchor, constant: 0),
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            variantOptionsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            variantOptionsContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Image carousel container view
            imageCarouselContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            imageCarouselContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageCarouselContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            imageCarouselContainerViewHeightConstraint,
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    func configureCompatConstraints() {
        compactConstraints.append(contentsOf: [
            //
            ])
    }
    
    func configureRegularConstraints() {
        regularConstraints.append(contentsOf: [
            //
            ])
    }
    
    func configureTextView() {
        // TextView
        self.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureCloseButton() {
        // Close button
        closeButton.closeProductButtonStyle()
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }
    
    func configureCheckOutButton() {
        // Checkout buttons background
        checkoutButtonBackgroundView.checkoutButtonBackgroundViewStyle()
        self.view.addSubview(checkoutButtonBackgroundView)
        
        // Checkout button
        checkoutButton.checkoutProductButtonStyle()
        checkoutButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(checkoutButton)
    }
    
    func configureVariantOptionsContainerView() {
        // Variant option selection container view
        variantOptionsContainerView.variantOptionsContainerViewStyle()
        self.view.addSubview(variantOptionsContainerView)
        
    }
    
    func configureImageCarouselContainerView() {
        // Image carousel container view
        imageCarouselContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageCarouselContainerView.backgroundColor = .orange
        view.addSubview(imageCarouselContainerView)
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
            // Close product view
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        if sender == checkoutButton {
            // Start checkout
            
        }
    }
}
