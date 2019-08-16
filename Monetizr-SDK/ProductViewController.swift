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
import PassKit

class ProductViewController: UIViewController, ActivityIndicatorPresenter, UIGestureRecognizerDelegate, VariantSelectionDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var tag: String?
    var product: Product?
    var selectedVariant: PurpleNode?
    var variantCount = 0
    var variants: [VariantsEdge] = []
    var imageLinks: NSMutableArray = []
    let dateOpened: Date = Date()
    var interaction: Bool = false
    
    // Outlets
    let closeButton = UIButton()
    let checkoutBackgroundView = UIStackView()
    let applePayButtonContainerView = UIView()
    let variantOptionsContainerView = UIView()
    let imageCarouselContainerView = UIView()
    let descriptionContainerView = UIView()
    let priceLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionTextView = UITextView()
    let slideShow = ImageSlideshow()
    let variantOptionDisclosureView = UIImageView()
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
    let minImageCarouselHeightProportion: CGFloat = 0.20
    
    var optionsSelectorViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Drag to dismiss
        let gestureRecognizer = UIPanGestureRecognizer(target: self,
                                                       action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        // Background configuration
        self.view.backgroundColor = .white
        
        // Load product
        self.loadProductData()
        
        // Checkout button
        self.configureCheckOutButtons()
        
        // Variant option selection container view
        self.configureVariantOptionsContainerView()
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
        
        // Update views data
        self.updateViewsData()
        
        // Setup constraints
        self.activateInitialConstraints()
        
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
        updateCheckoutButtons()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Deactivate previous constraints
        self.deactivateVariableConstraints()
        
        // Update view sizes
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        coordinator.animate(alongsideTransition: { (context) in
            // Configure safe area insets
            if #available(iOS 11.0, *) {
                self.topPadding = self.view.safeAreaInsets.top
                self.bottomPadding = self.view.safeAreaInsets.bottom
                self.leftPadding = self.view.safeAreaInsets.left
                self.rightPadding = self.view.safeAreaInsets.right
            }
            
            // Resize and position option selector view - do not do this if view is not in hierarchy
            self.optionsSelectorOverlayView.frame = CGRect(x: 0, y: 0, width: self.viewWidth, height: self.viewHeight)
            self.optionsSelectorPlaceholderView.center = self.optionsSelectorOverlayView.convert(self.optionsSelectorOverlayView.center, from:self.optionsSelectorOverlayView.superview)
            
            // Configure new constraints
            self.configureConstraintsForCurrentOrietnation()
            
        }, completion: nil)
    }
    
    func activateInitialConstraints() {
        let window = UIApplication.shared.keyWindow
        viewHeight = view.frame.size.height
        viewWidth = view.frame.size.width
        
        if #available(iOS 11.0, *) {
            topPadding = (window?.safeAreaInsets.top)!
            bottomPadding = (window?.safeAreaInsets.bottom)!
            leftPadding = (window?.safeAreaInsets.left)!
            rightPadding = (window?.safeAreaInsets.right)!
        }
        
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
        
        if UIDevice.current.orientation.isLandscape {
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
            
            // Option disclosure view
            variantOptionDisclosureView.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            variantOptionDisclosureView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 0),
            variantOptionDisclosureView.widthAnchor.constraint(equalToConstant: 40),
            
            // Variant stack view
            stackView.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 10),
            stackView.leftAnchor.constraint(equalTo: variantOptionsContainerView.leftAnchor, constant: 10),
            stackView.rightAnchor.constraint(equalTo: variantOptionDisclosureView.leftAnchor, constant: 10),
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
            descriptionContainerView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            
            // Price tag
            priceLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
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
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 0),
            
            // Close button
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    func configureCompactConstraints() {
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
            imageCarouselContainerView.widthAnchor.constraint(equalToConstant: viewWidth/100*55),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10+topPadding),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10+leftPadding),
            
            // Option disclosure view
            variantOptionDisclosureView.rightAnchor.constraint(equalTo: variantOptionsContainerView.rightAnchor, constant: 0-rightPadding),
            
            // Description text
            descriptionTextView.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10-rightPadding),
            
            // Price tag
            priceLabel.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10-rightPadding)
            ])
    }
    
    func configureRegularConstraints() {
        regularConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            checkoutBackgroundView.heightAnchor.constraint(equalToConstant: 70+bottomPadding),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Image carousel container view
            imageCarouselContainerView.heightAnchor.constraint(equalToConstant: viewHeight*maxImageCarouselHeightProportion),
            imageCarouselContainerView.widthAnchor.constraint(equalToConstant: viewWidth),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10+topPadding),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10+leftPadding),
            
            // Option disclosure view
            variantOptionDisclosureView.rightAnchor.constraint(equalTo: variantOptionsContainerView.rightAnchor, constant: 0-rightPadding),
            
            // Description text
            descriptionTextView.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10-rightPadding),
            
            // Price tag
            priceLabel.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -10-rightPadding)
            ])
    }
    
    func configureCloseButton() {
        // Close button
        closeButton.closeProductButtonStyle()
        closeButton.accessibilityLabel = NSLocalizedString("Close product", comment: "Close product")
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
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
        checkoutButton.checkoutProductButtonStyle()
        checkoutButton.addTarget(self, action: #selector(checkoutButtonAction), for: .touchUpInside)
        checkoutBackgroundView.addArrangedSubview(checkoutButton)
        
        // Add Apple Pay button
        if applePayAvailable() && applePayCanMakePayments() {
            let applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
            applePayButton.height(constant: 50)
            applePayButton.addTarget(self, action: #selector(buyApplePayButtonAction), for: .touchUpInside)
            checkoutBackgroundView.addArrangedSubview(applePayButton)
        }
        if applePayAvailable() && !applePayCanMakePayments() {
            let applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
            applePayButton.height(constant: 50)
            applePayButton.addTarget(self, action: #selector(setupApplePayButtonAction), for: .touchUpInside)
            checkoutBackgroundView.addArrangedSubview(applePayButton)
        }
    }
    
    func configureVariantOptionsContainerView() {
        // Variant option selection container view
        variantOptionsContainerView.variantOptionsContainerViewStyle()
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
        priceLabel.accessibilityLabel = NSLocalizedString("Price", comment: "Price")
        descriptionContainerView.addSubview(priceLabel)
    }
    
    func configureTitleLabel() {
        // Configure product title
        titleLabel.titleLabelStyle()
        titleLabel.accessibilityLabel = NSLocalizedString("Product title", comment: "Product title")
        descriptionContainerView.addSubview(titleLabel)
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
        for image in images! {
            let link = image.node?.transformedSrc
            imageLinks.add(link!)
        }
        
        // Extract variants
        variants = (product?.data?.productByHandle?.variants?.edges)!
        
        // Count variants
        variantCount = variants.count
        
        // Select default variant
        selectedVariant = variants[0].node
    }
    
    func updateViewsData() {
        // Title label
        titleLabel.text = selectedVariant?.product?.title
        titleLabel.accessibilityValue = selectedVariant?.product?.title
        
        priceLabel.text = self.getCurrencyFormat(price: (selectedVariant?.priceV2?.amount)!, currency: (selectedVariant?.priceV2?.currency)!)
        priceLabel.accessibilityValue = priceLabel.text
        
        // Description text view
        descriptionTextView.text = selectedVariant?.product?.description_ios
        
        let imageSources = NSMutableArray()
        // Image slide show
        for url in imageLinks {
            imageSources.add(AlamofireSource(urlString: url as! String)!)
        }
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.preload = .fixed(offset: 1)
        slideShow.setImageInputs(imageSources as! [InputSource])
        
        stackView.removeAllSubviews()
        
        // Options selector show/hide
        if variants.count > 1 {
            optionsSelectorViewHeight = 55
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
                valueLabel.text = option.value
                valueLabel.optionValueStyle()
                
                optionView.addArrangedSubview(nameLabel)
                optionView.addArrangedSubview(valueLabel)
                
                stackView.addArrangedSubview(optionView)
            }
        }
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
        optionsSelectorPlaceholderView.backgroundColor = .white
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
        variantSelectionViewController.delegate = self
        variantSelctionNavigationController.pushViewController(variantSelectionViewController, animated: true)
    }
    
    func closeOptionsSelector() {
        // Remove child view controllers
        self.children.forEach{$0.willMove(toParent: nil);$0.view.removeFromSuperview();$0.removeFromParent()}
        
        // Remove and reset optionsSelectorOverlayView
        optionsSelectorOverlayView.removeFromSuperview()
        optionsSelectorOverlayView = UIView()
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
                UIApplication.shared.open(url)
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
        // Start checkout
        self.checkoutSelectedVariant()
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
        Monetizr.shared.buyWithApplePay(selectedVariant: selectedVariant!) { success, error in
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
    
    // Cureency string preparation
    func getCurrencyFormat(price:String, currency:String)->String{
        let convertPrice = NSNumber(value: Double(price)!)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        let convertedPrice = formatter.string(from: convertPrice)
        return convertedPrice!
    }
    
    // Drag to dismiss and enlarge description view
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        let translation = sender.translation(in: view)
        
        let newY = ensureRange(value: view.frame.minY + translation.y, minimum: 0, maximum: view.frame.maxY)
        let progress = progressAlongAxis(newY, view.bounds.height)
        
        if view.frame.origin.y == CGFloat(0.0)  {
            if UIDevice.current.orientation.isPortrait {
                for constraint in imageCarouselContainerView.constraints {
                    if constraint.firstAttribute == .height {
                        if imageCarouselContainerView.frame.size.height <= viewHeight*maxImageCarouselHeightProportion+1 {
                            if textExceedBoundsOf(descriptionTextView) || translation.y > 0 {
                                let newH = ensureRange(value: constraint.constant + translation.y, minimum: viewHeight*minImageCarouselHeightProportion, maximum: viewHeight*maxImageCarouselHeightProportion)
                                constraint.constant = newH
                            }
                        }
                    }
                }
            }
        }
        
        if imageCarouselContainerView.frame.size.height >= viewHeight*maxImageCarouselHeightProportion {
            view.frame.origin.y = newY //Move view to new position
        }
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if imageCarouselContainerView.frame.size.height >= viewHeight*maxImageCarouselHeightProportion && velocity.y >= 300 || progress > percentThreshold {
                Monetizr.shared.impressionvisibleCreate(tag: tag!, fromDate: dateOpened, completionHandler: { success, error, value in ()})
                if !interaction {
                    Monetizr.shared.dismissCreate(tag: tag!, completionHandler: { success, error, value in ()})
                }
                self.dismiss(animated: true) //Perform dismiss
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame.origin.y = 0 // Revert animation
                })
            }
        }
        
        sender.setTranslation(.zero, in: view)
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
    
    // Slideshow fullscreen
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
        #if DEBUG
        print("saveAreaInsetsDidChange")
        print("top:    " + String(describing: view.safeAreaInsets.top))
        print("right:  " + String(describing: view.safeAreaInsets.right))
        print("bottom: " + String(describing: view.safeAreaInsets.bottom))
        print("left:   " + String(describing: view.safeAreaInsets.left))
        #endif
    }
    
    func textExceedBoundsOf(_ textView: UITextView) -> Bool {
        let textHeight = textView.contentSize.height
        return textHeight > textView.bounds.height
    }
}
