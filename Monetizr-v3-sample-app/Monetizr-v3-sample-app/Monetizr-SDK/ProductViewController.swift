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
import ImageSlideshow

class ProductViewController: UIViewController {
    
    var product: Product?
    var selectedVariant: PurpleNode?
    var variantCount = 0
    var imageLinks: NSMutableArray = []
    
    // Outlets
    let closeButton = UIButton()
    let checkoutButtonBackgroundView = UIView()
    let checkoutButton = UIButton()
    let variantOptionsContainerView = UIView()
    let imageCarouselContainerView = UIView()
    let descriptionContainerView = UIView()
    let priceLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionTextView = UITextView()
    let slideShow = ImageSlideshow()
    let variantOptionDisclosureView = UIImageView()
    let optionsStackView = UIStackView()
    
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
        
        // Load product
        self.loadProductData()
        
        // Checkout button
        self.configureCheckOutButton()
        
        // Variant option selection container view
        self.configureVariantOptionsContainerView()
        
        // Variant option disclosure
        self.configureVariantOptionDisclosure()
        
        // Image carousel
        self.configureImageCarouselContainerView()
        
        // Description container view
        self.configureDescriptionContainerView()
        
        // Close button
        self.configureCloseButton()
        
        // Configure price tag
        self.configurePriceTagLabel()
        
        // Configure title label
        self.configureTitleLabel()
        
        // Configure description text
        self.configureDescriptionTextView()
        
        // Configure image slider
        self.configureImageSlider()
        
        // Configure options selector
        self.configureOptionsSelector()
        
        // Update views data
        self.updateViewsData()
        
        // Setup constraints
        self.configureSharedConstraints()
        self.configureCompatConstraints()
        self.configureRegularConstraints()
        self.activateInitialConstraints()
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
        
        self.configureConstraintsForCurrentOrietnation()
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
        
        self.configureConstraintsForCurrentOrietnation()
    }
    
    func configureConstraintsForCurrentOrietnation() {
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
            
            // Option disclosure view
            variantOptionDisclosureView.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            variantOptionDisclosureView.rightAnchor.constraint(equalTo: variantOptionsContainerView.safeRightAnchor, constant: 0),
            variantOptionDisclosureView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 0),
            variantOptionDisclosureView.widthAnchor.constraint(equalToConstant: 40),
            
            // Option selection stack view
            optionsStackView.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            optionsStackView.leftAnchor.constraint(equalTo: variantOptionsContainerView.leftAnchor, constant: 0),
            optionsStackView.rightAnchor.constraint(equalTo: variantOptionDisclosureView.leftAnchor, constant: 0),
            optionsStackView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 0),
            
            // Image carousel container view
            imageCarouselContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            imageCarouselContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageCarouselContainerViewWidthConstraint,
            imageCarouselContainerViewHeightConstraint,
            
            // Image slideshow
            slideShow.topAnchor.constraint(equalTo: imageCarouselContainerView.topAnchor, constant: 0),
            slideShow.leftAnchor.constraint(equalTo: imageCarouselContainerView.leftAnchor, constant: 0),
            slideShow.rightAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            slideShow.bottomAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            descriptionContainerView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            
            // Price tag
            priceLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
            priceLabel.rightAnchor.constraint(equalTo: descriptionContainerView.safeRightAnchor, constant: -10),
            priceLabel.heightAnchor.constraint(equalToConstant: 30),
            priceLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Product title
            titleLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Description text
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionTextView.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            descriptionTextView.rightAnchor.constraint(equalTo: descriptionContainerView.safeRightAnchor, constant: -10),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 0),
            
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
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            ])
    }
    
    func configureRegularConstraints() {
        regularConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
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
    
    func configureVariantOptionDisclosure() {
        variantOptionDisclosureView.translatesAutoresizingMaskIntoConstraints = false
        variantOptionDisclosureView.backgroundColor = .clear
        variantOptionDisclosureView.image = UIImage.disclosureIndicator()
        variantOptionDisclosureView.contentMode = .center
        variantOptionsContainerView.addSubview(variantOptionDisclosureView)
    }
    
    func configureImageCarouselContainerView() {
        // Image carousel container view
        imageCarouselContainerView.imageCarouselContainerViewStyle()
        view.addSubview(imageCarouselContainerView)
    }
    
    func configureDescriptionContainerView() {
        // Description container view
        descriptionContainerView.descriptionContainerViewStyle()
        view.addSubview(descriptionContainerView)
    }
    
    func configurePriceTagLabel() {
        // Configure price tag
        priceLabel.priceLabelStyle()
        descriptionContainerView.addSubview(priceLabel)
    }
    
    func configureTitleLabel() {
        // Configure product title
        titleLabel.titleLabelStyle()
        descriptionContainerView.addSubview(titleLabel)
    }
    
    func configureDescriptionTextView() {
        // Configure description text
        descriptionTextView.descriptionTextViewStyle()
        descriptionContainerView.addSubview(descriptionTextView)
    }
    
    func configureImageSlider() {
        // Configure image slider
        slideShow.translatesAutoresizingMaskIntoConstraints = false
        slideShow.contentScaleMode = .scaleAspectFill
        imageCarouselContainerView.addSubview(slideShow)
    }
    
    func configureOptionsSelector() {
        // Configure options selector
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .horizontal
        optionsStackView.alignment = .leading // .leading .firstBaseline .center .trailing .lastBaseline
        optionsStackView.distribution = .fillEqually // .fillEqually .fillProportionally .equalSpacing .equalCentering
        optionsStackView.backgroundColor = .orange
        variantOptionsContainerView.addSubview(optionsStackView)
    }
    
    func loadProductData() {
        // Prepare image links Array
        let images = self.product?.data?.productByHandle?.images?.edges
        for image in images! {
            let link = image.node?.transformedSrc
            imageLinks.add(link!)
        }
        
        // Count variants
        variantCount = (product?.data?.productByHandle?.variants?.edges!.count)!
        
        // Select default variant
        selectedVariant = product?.data?.productByHandle?.variants?.edges![0].node
    }
    
    func updateViewsData() {
        // Title label
        titleLabel.text = selectedVariant?.product?.title
        
        // Price tagd label
        priceLabel.text = (selectedVariant?.priceV2?.currencyCode)!+" "+(selectedVariant?.priceV2?.amount)!
        
        // Description text view
        descriptionTextView.text = selectedVariant?.product?.description
        
        let imageSources = NSMutableArray()
        // Image slide show
        for url in imageLinks {
            imageSources.add(AlamofireSource(urlString: url as! String)!)
        }
        slideShow.setImageInputs(imageSources as! [InputSource])
        
        // Selected options
        optionsStackView.removeAllArrangedSubviews()
        for option in (selectedVariant?.selectedOptions)! {
            let view = UIView()
            //view.backgroundColor = .blue
            optionsStackView.addArrangedSubview(view)
            let nameLabel = UILabel()
            nameLabel.optionNameStyle()
            nameLabel.text = option.name
            nameLabel.sizeForOption()
            view.addSubview(nameLabel)
        }
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
