//
//  ProductViewController.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
//import ImageSlideshow
import PassKit
import SafariServices

class ProductViewController: UIViewController, ActivityIndicatorPresenter, UIGestureRecognizerDelegate, UIScrollViewDelegate, VariantSelectionDelegate, ApplePayControllerDelegate, ClaimItemControllerDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var tag: String?
    var playerID: String?
    var product: Product?
    var selectedVariant: PurpleNode?
    var variantCount = 0
    var variants: [VariantsEdge] = []
    var mediaLinks: [String] = []
    let dateOpened: Date = Date()
    var interaction: Bool = false
    
    // Outlets
    let closeButton = UIButton()
    let checkoutBackgroundView = UIStackView()
    let applePayButtonContainerView = UIView()
    let variantOptionsContainerView = UIView()
    let imageCarouselContainerView = UIView()
    let descriptionContainerView = ProductDescriptionScrollView()
    let priceLabel = UILabel()
    let discountPriceLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionSeparatorView = UIView()
    let descriptionTextView = UITextView()
    let slideShow = MediaSlideshow()
    var optionsTapGesture = UITapGestureRecognizer()
    var optionsSelectorOverlayView = UIView()
    var optionsSelectorOverlayTapGesture = UITapGestureRecognizer()
    let optionsSelectorPlaceholderView = UIView()
    let stackView = UIStackView()
    
    // Constraints
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    // Size values
    var bottomPadding: CGFloat = 0
    var topPadding: CGFloat = 0
    var leftPadding: CGFloat = 0
    var rightPadding: CGFloat = 0
    var viewHeight: CGFloat = 0
    var viewWidth: CGFloat = 0
    let maxImageCarouselHeightProportion: CGFloat = 0.55
    
    var optionsSelectorViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ScrollViewDelegate
        descriptionContainerView.delegate = self
        
        // Background configuration
        self.view.productViewBackgroundStyle()
        
        // Load product
        self.loadProductData()
        
        // Image carousel
        self.configureImageCarouselContainerView()
        
        // Description container view
        self.configureDescriptionContainerView()
        
        // Checkout button
        self.configureCheckOutButtons()
        
        // Close button
        self.configureCloseButton()
        
        // Configure price tag
        self.configurePriceTagLabel()
        
        // Configure discount price tag
        self.configureDiscountPriceTagLabel()
        
        // Configure title label
        self.configureTitleLabel()
        
        // Configure description text
        self.configureDescriptionTextView()
        
        // Configure description separator
        self.configureDescriptionSeparator()
        
        // Variant option selection container view
        self.configureVariantOptionsContainerView()
        
        // Configure image slider
        self.configureImageSlider()
        
        // Update views data
        self.updateViewsData()
        
        // Create a new entry for clickreward
        Monetizr.shared.clickrewardCreate(tag: tag!, completionHandler: { success, error, value in ()})
        
        // Create a new entry for firstimpression
        if Monetizr.shared.impressionCountInSession == 0 {
            Monetizr.shared.firstimpressionCreate(sessionDuration: Monetizr.shared.sessionDurationSeconds(), completionHandler: { success, error, value in ()})
        }
        
        // Create a new entry for playerbehaviour
        Monetizr.shared.playerbehaviourCreate(deviceIdentifier: deviceIdentifier(), gameProgress: nil, sessionDuration: Monetizr.shared.sessionDurationSeconds(), completionHandler: { success, error, value in ()})
        
        // Increase impression count
        Monetizr.shared.increaseImpressionCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.accessibilityViewIsModal = true
        // Setup constraints
        self.activateInitialConstraints()
        
        // Update buttons
        updateCheckoutButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .screenChanged, argument:titleLabel)
    }
    
    override func viewDidLayoutSubviews() {
        if !screenIsInPortrait() {
            descriptionContainerView.scrollToTop(animated: true)
        }        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            // load slim view
        } else {
            // load wide view
        }
        
        // Deactivate previous constraints
        self.deactivateVariableConstraints()
        
        self.viewWidth = view.frame.size.width
        self.viewHeight = view.frame.size.height
        
        // Resize and position option selector view - do not do this if view is not in hierarchy
        self.optionsSelectorOverlayView.frame = CGRect(x: 0, y: 0, width: self.viewWidth, height: self.viewHeight)
        self.optionsSelectorPlaceholderView.center = self.optionsSelectorOverlayView.convert(self.optionsSelectorOverlayView.center, from:self.optionsSelectorOverlayView.superview)
        
        // Configure new constraints
        self.configureConstraintsForCurrentOrietnation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    override func accessibilityPerformEscape() -> Bool {
        self.buttonAction(sender:closeButton)
        return true
    }
    
    func activateInitialConstraints() {
        viewHeight = view.frame.size.height
        viewWidth = view.frame.size.width
        
        // Configure new constraints
        self.configureConstraintsForCurrentOrietnation()
    }
    
    func configureConstraintsForCurrentOrietnation() {
        if sharedConstraints.count < 1 {
            // Configure initial constraints
            self.configureSharedConstraints()
        }
        if (!sharedConstraints[0].isActive) {
            NSLayoutConstraint.activate(sharedConstraints)
        }
        
        self.deactivateVariableConstraints()
        
        if !screenIsInPortrait() {
            if compactConstraints.count < 1 {
                // Configure initial constraints
                self.configureCompactConstraints()
            }
            NSLayoutConstraint.activate(compactConstraints)
        }
        else {
            if regularConstraints.count < 1 {
                // Configure initial constraints
                self.configureRegularConstraints()
            }
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    func deactivateVariableConstraints() {
        // Deactivate variable constraints
        if regularConstraints.count > 0 && regularConstraints[0].isActive {
            NSLayoutConstraint.deactivate(regularConstraints)
            regularConstraints = []
        }
        if compactConstraints.count > 0 && compactConstraints[0].isActive {
            NSLayoutConstraint.deactivate(compactConstraints)
            compactConstraints = []
        }
    }
    
    func configureSharedConstraints() {
        // Create shared constraints array
        sharedConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            checkoutBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            
            // Variant option selection container view
            variantOptionsContainerView.bottomAnchor.constraint(equalTo: checkoutBackgroundView.topAnchor, constant: 0),
            variantOptionsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            variantOptionsContainerView.heightAnchor.constraint(equalToConstant: optionsSelectorViewHeight),
            
            // Variant stack view
            stackView.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 10),
            stackView.leftAnchor.constraint(equalTo: variantOptionsContainerView.leftAnchor, constant: 10),
            stackView.rightAnchor.constraint(equalTo: variantOptionsContainerView.rightAnchor, constant: 10-rightPadding),
            stackView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 10),
            
            // Image carousel container view
            imageCarouselContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            imageCarouselContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Image slideshow
            slideShow.topAnchor.constraint(equalTo: imageCarouselContainerView.topAnchor, constant: 0),
            slideShow.leftAnchor.constraint(equalTo: imageCarouselContainerView.leftAnchor, constant: 0),
            slideShow.rightAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            slideShow.bottomAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            descriptionContainerView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 0),
            
            // Price tag
            priceLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
            priceLabel.widthAnchor.constraint(equalToConstant: 120),
            priceLabel.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10),
            
            // Discount price tag
            discountPriceLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 0),
            discountPriceLabel.widthAnchor.constraint(equalToConstant: 120),
            discountPriceLabel.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10),
            
            // Product title
            titleLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: -10),
            
            // Description separator
            descriptionSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            descriptionSeparatorView.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            descriptionSeparatorView.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10),
            descriptionSeparatorView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 5),
            descriptionSeparatorView.topAnchor.constraint(greaterThanOrEqualTo: discountPriceLabel.bottomAnchor, constant: 5),
            
            // Description text
            descriptionTextView.topAnchor.constraint(equalTo: descriptionSeparatorView.bottomAnchor),
            descriptionTextView.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 0),
            descriptionTextView.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10),
            
            // Close button
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    // Landscape
    func configureCompactConstraints() {
        descriptionContainerView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: optionsSelectorViewHeight, right: 0)
        
        compactConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutBackgroundView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            checkoutBackgroundView.heightAnchor.constraint(equalToConstant: 70+bottomPadding),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            
            // Image carousel container view
            imageCarouselContainerView.heightAnchor.constraint(equalToConstant: viewHeight),
            imageCarouselContainerView.widthAnchor.constraint(equalToConstant: viewWidth/100*45),
            
            // Description text
            descriptionTextView.widthAnchor.constraint(equalToConstant: viewWidth/100*55-20-rightPadding),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10+topPadding),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10+leftPadding)
            ])
    }
    
    // Portrait
    func configureRegularConstraints() {
        descriptionContainerView.contentInset = UIEdgeInsets(top: viewHeight*maxImageCarouselHeightProportion, left: 0, bottom: optionsSelectorViewHeight, right: 0)
        
        regularConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            checkoutBackgroundView.heightAnchor.constraint(equalToConstant: 70+bottomPadding),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            //descriptionContainerView.topAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Image carousel container view
            imageCarouselContainerView.heightAnchor.constraint(equalToConstant: -descriptionContainerView.contentOffset.y),
            imageCarouselContainerView.widthAnchor.constraint(equalToConstant: viewWidth),
            
            // Description text
            descriptionTextView.widthAnchor.constraint(equalToConstant: viewWidth-20),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10+topPadding),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10+leftPadding)
            ])
    }
    
    func configureCloseButton() {
        // close button configuration
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.accessibilityLabel = NSLocalizedString("Close product", comment: "Close product")
        closeButton.setImage(UIImage(named: "ic_cross_white", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControlState())
        closeButton.addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(closeButton)
    }
    
    func configureCheckOutButtons() {
        // Configure container view
        checkoutBackgroundView.checkoutButtonBackgroundViewStyle()
        self.view.addSubview(checkoutBackgroundView)
        
        // Update buttons
        updateCheckoutButtons()
    }
    
    func updateCheckoutButtons() {
        // Remove all buttons
        checkoutBackgroundView.removeAllArrangedSubviews()
        
        // Add checkout button
        let checkoutButton = UIButton()
        // Configure checkout button
        checkoutButton.checkoutProductButtonStyle(title: product?.data?.productByHandle?.button_title)
        checkoutButton.addTarget(self, action: #selector(checkoutButtonAction), for: .touchUpInside)
        checkoutBackgroundView.addArrangedSubview(checkoutButton)
        
        // Add Apple Pay button
        if applePayAvailable() && applePayCanMakePayments() && Monetizr.shared.applePayMerchantID != nil && product?.data?.productByHandle?.claimable == false {
            let applePayButton = PKPaymentButton().buyButtonWithTheme()
            applePayButton.height(constant: 50)
            applePayButton.addTarget(self, action: #selector(buyApplePayButtonAction), for: .touchUpInside)
            checkoutBackgroundView.addArrangedSubview(applePayButton)
        }
        if applePayAvailable() && !applePayCanMakePayments() && Monetizr.shared.applePayMerchantID != nil && product?.data?.productByHandle?.claimable == false {
            let applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
            applePayButton.height(constant: 50)
            applePayButton.addTarget(self, action: #selector(setupApplePayButtonAction), for: .touchUpInside)
            checkoutBackgroundView.addArrangedSubview(applePayButton)
        }
    }
    
    func configureVariantOptionsContainerView() {
        // Variant option selection container view
        variantOptionsContainerView.variantOptionsContainerViewStyle()
        variantOptionsContainerView.isAccessibilityElement = true
        variantOptionsContainerView.accessibilityLabel = NSLocalizedString("Select product variant", comment: "Select product variant")
        variantOptionsContainerView.accessibilityTraits = .button
        self.view.addSubview(variantOptionsContainerView)
        
        // Configure option stack
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing = 10.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        variantOptionsContainerView.addSubview(stackView)
        
        // Handle taps
        optionsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        optionsTapGesture.numberOfTapsRequired = 1
        optionsTapGesture.numberOfTouchesRequired = 1
        variantOptionsContainerView.addGestureRecognizer(optionsTapGesture)
    }
    
    func configureImageCarouselContainerView() {
        // Image carousel container view
        imageCarouselContainerView.imageCarouselContainerViewStyle()
        view.addSubview(imageCarouselContainerView)
    }
    
    func configureDescriptionContainerView() {
        // Description container view
        descriptionContainerView.descriptionContainerViewStyle()
        descriptionContainerView.showsVerticalScrollIndicator = false
        view.addSubview(descriptionContainerView)
    }
    
    func configurePriceTagLabel() {
        // Configure price tag
        priceLabel.priceLabelStyle()
        priceLabel.accessibilityLabel = NSLocalizedString("Price", comment: "Price")
        descriptionContainerView.addSubview(priceLabel)
    }
    
    func configureDiscountPriceTagLabel() {
        // Configure price tag
        discountPriceLabel.discountPriceLabelStyle()
        discountPriceLabel.accessibilityLabel = NSLocalizedString("Original price", comment: "Original price")
        descriptionContainerView.addSubview(discountPriceLabel)
    }
    
    func configureTitleLabel() {
        // Configure product title
        titleLabel.productTitleLabelStyle()
        titleLabel.accessibilityLabel = NSLocalizedString("Product title", comment: "Product title")
        descriptionContainerView.addSubview(titleLabel)
    }
    
    func configureDescriptionSeparator() {
        descriptionSeparatorView.descriptionSeparatorViewStyle()
        descriptionContainerView.addSubview(descriptionSeparatorView)
    }
    
    func configureDescriptionTextView() {
        // Configure description text
        descriptionTextView.descriptionTextViewStyle()
        descriptionTextView.accessibilityLabel = NSLocalizedString("Product description", comment: "Product description")
        descriptionContainerView.addSubview(descriptionTextView)
    }
    
    func configureImageSlider() {
        // Configure image slider
        slideShow.translatesAutoresizingMaskIntoConstraints = false
        slideShow.contentScaleMode = .scaleAspectFill
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.slideShowTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        imageCarouselContainerView.addSubview(slideShow)
    }
    
    func loadProductData() {
        // Prepare image links Array
        let images = self.product?.data?.productByHandle?.images?.edges
        if images != nil {
            for image in images! {
                let link = image.node?.transformedSrc
                mediaLinks.append(link!)
            }
        }
        
        // Extract variants
        variants = (product?.data?.productByHandle?.variants?.edges)!
        
        // Count variants
        variantCount = variants.count
        
        // Select default variant
        selectedVariant = variants[0].node
    }
    
    func updateViewsData() {
        //Clear previous data
        titleLabel.text = ""
        priceLabel.text = ""
        discountPriceLabel.text = ""
        descriptionTextView.text = ""
        
        // Title label
        titleLabel.text = selectedVariant?.product?.title
        titleLabel.accessibilityValue = selectedVariant?.product?.title
        
        let priceAmount = selectedVariant?.priceV2?.amount ?? "0"
        let priceCurrency = selectedVariant?.priceV2?.currency ?? "USD"
        priceLabel.text = priceAmount.priceFormat(currency: priceCurrency)
        priceLabel.accessibilityValue = priceLabel.text
        
        let discointPriceAmount = selectedVariant?.compareAtPriceV2?.amount ?? "0"
        let discointPriceCurrency = selectedVariant?.compareAtPriceV2?.currency ?? "USD"
        if discointPriceAmount != "0" {
            discountPriceLabel.text = discointPriceAmount.priceFormat(currency: discointPriceCurrency)
            discountPriceLabel.accessibilityValue = discountPriceLabel.text
            discountPriceLabel.strikeThrough()
        }
        
        // Description text view
        descriptionTextView.text = selectedVariant?.product?.description_ios
        
        // Options selector show/hide
        stackView.removeAllSubviews()
        if variants.count > 1 {
            optionsSelectorViewHeight = 65
            view.setNeedsUpdateConstraints()
            
            for option in (selectedVariant?.selectedOptions)! {
                let optionView = UIStackView()
                optionView.axis = NSLayoutConstraint.Axis.vertical
                optionView.spacing = 3.0
                optionView.translatesAutoresizingMaskIntoConstraints = false
                
                let nameLabel = UILabel()
                nameLabel.text = option.name
                nameLabel.optionNameStyle()
                
                let valueLabel = UILabel()
                //valueLabel.text = (option.value ?? "")
                valueLabel.optionValueStyle()
                
                let expandDownImage = UIImage(named: String().expandDownImageName(), in: Bundle(for: type(of: self)), compatibleWith: nil)
                valueLabel.optionValueTextWithImage(text: (option.value ?? ""), image: expandDownImage)
                
                optionView.addArrangedSubview(nameLabel)
                optionView.addArrangedSubview(valueLabel)
                
                stackView.addArrangedSubview(optionView)
            }
        }
        
        // Load images in carousel
        if let selctedVariantImageLinkUrl = selectedVariant?.image?.transformedSrc {
            if let index = mediaLinks.firstIndex(of: selctedVariantImageLinkUrl) {
                mediaLinks.remove(at: index)
                mediaLinks.insert(selctedVariantImageLinkUrl, at: 0)
            }
        }
        
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.preload = .fixed(offset: 1)
        slideShow.setMediaInputs(mediaLinks)
    }
    
    func showOptionsSelector() {
        // Configure option selector overlay
        optionsSelectorOverlayView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        optionsSelectorOverlayView.addBlurEffect(style: UIBlurEffect.Style.dark)
        optionsSelectorOverlayView.accessibilityViewIsModal = true
        view.addSubview(optionsSelectorOverlayView);
        
        // Handle taps
        optionsSelectorOverlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        optionsSelectorOverlayTapGesture.numberOfTapsRequired = 1
        optionsSelectorOverlayTapGesture.numberOfTouchesRequired = 1
        optionsSelectorOverlayTapGesture.cancelsTouchesInView = false
        optionsSelectorOverlayTapGesture.delegate = self
        optionsSelectorOverlayView.addGestureRecognizer(optionsSelectorOverlayTapGesture)
        
        // Options selector placeholder
        optionsSelectorPlaceholderView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        optionsSelectorPlaceholderView.center = optionsSelectorOverlayView.convert(optionsSelectorOverlayView.center, from:optionsSelectorOverlayView.superview)
        optionsSelectorPlaceholderView.backgroundColor = .clear
        optionsSelectorOverlayView.addSubview(optionsSelectorPlaceholderView)
        
        // Add navigation controller childview controller
        let variantSelctionNavigationController = UINavigationController()
        addChild(variantSelctionNavigationController)
        variantSelctionNavigationController.view.frame.size.width = optionsSelectorPlaceholderView.frame.size.width
        variantSelctionNavigationController.view.frame.size.height = optionsSelectorPlaceholderView.frame.size.height
        optionsSelectorPlaceholderView.addSubview(variantSelctionNavigationController.view)
        variantSelctionNavigationController.didMove(toParent: self)
        
        // Populate first level selection
        let variantSelectionViewController = VariantSelectionViewController()
        variantSelectionViewController.variants = variants
        variantSelectionViewController.selectedVariant = selectedVariant
        variantSelectionViewController.delegate = self
        variantSelctionNavigationController.pushViewController(variantSelectionViewController, animated: true)
    }
    
    func closeOptionsSelector() {
        // Remove child view controllers
        self.children.forEach{$0.willMove(toParent: nil);$0.view.removeFromSuperview();$0.removeFromParent()}
        
        // Remove and reset optionsSelectorOverlayView
        optionsSelectorOverlayView.removeFromSuperview()
        optionsSelectorOverlayView = UIView()
        UIAccessibility.post(notification: .screenChanged, argument:titleLabel)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view?.superview == gestureRecognizer.view
    }
    
    func checkoutSelectedVariant() {
        self.showActivityIndicator()
        Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!) { success, error, checkout in
            self.hideActivityIndicator()
            // Show some error if needed
            if success {
                guard let url = URL(string: (checkout?.data?.checkoutCreate?.checkout?.webURL)!) else { return }
                
                // Open Checkout in web browser
                //UIApplication.shared.open(url)
                
                // Open Checkout in Safaru SFSafariViewController
                let vc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
                vc.delegate = self as? SFSafariViewControllerDelegate
                self.present(vc, animated: true)
            }
            else {
                // Handle error
                let alert = UIAlertController(title: "", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    @unknown default:
                        break
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Handle button clicks
    @objc func buttonAction(sender:UIButton!){
        if sender == closeButton {
            // Close product view
            navigationController?.popViewController(animated: true)
            Monetizr.shared.impressionvisibleCreate(tag: tag!, fromDate: dateOpened, completionHandler: { success, error, value in ()})
            if !interaction {
                Monetizr.shared.dismissCreate(tag: tag!, completionHandler: { success, error, value in ()})
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func checkoutButtonAction() {
        interaction = true
        // Start checkout or claim item
        let claimable = product?.data?.productByHandle?.claimable ?? false
        if claimable {
            // Proceed with claim
            self.claimSelectedVariant()
        }
        if !claimable  {
            // Proceed with standart checkout
            self.checkoutSelectedVariant()
        }
        
        if Monetizr.shared.checkoutCountInSession < 1 {
            Monetizr.shared.firstimpressioncheckoutCreate(firstImpressionCheckout: Monetizr.shared.sessionDurationMiliseconds(), completionHandler: { success, error, value in ()})
        }
        Monetizr.shared.increaseCheckoutCountInSession()
    }
    
    @objc func setupApplePayButtonAction() {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
    
    @objc func buyApplePayButtonAction() {
        let priceCurrency = selectedVariant?.priceV2?.currency ?? "USD"
        if priceCurrency.isValidCurrencyCode() {
            Monetizr.shared.buyWithApplePay(selectedVariant: selectedVariant!, tag: tag!, presenter: self) {success, error in
                // Show some error if needed
                if success {
                    // Success
                }
                else {
                    // Handle error
                }
            }
        }
        else {
            print("Selected variant currency is not supported by Apple Pay")
        }
    }
    
    @objc func claimSelectedVariant() {
        Monetizr.shared.claimCheckout(selectedVariant: selectedVariant!, tag: tag!, playerID: playerID ?? "", price: selectedVariant?.priceV2?.amount ?? "0", presenter: self) {success, error in
            // Show some error if needed
            if success {
                // Success
            }
            else {
                // Handle error
            }
        }
    }
    
    // Handle taps
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender == optionsTapGesture {
            interaction = true
            if variants.count > 1 {
                self.showOptionsSelector()
                if Monetizr.shared.clickCountInSession < 1 {
                    Monetizr.shared.firstimpressionclickCreate(firstImpressionClick: Monetizr.shared.sessionDurationMiliseconds(), completionHandler: { success, error, value in ()})
                }
                Monetizr.shared.increaseClickCountInSession()
            }
        }
        if sender == optionsSelectorOverlayTapGesture {
            self.closeOptionsSelector()
        }
    }
    
    // Select variant from options selector
    func optionValuesSelected(selectedValues: NSMutableArray) {
        let selectedValues = selectedValues
        var availableVariants: [VariantsEdge] = []
        if selectedValues.count > 0 {
            for variant in variants {
                let optionsValues: NSMutableArray = []
                for option in (variant.node?.selectedOptions)! {
                    optionsValues.add(option.value!)
                }
                if selectedValues.allSatisfy(optionsValues.contains) {
                    availableVariants.append(variant)
                }
            }
        }
        if availableVariants.count > 0 {
            selectedVariant = availableVariants[0].node
            self.updateViewsData()
        }
    }
    
    // Apple Pay finished
    func applePayFinishedWithCheckout(paymentSuccess: Bool?) {
        
        if paymentSuccess ?? false {
            let alert = UIAlertController(title: NSLocalizedString("Thank you!", comment: "Thank you!"), message: NSLocalizedString("Order confirmation", comment: "Order confirmation"), preferredStyle: .alert)
            alert.view.tintColor = UIColor(hex: 0xE0093B)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default, handler: { action in
                  // Switch if needed handle buttons
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Claim finished
    func claimItemFinishedWithCheckout(claim: Claim?) {
        // Show confiramtion alert
        guard claim != nil else {
            return
        }
        
        let alert = UIAlertController(title: "", message: claim?.message, preferredStyle: .alert)
        alert.view.tintColor = UIColor(hex: 0xE0093B)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default, handler: { action in
              // Switch if needed handle buttons
        }))
        self.present(alert, animated: true, completion: nil)
    }
 
    // Cureency string preparation
    func getCurrencyFormat(price:String, currency:String)->String{
        let convertPrice = NSNumber(value: Double(price)!)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        let convertedPrice = formatter.string(from: convertPrice)
        return convertedPrice!
    }
    
    func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }
    
    func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T : Comparable {
        return min(max(value, minimum), maximum)
    }
    
    // Slideshow fullscreen - not implemented
    @objc func slideShowTap() {
        slideShow.presentFullScreenController(from: self)
        if Monetizr.shared.clickCountInSession < 1 {
            Monetizr.shared.firstimpressionclickCreate(firstImpressionClick: Monetizr.shared.sessionDurationMiliseconds(), completionHandler: { success, error, value in ()})
        }
        Monetizr.shared.increaseClickCountInSession()
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.topPadding = self.view.safeAreaInsets.top
        self.bottomPadding = self.view.safeAreaInsets.bottom
        self.leftPadding = self.view.safeAreaInsets.left
        self.rightPadding = self.view.safeAreaInsets.right
        
        // Configure new constraints
        self.configureConstraintsForCurrentOrietnation()
    }
    
    func textExceedBoundsOf(_ textView: UITextView) -> Bool {
        let textHeight = textView.contentSize.height
        return textHeight > textView.bounds.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if screenIsInPortrait() {
            let offset = scrollView.contentOffset.y
            var height = abs(offset)
            if offset > 0 {
                height = 0
            }
            for constraint in imageCarouselContainerView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = height
                }
            }
        }
    }
}
