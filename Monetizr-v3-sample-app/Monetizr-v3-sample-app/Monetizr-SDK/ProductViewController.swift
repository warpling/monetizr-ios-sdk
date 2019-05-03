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
    let closeButton = UIButton(frame: .zero)
    let checkoutButtonBackgroundView = UIView(frame: .zero)
    let checkoutButton = UIButton(frame: .zero)
    let variantOptionsContainerView = UIView(frame: .zero)
    let imageCarouselContainerView = UIView(frame: .zero)
    let descriptionContainerScrollView = UIScrollView(frame: .zero)
    
    // Constraints
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var checkoutButtonBackgroundViewConstraint = NSLayoutConstraint()
    private var imageCarouselContainerViewHeightConstraint = NSLayoutConstraint()
    private var imageCarouselContainerViewWidthConstraint = NSLayoutConstraint()
    
    // Size values
    var bottomPadding: CGFloat = 0
    var topPadding: CGFloat = 0
    var viewHeight: CGFloat = 0
    var viewWidth: CGFloat = 0
    
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
        
        // Image carousel
        self.configureImageCarouselContainerView()
        
        // Description container scroll view
        self.configureDescriptionContainerScrollView()
        
        // Close button
        self.configureCloseButton()
        
        // Setup constraints
        self.configureSharedConstraints()
        self.configureCompatConstraints()
        self.configureRegularConstraints()
        self.activateInitialConstraints()
        
        // Load product
        self.loadProduct()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func activateInitialConstraints() {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = (window?.safeAreaInsets.top)!
            bottomPadding = (window?.safeAreaInsets.bottom)!
            viewHeight = view.frame.size.height
            viewWidth = view.frame.size.width
        }
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint.constant = 70+bottomPadding
        if (!sharedConstraints[0].isActive) {
            // activating shared constraints
            NSLayoutConstraint.activate(sharedConstraints)
        }
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth/100*55
            
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            print("Portrait")
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight/100*55
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewWidth = size.width
        viewHeight = size.height
        coordinator.animate(alongsideTransition: { (context) in
            //
            if #available(iOS 11.0, *) {
                self.topPadding = self.view.safeAreaInsets.top
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 11.0, *) {
                self.bottomPadding = self.view.safeAreaInsets.bottom
            } else {
                // Fallback on earlier versions
            }
            // Checkout buttons background
            self.checkoutButtonBackgroundViewConstraint.constant = 70+self.bottomPadding
        }, completion: nil)
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth/100*55
            
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            print("Portrait")
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight/100*55
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        /*
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = (window?.safeAreaInsets.top)!
            bottomPadding = (window?.safeAreaInsets.bottom)!
            viewHeight = view.frame.size.height
            viewWidth = view.frame.size.width
        }
        
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint.constant = 70+bottomPadding
        
        if (!sharedConstraints[0].isActive) {
            // activating shared constraints
            NSLayoutConstraint.activate(sharedConstraints)
        }
        
        if traitCollection.verticalSizeClass == .compact {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth/100*55
            
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight/100*55
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
 */
    }
    
    func configureSharedConstraints() {
        
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint = checkoutButtonBackgroundView.heightAnchor.constraint(equalToConstant: 70+bottomPadding)
        
        // Image carousel container view
        imageCarouselContainerViewHeightConstraint = imageCarouselContainerView.heightAnchor.constraint(equalToConstant: viewHeight/100*55)
        
        // Image carousel container view
        imageCarouselContainerViewWidthConstraint = imageCarouselContainerView.widthAnchor.constraint(equalToConstant: viewWidth/100*55)
        
        // Create shared constraints array
        sharedConstraints.append(contentsOf: [
            
            // Checkout buttons background
            checkoutButtonBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            checkoutButtonBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            checkoutButtonBackgroundViewConstraint,
            
            // Checkout button
            checkoutButton.topAnchor.constraint(equalTo: checkoutButtonBackgroundView.topAnchor, constant: 10),
            checkoutButton.leftAnchor.constraint(equalTo: checkoutButtonBackgroundView.safeLeftAnchor, constant: 10),
            checkoutButton.rightAnchor.constraint(equalTo: checkoutButtonBackgroundView.safeRightAnchor, constant: -10),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Variant option selection container view
            variantOptionsContainerView.bottomAnchor.constraint(equalTo: checkoutButtonBackgroundView.topAnchor, constant: 0),
            variantOptionsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            variantOptionsContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Image carousel container view
            imageCarouselContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            imageCarouselContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageCarouselContainerViewWidthConstraint,
            imageCarouselContainerViewHeightConstraint,
            
            // Description container scroll view
            descriptionContainerScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            descriptionContainerScrollView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    func configureCompatConstraints() {
        compactConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            
            // Description container scroll view
            descriptionContainerScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            descriptionContainerScrollView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            ])
    }
    
    func configureRegularConstraints() {
        regularConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Description container scroll view
            descriptionContainerScrollView.topAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            descriptionContainerScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            ])
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
        imageCarouselContainerView.imageCarouselContainerViewStyle()
        view.addSubview(imageCarouselContainerView)
    }
    
    func configureDescriptionContainerScrollView() {
        // Description container scroll view
        descriptionContainerScrollView.descriptionContainerScrollViewStyle()
        //descriptionContainerScrollView.contentSize = descriptionContainerScrollView.frame.size
        view.addSubview(descriptionContainerScrollView)
    }
    
    func loadProduct() {
        //print(product!)
        let someProduct = self.product?.data?.productByHandle
        _ = String(describing: someProduct)
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
